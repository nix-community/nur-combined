#!/usr/bin/env python3
"""Structured Nix package updater.

Responsibilities:
  * NixEvaluator: package discovery and metadata evaluation.
  * UpdatePlanner: immutable per-package update plan.
  * UpdateExecutor: derivation / legacy / command / nix-update execution.
  * PackageTransaction: filesystem snapshot/restore (no Git).
  * GitCommitCoordinator: isolated --commit via Git worktree.
  * UpdateOrchestrator: coordination and result collection.

Normal failures roll back from a pre-execution filesystem snapshot.
Only scripts with supportedFeatures = ["commit"] have stdout captured
(for the JSON commit protocol); otherwise stdout/stderr are inherited.
"""

import argparse
import datetime
import hashlib
import json
import os
import shlex
import shutil
import stat
import subprocess
import sys
import tempfile
import uuid

from dataclasses import dataclass
from pathlib import Path


# ============================================================================
# Configuration
# ============================================================================

REPO_ROOT = Path(__file__).resolve().parents[2]
ROOT_NIX_FILE = (REPO_ROOT / "default.nix").resolve()

FEATURE_COMMIT = "commit"
FEATURE_SILENT = "silent"

MAGIC_PLACEHOLDER = "sha256-AzH1rZFqEH8sovZZfJykvsEmCedEZWigQFHWHl6/PdE="
UPDATE_ARTIFACT_SUFFIXES = (".cmp", ".fetchlog", ".bak")


# ============================================================================
# Logging and process execution
# ============================================================================


def log(*args):
    print(*args, file=sys.stderr)


def run_process(command, *, cwd=None, env=None, capture_output=True):
    command = [str(arg) for arg in command]
    kwargs = {
        "cwd": str(cwd) if cwd is not None else None,
        "env": env,
        "text": True,
        "check": False,
    }
    if capture_output:
        kwargs["capture_output"] = True
    else:
        kwargs["stdout"] = None
        kwargs["stderr"] = None

    try:
        return subprocess.run(command, **kwargs)
    except FileNotFoundError as exc:
        raise RuntimeError(f"Command not found: {command[0]}") from exc


def format_command_failure(exc):
    message = f"command failed with exit code {exc.returncode}"
    stderr = getattr(exc, "stderr", None) or ""
    stdout = getattr(exc, "output", None) or ""
    if stderr.strip():
        message += f"\nstderr:\n{stderr.strip()}"
    if stdout.strip():
        message += f"\nstdout:\n{stdout.strip()}"
    return message


@dataclass
class CommandExecution:
    command: list
    stdout: str = ""
    stderr: str = ""
    returncode: int = 0


@dataclass
class UpdateExecution:
    commands: list
    stdout: str = ""
    stderr: str = ""
    returncode: int = 0

    @property
    def command(self):
        if len(self.commands) == 1:
            return self.commands[0]
        return self.commands

    def as_dict(self):
        return {
            "command": self.command,
            "stdout": self.stdout,
            "stderr": self.stderr,
            "returncode": self.returncode,
        }


# ============================================================================
# Nix expression evaluation
# ============================================================================


def nix_quote(value):
    value = str(value)
    for old, new in (
        ("\\", "\\\\"),
        ('"', '\\"'),
        ("${", "\\${"),
        ("\n", "\\n"),
        ("\r", "\\r"),
        ("\t", "\\t"),
    ):
        value = value.replace(old, new)
    return f'"{value}"'


def make_package_eval_expr(pkg_name, body, *, root_nix_file=None):
    root_nix_file = Path(root_nix_file or ROOT_NIX_FILE).resolve()
    root_literal = nix_quote(root_nix_file)
    segments_literal = nix_quote(json.dumps(pkg_name.split("."), ensure_ascii=False))

    return f"""
let
  pkgs = import <nixpkgs> {{}};
  root = import (builtins.toPath {root_literal}) {{ inherit pkgs; }};
  packageSegments = builtins.fromJSON {segments_literal};
  package = builtins.foldl' (value: name: builtins.getAttr name value) root packageSegments;
  packageAttrs = if builtins.isAttrs package then package else {{}};
  rawPassthru = packageAttrs.passthru or {{}};
  passthru = if builtins.isAttrs rawPassthru then rawPassthru else {{}};
  lib = pkgs.lib;
in
{body}
"""


