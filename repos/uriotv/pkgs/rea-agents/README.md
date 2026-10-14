# REA

The default `rea-agents` package is the bare REA CLI/MCP server: it does not
install or configure Ghidra or the optional analysis toolchain. Use the exported
Home Manager module `urio-nur.homeModules.rea` to enable REA and optionally add
Ghidra to the user's profile and configure its REA environment.

On **x86_64-linux**, an opt-in `withFullTools` package variant bundles the open-source
Linux analysis toolchain. Runtime paths are set by the wrappers, not discovered
through `npx`, `pip`, or downloads when starting MCP. Explicit caller environment
settings can override the defaults.

| Area | Bundled tools |
| --- | --- |
| Native decompilation | Ghidra 12.1.x and full JDK 21 |
| .NET assemblies | ILSpy CLI and its Nix-managed .NET runtime |
| Android static analysis | jadx-headless-mcp 0.7.1 JAR and Apktool |
| Android devices | ADB (android-tools); a connected device is still required |
| Browser automation | Chromium; the matching Playwright client is in REA's npm dependencies |
| ELF/crash analysis | Python 3.13 with pwntools 4.15.0, pyelftools 0.33 and Unicorn 2.1.2 |
| Optional debugger context | pwndbg 2026.09.15 with its bundled GDB/Python/dependencies |
| Firmware | Binwalk 3.1.x, Unblob 26.6.x with its extraction dependencies |
| Captured traffic | mitmdump 12.2.3 (HAR parsing needs no separate tool) |
| JavaScript recovery | Wakaru 1.14.0 |
| Resource limiting | util-linux prlimit (explicit paths, not `/usr/bin/prlimit`) |
| Optional NativeAOT recovery | Pinned ghidra-nativeaot source and REA facade, compiled against the bundled Ghidra |

```bash
nix build .#rea-agents
./result/bin/rea --version
./result/bin/rea mcp
```

The optional full-toolchain variant provides `rea-check`, which checks tool
startup, audited dependency versions, plugin loading and JAR presence. It is not
an end-to-end test of every analysis operation. In particular, Chromium
`--version` does not prove browser rendering or sandbox availability on the host.
REA never disables the Chromium sandbox automatically.

Home Manager usage:

```nix
{
  imports = [ urio-nur.homeModules.rea ];
  programs.rea = {
    enable = true;
    ghidra.enable = true; # independent Ghidra option
    freeTools.enable = true; # all supported free tools except Ghidra
    # freeTools.chromium.enable = false; # override one tool in the bundle
    # ghidra.package = pkgs.ghidra; # default
  };
}
```

With `programs.rea.ghidra.enable`, `ghidra` is available on the user's `PATH`,
and Home Manager sets `GHIDRA_INSTALL_DIR`, `JAVA_HOME`, and
`REA_ANALYSIS_PROVIDER` for REA. `programs.rea.freeTools.enable` enables the
supported free integrations from the Nix bundle; each has its own
`programs.rea.freeTools.<name>.enable` switch: `chromium`, `androidTools`,
`apktool`, `jadx`, `ilspycmd`, `binwalk`, `unblob`, `mitmproxy`, `wakaru`,
`pwntools`, `pwndbg`, and `prlimit`. Individual switches default to the value of
`freeTools.enable`, so they can be overridden independently. Ghidra is excluded
from that group and remains controlled by `programs.rea.ghidra.enable`.

The all-tools bundle is supported on x86_64-linux; Wakaru, pwntools and pwndbg
are restricted to that platform. JADX and Ghidra add JDK 21 as a dependency.
`pwndbg` also enables its pwntools Python environment, and firmware/JavaScript
tools bring in `prlimit` when needed. Playwright is already part of REA's npm
dependencies, so it has no separate package switch. The pinned REA 6.4.0
release does not yet consume Rizin or GNU objdump; these are intentionally not
exposed as install-only “REA” options. This is a per-user profile, not a
system-wide NixOS installation.

In the optional full-toolchain variant, the NativeAOT extension is installed but
deliberately not enabled in the generic MCP process: REA rejects unrelated binary
targets when that extension is enabled. Use `rea-nativeaot` / `rea-nativeaot mcp`
for that workflow, or explicitly select the JAR using
`REA_GHIDRA_NATIVEAOT_JAR`. The built-in PE NativeAOT snapshot parser remains
available in the generic process without this optional extension.

## Scope and external requirements

This is the open-source toolchain supported on Linux, not a claim that every REA
capability works on every host or target:

- **Hopper, IDA and JEB** require separately obtained licensed installations and,
  for IDA/JEB, their working MCP registrations/endpoints. They are alternative
  providers, not prerequisites of Ghidra.
- Native Apple UI/tracing workflows need **macOS and Apple developer tools**.
  Windows-specific runtime authority needs **Windows**. A NixOS package cannot
  provide those host capabilities.
- Device/browser/process attachments still require caller-selected targets,
  permitted debugging endpoints and applicable host permissions.
- REA pins some engines to exact versions/release lines. Updating REA requires
  reviewing `runtime-tools.nix`, the NativeAOT facade revision and smoke tests,
  not just updating its npm hashes. Python environments for pwntools, pwndbg and
  Unblob are deliberately separate because their dependency versions conflict.

The full bundle currently targets x86_64-linux. Other supported hosts can use
the bare CLI or the separate Ghidra/JDK variant. Overrides allow an intentionally
smaller package:

```nix
# Ghidra/JDK only, without the extended Linux toolchain:
# CLI/MCP only, with externally managed analysis providers (also the default):
rea-agents.override { withFullTools = false; withGhidra = false; }
# Ghidra/JDK only:
rea-agents.override { withFullTools = false; withGhidra = true; }
# Full Linux toolchain, including Ghidra/JDK:
rea-agents.override { withFullTools = true; withGhidra = true; }
```

To consume a changed package, update the urio-nur flake input, activate the
consumer's configuration and restart its MCP process. The generic MCP command
remains `rea mcp`.
