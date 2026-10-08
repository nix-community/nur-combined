#!/usr/bin/env python3
"""Update NUR packages and print build and test results as JSON."""

import argparse
import hashlib
import json
import os
import shlex
import subprocess
import sys
from contextlib import ExitStack
from pathlib import Path


class CommandFailed(Exception):
    def __init__(self, result):
        self.result = result
        super().__init__(
            result.get("error", f"Command exited with {result['exitCode']}")
        )


class Runner:
    def __init__(self, repo):
        self.repo = repo
        self.logs = repo / ".update-results"
        self.logs.mkdir(exist_ok=True)
        self.env = os.environ | {
            "NIXPKGS_ALLOW_UNFREE": "1",
            "PYTHONUNBUFFERED": "1",
        }

    def run(self, command, log_name, env=None, stdout_path=None):
        log = self.logs / f"{log_name}.log"
        result = {"command": command, "log": str(log), "exitCode": None}
        with ExitStack() as files:
            output = files.enter_context(log.open("w"))
            stdout = (
                files.enter_context(stdout_path.open("w"))
                if stdout_path
                else subprocess.PIPE
            )

            def log_output(line):
                output.write(line)
                output.flush()
                print(line, end="", file=sys.stderr, flush=True)

            log_output(f"[{log_name}] $ {shlex.join(command)}\n")
            try:
                with subprocess.Popen(
                    command,
                    cwd=self.repo,
                    env=self.env | (env or {}),
                    stdin=subprocess.DEVNULL,
                    stdout=stdout,
                    stderr=subprocess.PIPE if stdout_path else subprocess.STDOUT,
                    text=True,
                ) as process:
                    stream = process.stderr if stdout_path else process.stdout
                    for line in stream:
                        log_output(line)
                    result["exitCode"] = process.wait()
            except OSError as error:
                result["error"] = str(error)
                log_output(f"[{log_name}] {error}\n")
            result["status"] = "passed" if result["exitCode"] == 0 else "failed"
            log_output(f"[{log_name}] {result['status']} (exit {result['exitCode']})\n")
        if result["status"] == "failed":
            raise CommandFailed(result)
        return result


def snapshot(repo):
    return {
        str(path.relative_to(repo)): hashlib.sha256(path.read_bytes()).hexdigest()
        for path in (repo / "pkgs").rglob("*.nix")
        if path.is_file()
    }


def changed_files(before, after):
    return sorted(
        name
        for name in before.keys() | after.keys()
        if before.get(name) != after.get(name)
    )


def read_metadata(runner, log_name, attribute="inventory"):
    json_path = runner.logs / f"{log_name}.json"
    result = runner.run(
        [
            "nix-instantiate",
            "--eval",
            "--read-write-mode",
            "--strict",
            "--json",
            "update.nix",
            "-A",
            attribute,
        ],
        log_name,
        stdout_path=json_path,
    )
    return json.loads(json_path.read_text()), result