class NixEvaluator:
    def __init__(self, project_root):
        self.project_root = Path(project_root).resolve()
        self.root_nix_file = (self.project_root / "default.nix").resolve()
        self._package_cache = {}

    def eval(self, expression, description="Nix evaluation", *, cwd=None):
        command = [
            "nix",
            "eval",
            "--impure",
            "--show-trace",
            "--json",
            "--expr",
            expression,
        ]
        result = run_process(command, cwd=cwd or self.project_root, capture_output=True)
        if result.returncode != 0:
            raise RuntimeError(
                f"{description} failed (exit {result.returncode}):\n"
                f"{(result.stderr or '').strip()}"
            )
        try:
            return json.loads(result.stdout)
        except json.JSONDecodeError as exc:
            raise RuntimeError(
                f"{description} returned invalid JSON:\n{result.stdout}"
            ) from exc

    def list_packages(self):
        root_literal = nix_quote(self.root_nix_file)
        expression = f"""
let
  pkgs = import <nixpkgs> {{}};
  root = import (builtins.toPath {root_literal}) {{ inherit pkgs; }};
in
  builtins.attrNames root
"""
        result = self.eval(expression, "Package discovery")
        if not isinstance(result, list):
            raise RuntimeError("default.nix did not evaluate to an attribute set.")
        return result

    def get_package_data(self, pkg_name, *, refresh=False):
        cache_key = (str(self.root_nix_file), pkg_name)
        if not refresh and cache_key in self._package_cache:
            return self._package_cache[cache_key]

        # Normalizer distinguishes:
        #   1. derivation (nix run)
        #   2. { command, supportedFeatures, ... }
        #   3. legacy string / list (including experimental combinators)
        body = r"""
let
  packageAttrPath = builtins.concatStringsSep "." packageSegments;

  updateScript =
    if packageAttrs ? updateScript
    then packageAttrs.updateScript
    else (passthru.updateScript or null);

  rawAutoUpdate =
    if packageAttrs ? autoUpdate
    then packageAttrs.autoUpdate
    else (passthru.autoUpdate or true);

  rawUpdateArgs =
    if packageAttrs ? updateArgs
    then packageAttrs.updateArgs
    else (passthru.updateArgs or []);

  updateArgs =
    if rawUpdateArgs == null
    then []
    else map toString (lib.toList rawUpdateArgs);

  pname =
    if packageAttrs ? pname
    then toString packageAttrs.pname
    else if packageAttrs ? name
    then lib.getName (toString packageAttrs.name)
    else packageAttrPath;

  version =
    if packageAttrs ? version
    then toString packageAttrs.version
    else if packageAttrs ? name
    then lib.getVersion packageAttrs
    else "";

  name =
    if packageAttrs ? name
    then toString packageAttrs.name
    else if version != ""
    then pname + "-" + version
    else pname;

  isDerivationValue = value:
    builtins.isAttrs value && ((value.type or null) == "derivation");

  normalizeCommand = value:
    if value == null then [] else map toString (lib.toList value);

  referencedDerivations = strings:
    lib.unique (
      builtins.concatLists (
        map (s:
          builtins.filter (p: lib.hasSuffix ".drv" p)
            (builtins.attrNames (builtins.getContext s))
        ) strings
      )
    );

  stringsFromValue = value:
    if builtins.isString value then [ value ]
    else if builtins.isPath value then [ (toString value) ]
    else if builtins.isList value then builtins.concatLists (map stringsFromValue value)
    else if builtins.isAttrs value && value ? command then normalizeCommand value.command
    else [];

  normalizeLegacy = value:
    if value == null then null
    else if isDerivationValue value then {
      __kind = "nested-derivation";
      drvPath = toString value.drvPath;
      outPath = toString value;
    }
    else if builtins.isList value then map normalizeLegacy value
    else if builtins.isAttrs value && value ? command then {
      __kind = "command-step";
      command = normalizeCommand value.command;
      supportedFeatures =
        if value ? supportedFeatures && value.supportedFeatures != null
        then map toString (lib.toList value.supportedFeatures)
        else [];
      attrPath = toString (value.attrPath or packageAttrPath);
      commandDerivations = referencedDerivations (normalizeCommand value.command);
    }
    else if builtins.isAttrs value then {
      __kind = "unknown-attrs";
      keys = builtins.attrNames value;
    }
    else toString value;

  normalizedUpdateScript =
    if updateScript == null then null
    else if isDerivationValue updateScript then {
      kind = "derivation";
      isDerivation = true;
      attrPath = packageAttrPath;
      command = [];
      # Prefer explicit supportedFeatures on the derivation when present.
      supportedFeatures =
        if updateScript ? supportedFeatures && updateScript.supportedFeatures != null
        then map toString (lib.toList updateScript.supportedFeatures)
        else [];
      commandDerivations = [];
      scriptDerivations = [];
    }
    else if builtins.isAttrs updateScript && updateScript ? command then
      let command = normalizeCommand updateScript.command;
      in {
        kind = "command";
        isDerivation = false;
        inherit command;
        supportedFeatures =
          if updateScript ? supportedFeatures && updateScript.supportedFeatures != null
          then map toString (lib.toList updateScript.supportedFeatures)
          else [];
        attrPath = toString (updateScript.attrPath or packageAttrPath);
        commandDerivations = referencedDerivations command;
        scriptDerivations = [];
      }
    else {
      kind = "legacy";
      isDerivation = false;
      value = normalizeLegacy updateScript;
      attrPath = packageAttrPath;
      supportedFeatures = [];
      commandDerivations = [];
      scriptDerivations = referencedDerivations (stringsFromValue updateScript);
    };

  updateArgsDerivations = referencedDerivations updateArgs;

  src = packageAttrs.src or null;
  srcGitRepoUrl =
    if builtins.isAttrs src then (src.gitRepoUrl or null) else null;

in
{
  inherit name pname version updateArgs updateArgsDerivations srcGitRepoUrl;
  autoUpdate = rawAutoUpdate;
  hasUpdateScript = updateScript != null;
  updateScript = normalizedUpdateScript;
}
"""

        expression = make_package_eval_expr(
            pkg_name, body, root_nix_file=self.root_nix_file
        )
        result = self.eval(
            expression, f"Package evaluation for {pkg_name}", cwd=self.project_root
        )
        if not isinstance(result, dict):
            raise RuntimeError(f"Invalid package metadata for {pkg_name}: {result!r}")

        self._package_cache[cache_key] = result
        return result

    def get_package_version(self, pkg_name, *, project_root=None):
        project_root = Path(project_root or self.project_root).resolve()
        body = r"""
if packageAttrs ? version
then toString packageAttrs.version
else lib.getVersion package
"""
        return self.eval(
            make_package_eval_expr(
                pkg_name, body, root_nix_file=project_root / "default.nix"
            ),
            f"Version evaluation for {pkg_name}",
            cwd=project_root,
        )


# ============================================================================
# Package paths and update planning
# ============================================================================


def package_directory(project_root, pkg_name):
    project_root = Path(project_root).resolve()
    packages_root = (project_root / "pkgs").resolve()
    candidate = (packages_root / pkg_name).resolve()
    try:
        candidate.relative_to(packages_root)
    except ValueError as exc:
        raise RuntimeError(f"Invalid package path for {pkg_name!r}") from exc
    return candidate


@dataclass
class UpdatePlan:
    package: str
    package_data: dict
    script: object
    arguments: list
    method: str

    @property
    def features(self):
        if isinstance(self.script, dict):
            return set(self.script.get("supportedFeatures") or [])
        return set()


class UpdatePlanner:
    def build(self, pkg_name, package_data, extra_args=None):
        extra_args = list(extra_args or [])
        script = package_data.get("updateScript")
        arguments = list(package_data.get("updateArgs") or []) + extra_args
        method = "updateScript" if script is not None else "nix-update"
        return UpdatePlan(
            package=pkg_name,
            package_data=package_data,
            script=script,
            arguments=arguments,
            method=method,
        )


# ============================================================================
# Filesystem transaction
# ============================================================================


def path_exists(path):
    return Path(path).exists() or Path(path).is_symlink()


def remove_path(path):
    path = Path(path)
    if path.is_symlink() or path.is_file():
        path.unlink(missing_ok=True)
    elif path.is_dir():
        shutil.rmtree(path)


