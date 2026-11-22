# openmpt-tracker

Built with upstream's own build: `msbuild` from `msvc-wine-toolchain` drives the
committed `build/vs2022win10/OpenMPT.vcxproj` and the projects it references,
which in turn run cl/lib/link/rc under Wine.

The toolchain carries the two things that build needs:

- `Microsoft.VisualStudio.Telemetry.dll` next to `MSBuild.exe`: the payload
  ships it with the compiler, but .NET only probes next to the executable, so
  without it MSBuild aborts at startup.
- ATL/MFC's `.rc` files healed from their mixed-endian UTF-16 into plain text:
  rc.exe reads them as UTF-16LE and otherwise stops with RC2255.

Properties the projects need against this toolchain live in `windows.nix`:
`PlatformToolset=v145` (the projects ask for v143), `WindowsTargetPlatformVersion`
`10.0.26100.0` (they ask for 10.0.22621.0), `WindowsSDKInstalled` and
`WindowsSDK_Desktop_Support` (the payload ships no UAP `DesignTime` props), and
`SpectreMitigation=false` (Spectre-mitigated libraries are a separate VS
component). `UseEnv=true` makes MSBuild take the wrapper's `INCLUDE`/`LIB`
instead of recomputing them, which is what leaves the UCRT out otherwise.

`update.sh` bumps the version and the source hash.