def update_package(runner, name, explicit, failed_builds):
    result = {
        "package": name,
        "status": "failed",
        "oldVersion": None,
        "newVersion": None,
        "changelog": None,
        "compare": None,
        "changedFiles": [],
        "steps": {},
        "tests": {},
    }
    before = snapshot(runner.repo)
    stage = "evaluateBefore"
    try:
        info, evaluated = read_metadata(
            runner, f"{name}-before", f"inventory.packages.{json.dumps(name)}"
        )
        result["steps"][stage] = evaluated
        result["oldVersion"] = info["version"]
        if not info["updatable"]:
            reason = (
                "Package is not buildable on the current system"
                if not info["buildable"]
                else "Package needs a GitHub source or an updateScript"
            )
            if explicit:
                result.update(failedStage="eligibility", error=reason)
            else:
                result.update(status="skipped", reason=reason)
            return result

        if info["hasUpdateScript"]:
            stage = "prepare"
            script_path = runner.logs / f"{name}-script-path"
            result["steps"][stage] = runner.run(
                [
                    "nix-build",
                    "update.nix",
                    "-A",
                    f"scripts.{json.dumps(name)}",
                    "--no-out-link",
                ],
                f"{name}-prepare",
                stdout_path=script_path,
            )
            command = [script_path.read_text().strip()]
        else:
            command = ["nix-update", name]
            if "-unstable-" in info["version"]:
                command.append("--version=branch")

        stage = "update"
        result["steps"][stage] = runner.run(
            command,
            f"{name}-update",
            {
                "UPDATE_NIX_ATTR_PATH": name,
                "UPDATE_NIX_NAME": info["name"],
                "UPDATE_NIX_PNAME": info["pname"],
                "UPDATE_NIX_OLD_VERSION": info["version"],
            },
        )
        result["changedFiles"] = changed_files(before, snapshot(runner.repo))
        stage = "evaluate"
        updated, evaluated = read_metadata(
            runner, f"{name}-evaluate", f"inventory.packages.{json.dumps(name)}"
        )
        result["steps"][stage] = evaluated
        result["newVersion"] = updated["version"]
        result["changelog"] = updated["changelog"]
        old_source = info["githubSource"]
        new_source = updated["githubSource"]
        if (
            "-unstable-" in updated["version"]
            and old_source
            and new_source
            and old_source["url"] == new_source["url"]
            and old_source["rev"] != new_source["rev"]
        ):
            result["compare"] = (
                f"{new_source['url']}/compare/"
                f"{old_source['rev']}...{new_source['rev']}"
            )
        if not result["changedFiles"]:
            result["status"] = "unchanged"
            return result

        stage = "evaluateDerivations"
        derivations, evaluated = read_metadata(
            runner, f"{name}-derivations", f"derivations.{json.dumps(name)}"
        )
        result["steps"][stage] = evaluated
        result["derivations"] = derivations
        failure = failed_builds.get(name)
        if failure and failure["derivations"] == derivations:
            result.update(
                status="skipped",
                reason="Build and test derivations match a previous failure",
                failureIssue=failure["issueUrl"],
            )
            print(
                f"{name}: skipping build and tests ({result['failureIssue']})",
                file=sys.stderr,
                flush=True,
            )
            return result

        stage = "build"
        result["steps"][stage] = runner.run(
            ["nix-build", "default.nix", "-A", json.dumps(name), "--no-out-link"],
            f"{name}-build",
        )
        stage = "tests"
        for index, test in enumerate(updated["tests"]):
            try:
                result["tests"][test] = runner.run(
                    [
                        "nix-build",
                        "update.nix",
                        "-A",
                        f"tests.{json.dumps(name)}.{json.dumps(test)}",
                        "--no-out-link",
                    ],
                    f"{name}-test-{index}",
                )
            except CommandFailed as error:
                result["tests"][test] = error.result
        if any(test["status"] == "failed" for test in result["tests"].values()):
            result["failedStage"] = stage
        else:
            result["status"] = "updated"
    except CommandFailed as error:
        result["steps"][stage] = error.result
        result["failedStage"] = stage
        result["changedFiles"] = changed_files(before, snapshot(runner.repo))
    except (OSError, ValueError) as error:
        result["error"] = str(error)
        result["failedStage"] = stage
        result["changedFiles"] = changed_files(before, snapshot(runner.repo))
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "packages", nargs="*", help="Package attributes; omit to update all"
    )
    parser.add_argument(
        "--list", action="store_true", help="List packages and update eligibility"
    )
    parser.add_argument(
        "--failed-builds",
        type=Path,
        help="JSON file of previous failures; skip matching build and test derivations",
    )
    args = parser.parse_args()
    report = {"schemaVersion": 1, "results": []}
    try:
        failed_builds = (
            json.loads(args.failed_builds.read_text()) if args.failed_builds else {}
        )
        if not isinstance(failed_builds, dict) or any(
            not isinstance(failure, dict)
            or not isinstance(failure.get("derivations"), dict)
            or not isinstance(failure.get("issueUrl"), str)
            for failure in failed_builds.values()
        ):
            raise ValueError("Expected a package map with derivations and issueUrl")
        runner = Runner(Path.cwd())
        inventory, discovery = read_metadata(runner, "discovery")
        report["system"] = inventory["system"]
        report["discovery"] = discovery
        packages = inventory["packages"]
        names = (
            list(dict.fromkeys(args.packages)) if args.packages else sorted(packages)
        )
        unknown = sorted(set(names) - packages.keys())
        if unknown:
            report["error"] = f"Unknown packages: {', '.join(unknown)}"
        elif args.list:
            report["packages"] = {name: packages[name] for name in names}
        else:
            for name in names:
                print(f"Processing {name}", file=sys.stderr, flush=True)
                result = update_package(
                    runner, name, bool(args.packages), failed_builds
                )
                report["results"].append(result)
                print(f"{name}: {result['status']}", file=sys.stderr, flush=True)
    except CommandFailed as error:
        report["discovery"] = error.result
        report["error"] = str(error)
    except (OSError, ValueError) as error:
        report["error"] = str(error)

    report["success"] = "error" not in report and all(
        result["status"] != "failed" for result in report["results"]
    )
    print(json.dumps(report, indent=2))
    return 0 if report["success"] else 1


if __name__ == "__main__":
    sys.exit(main())