def copy_path(source, destination):
    source = Path(source)
    destination = Path(destination)
    destination.parent.mkdir(parents=True, exist_ok=True)
    if source.is_symlink():
        os.symlink(os.readlink(source), destination)
    elif source.is_dir():
        shutil.copytree(source, destination, symlinks=True)
    elif source.is_file():
        shutil.copy2(source, destination)
    else:
        raise RuntimeError(f"Cannot snapshot unsupported filesystem entry: {source}")


def path_fingerprint(path):
    path = Path(path)
    if not path_exists(path):
        return None
    if path.is_symlink():
        return ("symlink", os.readlink(path))
    info = path.stat()
    mode = stat.S_IMODE(info.st_mode)
    if path.is_file():
        digest = hashlib.sha256()
        with path.open("rb") as handle:
            for chunk in iter(lambda: handle.read(1024 * 1024), b""):
                digest.update(chunk)
        return ("file", mode, digest.hexdigest())
    if path.is_dir():
        children = []
        for child in sorted(path.iterdir(), key=lambda item: item.name):
            children.append((child.name, path_fingerprint(child)))
        return ("directory", mode, tuple(children))
    return ("other", mode, info.st_size)


class PackageTransaction:
    """Snapshot/restore of pkgs/<package> and package-scoped root artifacts.

    Captures untracked, ignored and hidden files. No Git commands are used.
    """

    def __init__(self, project_root, pkg_name, package_data):
        self.project_root = Path(project_root).resolve()
        self.pkg_name = pkg_name
        self.package_data = package_data
        self.package_dir = package_directory(self.project_root, pkg_name)
        self.backup_root = Path(tempfile.mkdtemp(prefix=f"update-{pkg_name}-snapshot-"))
        self.package_backup = self.backup_root / "package"
        self.package_existed = path_exists(self.package_dir)
        self.aux_backups = {}
        self.aux_original_paths = set()
        self.closed = False

        try:
            if self.package_existed:
                copy_path(self.package_dir, self.package_backup)
            self.aux_original_paths = set(self._find_auxiliary_artifacts())
            for index, source in enumerate(sorted(self.aux_original_paths, key=str)):
                backup = self.backup_root / "auxiliary" / str(index)
                copy_path(source, backup)
                self.aux_backups[source] = backup
            self.initial_package_fingerprint = path_fingerprint(self.package_dir)
            self.initial_aux_fingerprints = {
                path: path_fingerprint(path) for path in self.aux_original_paths
            }
        except Exception:
            shutil.rmtree(self.backup_root, ignore_errors=True)
            raise

    def _package_tokens(self):
        tokens = {self.pkg_name, str(self.package_data.get("pname") or "")}
        return {token for token in tokens if token}

    def _find_auxiliary_artifacts(self):
        if not self.project_root.is_dir():
            return []
        tokens = self._package_tokens()
        matches = []
        for path in self.project_root.iterdir():
            if not (path.is_file() or path.is_symlink()):
                continue
            if path.suffix not in UPDATE_ARTIFACT_SUFFIXES:
                continue
            if any(
                path.name.startswith(token + delimiter)
                for token in tokens
                for delimiter in (".", "-", "_")
            ):
                matches.append(path)
        return matches

    def package_changed(self):
        return path_fingerprint(self.package_dir) != self.initial_package_fingerprint

    def changed(self):
        if self.package_changed():
            return True
        current_aux = set(self._find_auxiliary_artifacts())
        all_paths = current_aux | self.aux_original_paths
        for path in all_paths:
            before = self.initial_aux_fingerprints.get(path)
            after = path_fingerprint(path)
            if before != after:
                return True
        return False

    def commit(self):
        if self.closed:
            return
        shutil.rmtree(self.backup_root, ignore_errors=True)
        self.closed = True

    def rollback(self):
        if self.closed:
            return
        if not self.changed():
            shutil.rmtree(self.backup_root, ignore_errors=True)
            self.closed = True
            return

        errors = []
        try:
            remove_path(self.package_dir)
            if self.package_existed:
                copy_path(self.package_backup, self.package_dir)
        except Exception as exc:
            errors.append(f"package directory restore failed: {exc}")

        try:
            current_aux = set(self._find_auxiliary_artifacts())
            for path in current_aux - self.aux_original_paths:
                remove_path(path)
            for path, backup in self.aux_backups.items():
                remove_path(path)
                copy_path(backup, path)
        except Exception as exc:
            errors.append(f"auxiliary artifact restore failed: {exc}")

        if errors:
            # Keep the snapshot so the only recovery copy is not lost.
            raise RuntimeError(
                "; ".join(errors) + f"; snapshot retained at {self.backup_root}"
            )
        shutil.rmtree(self.backup_root, ignore_errors=True)
        self.closed = True


# ============================================================================
# Update command execution
# ============================================================================


def make_update_environment(pkg_name, package_data, script):
    env = os.environ.copy()
    script = script if isinstance(script, dict) else {}
    env["UPDATE_NIX_NAME"] = str(package_data.get("name", pkg_name))
    env["UPDATE_NIX_PNAME"] = str(package_data.get("pname", pkg_name))
    env["UPDATE_NIX_OLD_VERSION"] = str(package_data.get("version", ""))
    env["UPDATE_NIX_ATTR_PATH"] = str(script.get("attrPath", pkg_name))
    return env


def rewrite_repo_path(argument, execution_root):
    argument = str(argument)
    old = str(REPO_ROOT.resolve())
    new = str(Path(execution_root).resolve())
    if argument == old:
        return new
    prefix = old + os.sep
    if argument.startswith(prefix):
        return new + argument[len(old) :]
    return argument


def patch_updater_url(command, package_data):
    """Fill unstableGitUpdater's empty --url= from package.src.gitRepoUrl."""
    url = package_data.get("srcGitRepoUrl")
    if not url:
        return list(command)
    return [f"--url={url}" if arg == "--url=" else arg for arg in command]


