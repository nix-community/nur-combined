# openmpt-tracker: upstream's MSBuild, and why this package does not use it yet

Upstream builds the tracker from premake-generated project files with MSBuild.
That is the route this package wants, so the result of trying it is recorded
here.

Where it stands with the toolchain as shipped (MSBuild 18.12.3, toolset `v145`,
Windows SDK 10.0.26100.0):

- The stock `msbuild` wrapper dies with `TypeLoadException` on
  `Microsoft.VisualStudio.Telemetry`. The assembly is in the payload
  (`VC/Tools/MSVC/<ver>/bin/Hostx64/x64/`), just not next to `MSBuild.exe`
  where .NET probes for it. Copying it there makes MSBuild run.
- MSBuild then needs `/p:PlatformToolset=v145`
  (the projects ask for `v143`, which this payload does not carry),
  `/p:WindowsTargetPlatformVersion=10.0.26100.0` (the projects ask for
  `10.0.22621.0`), `/p:WindowsSDKInstalled=true` and
  `/p:WindowsSDK_Desktop_Support=true` (the SDK check looks for the UAP
  `DesignTime` props, which the payload does not ship), and
  `/p:SpectreMitigation=false` (no Spectre-mitigated libraries are installed).
- It compiles at that point, but its own include computation leaves the UCRT out
  (`Cannot open include file: 'stddef.h'`), and `rc.exe` still needs MFC's
  `.rc` files healed before the GUI resources build.

Each remaining piece belongs to the toolchain (ship the telemetry assembly next
to `MSBuild.exe`, fix the include set, heal ATL/MFC's resource scripts), not to
this package. Until that lands, `build.py` stands in for MSBuild: it executes
upstream's committed `.vcxproj` ItemDefinitionGroups through cl/lib/link/rc and
does not reimplement any of upstream's build logic.
