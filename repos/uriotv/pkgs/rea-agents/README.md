# REA

On **x86_64-linux**, `rea-agents` defaults to the complete bundled open-source
Linux toolchain. Runtime paths are set by the wrappers, not discovered through
`npx`, `pip`, or downloads when starting MCP. Explicit caller environment settings
can override the defaults.

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
./result/bin/rea-check       # read-only dependency smoke tests, also run during build
./result/bin/rea mcp
```

`rea-check` checks tool startup, audited dependency versions, plugin loading and
JAR presence. It is not an end-to-end test of every analysis operation. In
particular, Chromium `--version` does not prove browser rendering or sandbox
availability on the host. REA never disables the Chromium sandbox automatically.

The NativeAOT extension is installed but deliberately not enabled in the generic
MCP process: REA rejects unrelated binary targets when that extension is enabled.
Use `rea-nativeaot` / `rea-nativeaot mcp` for that workflow, or explicitly select
the JAR using `REA_GHIDRA_NATIVEAOT_JAR`. The built-in PE NativeAOT snapshot parser
remains available in the generic process without this optional extension.

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

The full bundle currently targets x86_64-linux. Other supported hosts retain the
Ghidra/JDK variant. Overrides allow an intentionally smaller package:

```nix
# Ghidra/JDK only, without the extended Linux toolchain:
rea-agents.override { withFullTools = false; }
# CLI/MCP only, with externally managed analysis providers:
rea-agents.override { withFullTools = false; withGhidra = false; }
```

To consume a changed package, update the urio-nur flake input, activate the
consumer's configuration and restart its MCP process. The generic MCP command
remains `rea mcp`.