def package_working_directory(pkg_dir, command, script, execution_root):
    """Project root for store commands / updaters; package dir for local scripts."""
    command = list(command or [])
    script = script if isinstance(script, dict) else {}
    execution_root = Path(execution_root).resolve()

    if (
        script.get("commandDerivations")
        or script.get("scriptDerivations")
        or script.get("kind") == "derivation"
        or (command and str(command[0]).startswith("/nix/store/"))
    ):
        return execution_root

    cmd_joined = " ".join(str(c) for c in command)
    updater_markers = (
        "nix-instantiate",
        "import ./.",
        "unstableGitUpdater",
        "nix-update",
        "genericUpdater",
        "gitUpdater",
        "unstable-update-script",
    )
    if any(marker in cmd_joined for marker in updater_markers):
        return execution_root

    pkg_dir = Path(pkg_dir)
    if not pkg_dir.is_absolute():
        pkg_dir = execution_root / pkg_dir

    try:
        relative = pkg_dir.resolve().relative_to(execution_root)
        candidate = execution_root / relative
    except ValueError:
        return execution_root

    if candidate.is_dir():
        if (
            command
            and not str(command[0]).startswith("/")
            and (candidate / command[0]).exists()
        ):
            return candidate
        return candidate
    return execution_root


def is_poisoned(package_dir):
    default_nix = Path(package_dir) / "default.nix"
    if not default_nix.is_file():
        return False
    try:
        return MAGIC_PLACEHOLDER in default_nix.read_text(encoding="utf-8")
    except (OSError, UnicodeError):
        return False


