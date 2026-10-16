import * as path from "@std/path";
import { nix, provider, runCommand, type SourceDefinition } from "nix-repin";

// Read flake.lock directly; getFlake would copy the whole worktree into the store.
async function build(
  packageDirectory: string,
  attribute: string,
): Promise<string> {
  const root = await nix.findFlakeRoot(packageDirectory);
  const output = await runCommand("nix", [
    "build",
    "--expr",
    `let
  lock = builtins.fromJSON (builtins.readFile ${
      nix.string(`${root}/flake.lock`)
    });
  pkgs = import (builtins.fetchTree lock.nodes.nixpkgs.locked) {};
  gomod2nix = import ${nix.string(`${root}/internal/gomod2nix.nix`)};
in
(pkgs.extend (import (gomod2nix + "/overlay.nix"))).${attribute}`,
    "--impure",
    "--json",
    "--no-link",
  ]);
  const [result] = JSON.parse(output) as { outputs: Record<string, string> }[];

  return result.outputs.out;
}

async function copyTree(from: string, to: string): Promise<void> {
  for await (const entry of Deno.readDir(from)) {
    const source = path.join(from, entry.name);
    const target = path.join(to, entry.name);
    if (entry.isSymlink) {
      await Deno.symlink(await Deno.readLink(source), target);
    } else if (entry.isDirectory) {
      await Deno.mkdir(target);
      await copyTree(source, target);
    } else {
      await Deno.copyFile(source, target);
      await Deno.chmod(target, (await Deno.stat(target)).mode! | 0o200);
    }
  }
}

/** Generate Cargo.nix from an archive source, optionally for a manifest below its root. */
export function crate2nix(
  options: { manifest?: string } = {},
): SourceDefinition {
  return provider(async (source) => {
    const tools = await Promise.all([
      build(source.packageDirectory, "crate2nix"),
      build(source.packageDirectory, "cargo"),
    ]);
    const directory = await Deno.makeTempDir({ prefix: "crate2nix-" });
    try {
      await copyTree(source.sourceFile("."), directory);
      const shell = (...command: string[]) =>
        runCommand("nix", ["shell", ...tools, "-c", ...command], {
          cwd: directory,
        });
      // crate2nix runs cargo metadata with --locked, so let cargo reconcile a stale upstream Cargo.lock first.
      await shell(
        "cargo",
        "metadata",
        "--format-version",
        "1",
        ...(options.manifest ? ["--manifest-path", options.manifest] : []),
      );
      await shell(
        "crate2nix",
        "generate",
        ...(options.manifest ? ["-f", options.manifest] : []),
      );

      return {
        "Cargo.nix": await Deno.readTextFile(path.join(directory, "Cargo.nix")),
      };
    } finally {
      await Deno.remove(directory, { recursive: true });
    }
  });
}

/** Generate gomod2nix.toml, including the dependency cache list, from an archive source. */
export function gomod2nix(): SourceDefinition {
  return provider(async (source) => {
    const tool = await build(source.packageDirectory, "gomod2nix");
    const directory = await Deno.makeTempDir({ prefix: "gomod2nix-" });
    try {
      await runCommand("nix", [
        "shell",
        tool,
        "-c",
        "gomod2nix",
        "generate",
        "--with-deps",
        "--dir",
        source.sourceFile("."),
        "--outdir",
        directory,
      ]);

      return {
        "gomod2nix.toml": await Deno.readTextFile(
          path.join(directory, "gomod2nix.toml"),
        ),
      };
    } finally {
      await Deno.remove(directory, { recursive: true });
    }
  });
}