class UpdateExecutor:
    def __init__(self, project_root, evaluator):
        self.project_root = Path(project_root).resolve()
        self.evaluator = evaluator

    def _run_argv(self, command, *, cwd, env, capture_output=True, execution_root=None):
        command = [str(arg) for arg in command]
        if not command:
            raise RuntimeError("Cannot execute an empty command.")

        result = run_process(command, cwd=cwd, env=env, capture_output=capture_output)
        if result.returncode != 0:
            if capture_output:
                if result.stdout and result.stdout.strip():
                    log(f"[SCRIPT STDOUT]:\n{result.stdout.rstrip()}")
                if result.stderr and result.stderr.strip():
                    log(f"[SCRIPT STDERR]:\n{result.stderr.rstrip()}")
            raise subprocess.CalledProcessError(
                result.returncode,
                command,
                output=(result.stdout or "") if capture_output else "",
                stderr=(result.stderr or "") if capture_output else "",
            )
        return CommandExecution(
            command=command,
            stdout=(result.stdout or "") if capture_output else "",
            stderr=(result.stderr or "") if capture_output else "",
            returncode=result.returncode,
        )

    def _realise_referenced_derivations(self, script, package_data, pkg_name):
        paths = []
        if isinstance(script, dict):
            paths.extend(script.get("commandDerivations") or [])
            paths.extend(script.get("scriptDerivations") or [])
        paths.extend(package_data.get("updateArgsDerivations") or [])
        paths = list(
            dict.fromkeys(
                str(path)
                for path in paths
                if str(path).startswith("/") and str(path).endswith(".drv")
            )
        )
        if not paths:
            return

        nix_store = shutil.which("nix-store")
        if not nix_store:
            raise RuntimeError(
                f"{pkg_name}: updateScript references derivations, "
                "but nix-store is not in PATH."
            )
        command = [nix_store, "--realise", *paths]
        log(f"[BUILD UPDATE SCRIPT] {pkg_name}: realising {len(paths)} derivation(s)")
        result = run_process(command, cwd=self.project_root, capture_output=True)
        if result.returncode != 0:
            raise RuntimeError(
                f"{pkg_name}: failed to build updateScript dependencies.\n"
                f"Command: {shlex.join(command)}\n"
                f"stdout:\n{result.stdout}\n"
                f"stderr:\n{result.stderr}"
            )

    def _looks_like_command_plus_args(self, step_list, package_dir):
        """Heuristic for [executable, arg, ...] vs sequential independent scripts.

        Prefers treating as a single command when the first element is a store
        path and subsequent elements look like flags. This matches the common
        expansion of unstableGitUpdater. True sequential combinators that
        start with a store-path script remain a residual risk.
        """
        if not step_list:
            return False

        first = str(step_list[0])
        if not first.startswith("/nix/store/"):
            candidate = Path(first)
            if not candidate.is_absolute():
                candidate = package_dir / candidate
            if not (candidate.is_file() or candidate.exists()):
                return False

        for item in step_list[1:]:
            s = str(item)
            if s.startswith("-"):
                continue
            candidate = Path(s)
            if not candidate.is_absolute():
                candidate = package_dir / candidate
            if candidate.is_file() and os.access(candidate, os.X_OK):
                return False
        return True

    def _run_derivation(self, plan, execution_root, *, capture_output):
        pkg_name = plan.package
        script = plan.script
        attr_path = str(script.get("attrPath") or pkg_name)

        command = [
            "nix",
            "run",
            f".#{attr_path}.passthru.updateScript",
            "--",
            *plan.arguments,
        ]
        env = make_update_environment(pkg_name, plan.package_data, script)
        log(f"[RUN UPDATE SCRIPT] {pkg_name}: {shlex.join(command)}")
        log(f"[RUN UPDATE SCRIPT] cwd={execution_root}")

        result = run_process(
            command, cwd=execution_root, env=env, capture_output=capture_output
        )
        if result.returncode != 0:
            if capture_output:
                if result.stdout and result.stdout.strip():
                    log(f"[SCRIPT STDOUT] {pkg_name}:\n{result.stdout.rstrip()}")
                if result.stderr and result.stderr.strip():
                    log(f"[SCRIPT STDERR] {pkg_name}:\n{result.stderr.rstrip()}")
            raise subprocess.CalledProcessError(
                result.returncode,
                command,
                output=(result.stdout or "") if capture_output else "",
                stderr=(result.stderr or "") if capture_output else "",
            )
        return UpdateExecution(
            commands=[command],
            stdout=(result.stdout or "") if capture_output else "",
            stderr=(result.stderr or "") if capture_output else "",
            returncode=result.returncode,
        )

    def _execute_command_descriptor(
        self, plan, script, execution_root, *, capture_output
    ):
        pkg_name = plan.package
        self._realise_referenced_derivations(script, plan.package_data, pkg_name)

        command = [str(arg) for arg in (script.get("command") or [])]
        command.extend(str(arg) for arg in plan.arguments)
        command = patch_updater_url(command, plan.package_data)
        command = [rewrite_repo_path(arg, execution_root) for arg in command]

        env = make_update_environment(pkg_name, plan.package_data, script)
        cwd = package_working_directory(
            package_directory(execution_root, pkg_name),
            command,
            script,
            execution_root,
        )
        log(f"[RUN UPDATE SCRIPT] {pkg_name}: {shlex.join(command)}")
        log(f"[RUN UPDATE SCRIPT] cwd={cwd}")
        result = self._run_argv(
            command,
            cwd=cwd,
            env=env,
            capture_output=capture_output,
            execution_root=execution_root,
        )
        return UpdateExecution(
            commands=[result.command],
            stdout=result.stdout,
            stderr=result.stderr,
            returncode=result.returncode,
        )

    def _execute_legacy_step(
        self,
        step,
        *,
        plan,
        package_dir,
        execution_root,
        env,
        commands,
        stdout_parts,
        stderr_parts,
        capture_output,
    ):
        pkg_name = plan.package

        if step is None:
            return

        if isinstance(step, list):
            if step and self._looks_like_command_plus_args(step, package_dir):
                # Preserve any features that might exist on the surrounding
                # script; individual string elements carry none.
                self._execute_legacy_step(
                    {
                        "__kind": "command-step",
                        "command": [str(x) for x in step],
                        "supportedFeatures": list(plan.features),
                        "attrPath": plan.package,
                        "commandDerivations": [],
                    },
                    plan=plan,
                    package_dir=package_dir,
                    execution_root=execution_root,
                    env=env,
                    commands=commands,
                    stdout_parts=stdout_parts,
                    stderr_parts=stderr_parts,
                    capture_output=capture_output,
                )
                return

            for child in step:
                self._execute_legacy_step(
                    child,
                    plan=plan,
                    package_dir=package_dir,
                    execution_root=execution_root,
                    env=env,
                    commands=commands,
                    stdout_parts=stdout_parts,
                    stderr_parts=stderr_parts,
                    capture_output=capture_output,
                )
            return

        if isinstance(step, dict):
            kind = step.get("__kind")
            if kind == "command-step" or "command" in step:
                self._realise_referenced_derivations(step, plan.package_data, pkg_name)
                command = [str(arg) for arg in (step.get("command") or [])]
                command.extend(str(arg) for arg in plan.arguments)
                command = patch_updater_url(command, plan.package_data)
                command = [rewrite_repo_path(arg, execution_root) for arg in command]
                cwd = package_working_directory(
                    package_dir, command, step, execution_root
                )
            elif kind == "unknown-attrs":
                raise RuntimeError(
                    f"{pkg_name}: unsupported updateScript attribute set; "
                    f"keys={step.get('keys', [])}"
                )
            elif kind == "nested-derivation":
                raise RuntimeError(
                    f"{pkg_name}: nested derivation inside a legacy updateScript "
                    "list is not supported. Expose it as top-level updateScript "
                    "or expand the combinator into sequential command descriptors."
                )
            else:
                raise RuntimeError(
                    f"{pkg_name}: unsupported legacy updateScript step: {step!r}"
                )

        elif isinstance(step, str):
            if "nix-update" in step:
                command = [
                    step,
                    pkg_name,
                    "-f",
                    str(Path(execution_root) / "default.nix"),
                    *[str(arg) for arg in plan.arguments],
                ]
                cwd = package_working_directory(
                    package_dir, command, {"kind": "legacy"}, execution_root
                )
            else:
                update_file = Path(step)
                if not update_file.is_absolute():
                    update_file = package_dir / update_file
                if not update_file.exists():
                    raise RuntimeError(
                        f"{pkg_name}: updateScript file does not exist: {update_file}"
                    )
                if update_file.is_dir():
                    raise RuntimeError(
                        f"{pkg_name}: updateScript points to a directory, "
                        f"not an executable file: {update_file}"
                    )
                command = [str(update_file), *[str(arg) for arg in plan.arguments]]
                if str(update_file).startswith("/nix/store/"):
                    cwd = Path(execution_root).resolve()
                else:
                    cwd = package_dir
        else:
            raise RuntimeError(
                f"{pkg_name}: unsupported updateScript step type: {type(step).__name__}"
            )

        log(f"[RUN UPDATE SCRIPT] {pkg_name}: {shlex.join(command)}")
        log(f"[RUN UPDATE SCRIPT] cwd={cwd}")
        result = self._run_argv(
            command,
            cwd=cwd,
            env=env,
            capture_output=capture_output,
            execution_root=execution_root,
        )
        commands.append(result.command)
        if result.stdout:
            stdout_parts.append(result.stdout)
        if result.stderr:
            stderr_parts.append(result.stderr)

    def _execute_legacy(self, plan, execution_root, *, capture_output):
        script = plan.script
        self._realise_referenced_derivations(script, plan.package_data, plan.package)
        package_dir = package_directory(execution_root, plan.package)
        env = make_update_environment(plan.package, plan.package_data, script)
        commands, stdout_parts, stderr_parts = [], [], []

        self._execute_legacy_step(
            script.get("value"),
            plan=plan,
            package_dir=package_dir,
            execution_root=execution_root,
            env=env,
            commands=commands,
            stdout_parts=stdout_parts,
            stderr_parts=stderr_parts,
            capture_output=capture_output,
        )
        return UpdateExecution(
            commands=commands,
            stdout="".join(stdout_parts),
            stderr="".join(stderr_parts),
            returncode=0,
        )

    def run_update_script(self, plan, *, execution_root=None):
        execution_root = Path(execution_root or self.project_root).resolve()
        script = plan.script
        if not isinstance(script, dict):
            raise RuntimeError(
                f"{plan.package}: invalid normalized updateScript metadata: {script!r}"
            )

        features = plan.features
        capture_output = FEATURE_COMMIT in features
        silent = FEATURE_SILENT in features

        kind = script.get("kind")
        if kind == "derivation":
            execution = self._run_derivation(
                plan, execution_root, capture_output=capture_output
            )
        elif kind == "command":
            execution = self._execute_command_descriptor(
                plan, script, execution_root, capture_output=capture_output
            )
        elif kind == "legacy":
            execution = self._execute_legacy(
                plan, execution_root, capture_output=capture_output
            )
        else:
            raise RuntimeError(f"{plan.package}: unknown updateScript kind: {kind!r}")

        if capture_output:
            if (
                not silent
                and FEATURE_COMMIT not in features
                and execution.stdout.strip()
            ):
                log(f"[SCRIPT STDOUT] {plan.package}:\n{execution.stdout.rstrip()}")
            if not silent and execution.stderr.strip():
                log(f"[SCRIPT STDERR] {plan.package}:\n{execution.stderr.rstrip()}")
        return execution

    def run_nix_update(self, plan, *, execution_root=None):
        execution_root = Path(execution_root or self.project_root).resolve()
        nix_update = shutil.which("nix-update")
        if not nix_update:
            raise RuntimeError("nix-update not found")

        command = [
            nix_update,
            plan.package,
            "-f",
            str(execution_root / "default.nix"),
            *[str(arg) for arg in plan.arguments],
        ]
        log(f"[NIX-UPDATE] Running: {shlex.join(command)}")
        result = run_process(command, cwd=execution_root, capture_output=False)
        if result.returncode != 0:
            raise subprocess.CalledProcessError(
                result.returncode, command, output="", stderr=""
            )
        return UpdateExecution(
            commands=[command], stdout="", stderr="", returncode=result.returncode
        )

    def execute_plan(self, plan, *, execution_root=None):
        if plan.script is not None:
            log(
                f"[UPDATE SCRIPT] {plan.package}: "
                f"running {plan.script.get('kind', 'unknown')} updateScript"
            )
            return self.run_update_script(plan, execution_root=execution_root)
        return self.run_nix_update(plan, execution_root=execution_root)


# ============================================================================
# Git helpers (commit mode only)
# ============================================================================


def git_run(args, *, cwd=None, check=True):
    command = ["git", *[str(arg) for arg in args]]
    result = run_process(command, cwd=cwd or REPO_ROOT, capture_output=True)
    if check and result.returncode != 0:
        raise RuntimeError(
            f"Git command failed: {shlex.join(command)}\n"
            f"stdout:\n{result.stdout}\n"
            f"stderr:\n{result.stderr}"
        )
    return result


def get_git_root(path=REPO_ROOT):
    result = git_run(["rev-parse", "--show-toplevel"], cwd=path, check=False)
    if result.returncode != 0:
        raise RuntimeError(f"{path} is not inside a Git repository.")
    return Path(result.stdout.strip()).resolve()


def get_git_head(path=REPO_ROOT):
    result = git_run(["rev-parse", "HEAD"], cwd=path, check=False)
    if result.returncode != 0:
        raise RuntimeError(f"Cannot determine Git HEAD in {path}.")
    return result.stdout.strip()


def ensure_clean_git_tree(path=REPO_ROOT):
    git_root = get_git_root(path)
    result = git_run(["status", "--porcelain", "--untracked-files=all"], cwd=git_root)
    if result.stdout.strip():
        raise RuntimeError(
            "The Git working tree must be clean when --commit is used.\n"
            "Commit or stash existing changes first.\n"
            f"{result.stdout}"
        )
    return git_root


def get_git_changed_files(path, base_commit):
    files = set()
    diff = git_run(["diff", "--name-only", "-z", base_commit], cwd=path, check=False)
    if diff.returncode == 0:
        files.update(item for item in diff.stdout.split("\0") if item)
    untracked = git_run(
        ["ls-files", "--others", "--exclude-standard", "-z"], cwd=path, check=False
    )
    if untracked.returncode == 0:
        files.update(item for item in untracked.stdout.split("\0") if item)
    return sorted(files)


def make_worktree(pkg_name):
    git_root = get_git_root(REPO_ROOT)
    base_commit = get_git_head(git_root)
    safe_name = "".join(
        char if char.isalnum() or char in "-_" else "-" for char in pkg_name
    )
    branch = f"update-{safe_name}-{uuid.uuid4().hex[:8]}"
    worktree = Path(tempfile.mkdtemp(prefix="nix-update-worktree-")).resolve()
    worktree.rmdir()
    try:
        git_run(
            ["worktree", "add", "-b", branch, str(worktree), base_commit],
            cwd=git_root,
        )
    except Exception:
        shutil.rmtree(worktree, ignore_errors=True)
        git_run(["branch", "-D", branch], cwd=git_root, check=False)
        raise
    return worktree, branch, base_commit, git_root


def remove_worktree(worktree, branch, git_root):
    git_run(["worktree", "remove", "--force", str(worktree)], cwd=git_root, check=False)
    git_run(["branch", "-D", branch], cwd=git_root, check=False)
    git_run(["worktree", "prune"], cwd=git_root, check=False)


def normalize_commit_file(path, *, worktree_root, project_root, git_root):
    if not str(path):
        raise RuntimeError("Commit metadata contains an empty file path.")

    candidate = Path(str(path))
    worktree_root = Path(worktree_root).resolve()
    project_root = Path(project_root).resolve()
    git_root = Path(git_root).resolve()

    if candidate.is_absolute():
        candidate = Path(os.path.normpath(str(candidate)))
        possible_bases = [worktree_root, project_root, REPO_ROOT.resolve()]
        relative = None
        for base in possible_bases:
            try:
                relative_to_base = candidate.relative_to(base)
            except ValueError:
                continue
            if base == worktree_root:
                relative = relative_to_base
            elif base == project_root:
                relative = project_root.relative_to(worktree_root) / relative_to_base
            else:
                project_relative = project_root.relative_to(worktree_root)
                relative = project_relative / relative_to_base
            break
        if relative is None:
            raise RuntimeError(f"Commit metadata path is outside the worktree: {path}")
    else:
        relative_input = Path(os.path.normpath(str(candidate)))
        if relative_input.is_absolute() or ".." in relative_input.parts:
            raise RuntimeError(f"Invalid path in commit metadata: {path}")
        project_candidate = project_root / relative_input
        worktree_candidate = worktree_root / relative_input
        project_relative = project_root.relative_to(worktree_root)
        if (
            project_relative != Path(".")
            and project_candidate.exists()
            and not worktree_candidate.exists()
        ):
            relative = project_relative / relative_input
        else:
            relative = relative_input

    normalized = Path(os.path.normpath(str(relative)))
    if normalized.is_absolute() or ".." in normalized.parts:
        raise RuntimeError(f"Invalid path in commit metadata: {path}")

    absolute = (worktree_root / normalized).resolve()
    try:
        absolute.relative_to(git_root)
    except ValueError as exc:
        raise RuntimeError(
            f"Commit metadata path is outside the Git repository: {path}"
        ) from exc
    return normalized.as_posix()


# ============================================================================
# Nixpkgs commit protocol
# ============================================================================


def parse_commit_output(stdout, pkg_name):
    try:
        changes = json.loads(stdout)
    except json.JSONDecodeError as exc:
        raise RuntimeError(
            f"{pkg_name}: commit feature requires JSON on stdout:\n{stdout}"
        ) from exc
    if isinstance(changes, dict):
        changes = [changes]
    if not isinstance(changes, list) or not all(
        isinstance(item, dict) for item in changes
    ):
        raise RuntimeError(
            f"{pkg_name}: commit-feature output must be a JSON list of objects."
        )
    return changes


def prepare_commit_changes(
    plan, execution, evaluator, *, worktree_root, base_commit, project_root, git_root
):
    pkg_name = plan.package
    commit_feature = FEATURE_COMMIT in plan.features
    changes = (
        parse_commit_output(execution.stdout, pkg_name) if commit_feature else [{}]
    )
    if not changes:
        return []

    if len(changes) == 1:
        change = changes[0]
        change.setdefault("attrPath", (plan.script or {}).get("attrPath", pkg_name))
        change.setdefault("oldVersion", plan.package_data.get("version", ""))
        if "newVersion" not in change:
            change["newVersion"] = evaluator.get_package_version(
                str(change["attrPath"]), project_root=project_root
            )
        if "files" not in change:
            change["files"] = get_git_changed_files(worktree_root, base_commit)
        if not change["files"]:
            return []

    prepared = []
    for index, original in enumerate(changes, start=1):
        change = dict(original)
        for key in ("attrPath", "oldVersion", "newVersion", "files"):
            if key not in change:
                raise RuntimeError(
                    f"{pkg_name}: change #{index} is missing required field {key!r}."
                )
        files = change["files"]
        if isinstance(files, str):
            files = [files]
        if not isinstance(files, list):
            raise RuntimeError(f"{pkg_name}: change #{index} 'files' must be a list.")
        normalized_files = [
            normalize_commit_file(
                item,
                worktree_root=worktree_root,
                project_root=project_root,
                git_root=git_root,
            )
            for item in files
        ]
        change["files"] = normalized_files
        if normalized_files:
            prepared.append(change)
    return prepared


def commit_changes_to_main(pkg_name, changes, worktree, branch, git_root):
    committed = []
    for change in changes:
        files = change["files"]
        if not files:
            continue
        git_run(["add", "--", *files], cwd=worktree)
        staged = git_run(["diff", "--cached", "--quiet"], cwd=worktree, check=False)
        if staged.returncode == 0:
            continue
        if staged.returncode != 1:
            raise RuntimeError(f"{pkg_name}: failed to inspect staged changes.")

        message = (
            f"{change['attrPath']}: {change['oldVersion']} -> {change['newVersion']}"
        )
        if "commitMessage" in change:
            message = str(change["commitMessage"])
        if change.get("commitBody"):
            message += "\n\n" + str(change["commitBody"])

        git_run(["commit", "--quiet", "-m", message], cwd=worktree)
        cherry_pick = git_run(["cherry-pick", branch], cwd=git_root, check=False)
        if cherry_pick.returncode != 0:
            raise RuntimeError(
                f"{pkg_name}: cherry-pick failed for {branch}.\n"
                f"{cherry_pick.stderr.strip()}"
            )
        committed.append(
            {
                "attrPath": change["attrPath"],
                "oldVersion": change["oldVersion"],
                "newVersion": change["newVersion"],
                "files": files,
                "commitMessage": message,
            }
        )

    remaining = get_git_changed_files(worktree, get_git_head(worktree))
    if remaining:
        raise RuntimeError(
            f"{pkg_name}: uncommitted worktree changes remain after processing "
            f"commit metadata: {remaining}"
        )
    return committed


class GitCommitCoordinator:
    def __init__(self, executor, evaluator):
        self.executor = executor
        self.evaluator = evaluator

    def run(self, plan):
        git_root = ensure_clean_git_tree(REPO_ROOT)
        original_head = get_git_head(git_root)
        worktree = None
        branch = None
        try:
            worktree, branch, base_commit, git_root = make_worktree(plan.package)
            project_relative = REPO_ROOT.resolve().relative_to(git_root)
            project_root = (worktree / project_relative).resolve()
            if not (project_root / "default.nix").is_file():
                raise RuntimeError(
                    f"Worktree is missing {project_root / 'default.nix'}"
                )

            package_dir = package_directory(project_root, plan.package)
            execution = self.executor.execute_plan(plan, execution_root=project_root)
            if is_poisoned(package_dir):
                raise RuntimeError(
                    f"{plan.package}: update left the magic temporary hash in default.nix"
                )

            existing_commits = git_run(
                ["rev-list", "--count", f"{base_commit}..HEAD"], cwd=worktree
            )
            if existing_commits.stdout.strip() != "0":
                raise RuntimeError(
                    f"{plan.package}: updateScript created Git commits itself; "
                    "commit-feature scripts must report changes as JSON instead."
                )

            changes = prepare_commit_changes(
                plan,
                execution,
                self.evaluator,
                worktree_root=worktree,
                base_commit=base_commit,
                project_root=project_root,
                git_root=git_root,
            )
            committed = commit_changes_to_main(
                plan.package, changes, worktree, branch, git_root
            )
            return {
                "changes": committed,
                "commits": len(committed),
                "files": sorted({path for item in committed for path in item["files"]}),
            }
        except Exception:
            git_run(["cherry-pick", "--abort"], cwd=git_root, check=False)
            current_head = get_git_head(git_root)
            if current_head != original_head:
                log(f"[ROLLBACK] Restoring commit-mode HEAD to {original_head}")
                git_run(["reset", "--hard", original_head], cwd=git_root)
            raise
        finally:
            if worktree is not None and branch is not None:
                remove_worktree(worktree, branch, git_root)


# ============================================================================
# Results and orchestration
# ============================================================================


class ResultCollector:
    def __init__(self):
        self.items = []

    def record(self, pkg_name, status, detail=None):
        if any(item["pkg"] == pkg_name for item in self.items):
            return
        item = {"pkg": pkg_name, "status": status}
        if detail is not None:
            item["detail"] = detail
        self.items.append(item)

    def summary(self, error=None):
        result = {
            "updated": sum(item["status"] == "updated" for item in self.items),
            "unchanged": sum(item["status"] == "unchanged" for item in self.items),
            "skipped": sum(item["status"] == "skipped" for item in self.items),
            "failed": sum(item["status"] == "failed" for item in self.items),
            "packages": self.items,
            "generated_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        }
        if error is not None:
            result["error"] = error
        return result

    def emit(self, error=None):
        result = self.summary(error)
        print(json.dumps(result, ensure_ascii=False))
        log(
            "[SUMMARY] "
            f"{result['updated']} updated / "
            f"{result['unchanged']} unchanged / "
            f"{result['skipped']} skipped / "
            f"{result['failed']} failed"
        )


class UpdateOrchestrator:
    def __init__(self, project_root):
        self.project_root = Path(project_root).resolve()
        self.evaluator = NixEvaluator(self.project_root)
        self.planner = UpdatePlanner()
        self.executor = UpdateExecutor(self.project_root, self.evaluator)
        self.commit_coordinator = GitCommitCoordinator(self.executor, self.evaluator)
        self.results = ResultCollector()

    def _record_failure(self, pkg_name, exc, rollback_error=None):
        if isinstance(exc, subprocess.CalledProcessError):
            message = format_command_failure(exc)
        else:
            message = f"{type(exc).__name__}: {exc}"
        if rollback_error:
            message += f"\nrollback error: {rollback_error}"
        log(f"[FAIL] {pkg_name}: {message}")
        self.results.record(pkg_name, "failed", message)

    def update_one(self, pkg_name, extra_args=None, *, commit=False):
        extra_args = list(extra_args or [])
        transaction = None
        try:
            package_data = self.evaluator.get_package_data(pkg_name)
            if package_data.get("autoUpdate") is False:
                log(f"[SKIP] {pkg_name}: passthru.autoUpdate = false")
                self.results.record(pkg_name, "skipped", "passthru.autoUpdate = false")
                return

            plan = self.planner.build(pkg_name, package_data, extra_args)
            features = sorted(plan.features)

            if commit:
                log(f"[COMMIT] {pkg_name}: using an isolated Git worktree")
                result = self.commit_coordinator.run(plan)
                status = "updated" if result["commits"] else "unchanged"
                self.results.record(
                    pkg_name,
                    status,
                    {"method": "worktree commit", "features": features, **result},
                )
                return

            transaction = PackageTransaction(self.project_root, pkg_name, package_data)
            execution = self.executor.execute_plan(
                plan, execution_root=self.project_root
            )

            pkg_dir = package_directory(self.project_root, pkg_name)
            if is_poisoned(pkg_dir):
                raise RuntimeError(
                    "updateScript left the magic temporary hash in default.nix; "
                    "the package snapshot will be restored."
                )

            package_changed = transaction.package_changed()
            any_changed = transaction.changed()
            transaction.commit()
            transaction = None

            status = "updated" if package_changed else "unchanged"
            detail = {
                "method": (
                    "updateScript derivation"
                    if plan.script and plan.script.get("kind") == "derivation"
                    else "updateScript"
                    if plan.script is not None
                    else "nix-update"
                ),
                "features": features,
                **execution.as_dict(),
            }
            if any_changed and not package_changed:
                detail["note"] = (
                    "Only a package-scoped auxiliary updater artifact changed; "
                    "package files are unchanged."
                )
            self.results.record(pkg_name, status, detail)
            log(f"[OK] {pkg_name}: {'updated' if status == 'updated' else 'unchanged'}")

        except Exception as exc:
            rollback_error = None
            if transaction is not None:
                try:
                    transaction.rollback()
                    log(
                        f"[ROLLBACK] {pkg_name}: restored the pre-update filesystem snapshot"
                    )
                except Exception as restore_exc:
                    rollback_error = str(restore_exc)
                    log(f"[ROLLBACK ERROR] {pkg_name}: {restore_exc}")
            if commit:
                log(
                    f"[FAIL] {pkg_name}: commit-mode changes were isolated in a worktree"
                )
            self._record_failure(pkg_name, exc, rollback_error)

    def run(self, package=None, extra_args=None, *, commit=False):
        try:
            packages = self.evaluator.list_packages()
        except Exception as exc:
            error = f"Package discovery failed: {type(exc).__name__}: {exc}"
            log(f"[ERROR] {error}")
            self.results.emit(error)
            return 1

        if not packages:
            error = "No packages found."
            log(f"[ERROR] {error}")
            self.results.emit(error)
            return 1

        if package:
            if package not in packages:
                log(f"[ERROR] Package {package} not found")
                self.results.record(package, "failed", "package not found in repo")
            else:
                self.update_one(package, extra_args, commit=commit)
        else:
            for pkg_name in packages:
                self.update_one(pkg_name, extra_args, commit=commit)

        self.results.emit()
        return (
            1 if any(item["status"] == "failed" for item in self.results.items) else 0
        )


# ============================================================================
# CLI
# ============================================================================


def main():
    parser = argparse.ArgumentParser(description="Update Nix packages")
    parser.add_argument("--package", help="Update a single package")
    parser.add_argument(
        "--commit",
        action="store_true",
        help="Run updates in an isolated Git worktree and create commits.",
    )
    parser.add_argument(
        "extra_args",
        nargs=argparse.REMAINDER,
        help="Additional arguments forwarded to update scripts; put them after --.",
    )
    args = parser.parse_args()
    extra_args = list(args.extra_args)
    if extra_args and extra_args[0] == "--":
        extra_args = extra_args[1:]

    if not ROOT_NIX_FILE.is_file():
        error = f"Cannot find {ROOT_NIX_FILE}"
        log(f"[ERROR] {error}")
        collector = ResultCollector()
        collector.emit(error)
        return 1

    orchestrator = UpdateOrchestrator(REPO_ROOT)
    return orchestrator.run(
        package=args.package, extra_args=extra_args, commit=args.commit
    )


if __name__ == "__main__":
    sys.exit(main())
