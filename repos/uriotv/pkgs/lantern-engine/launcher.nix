{ buildDotnetModule, dotnetCorePackages, lib, libGL, libx11, libxcursor, libxext, libxi, libxrandr, libice, libsm, src, version }:
buildDotnetModule {
  pname = "lantern-engine-launcher";
  inherit src version;
  projectFile = "launcher/windows/LanternLauncher/LanternLauncher.csproj";
  nugetDeps = ./deps.json;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;
  # The engine is read-only; validate and log in BB_DATA_DIR / BB_OUT_DIR instead.
  patches = [ ./writable-data.patch ];
  # Nix owns updates: never replace the source-built engine with release binaries.
  postPatch = ''
    substituteInPlace launcher/windows/LanternLauncher/{Program.cs,Views/DiscordPreview.cs,Views/Symbols.cs} \
      --replace-fail 'avares://Lantern Engine/' 'avares://LanternEngine/'
    substituteInPlace launcher/windows/LanternLauncher/MainWindow.cs \
      --replace-fail 'Title = "Lantern Engine";' 'Title = "Nix build based on Lantern Engine";' \
      --replace-fail 'new Run("Lantern Engine")' 'new Run("Nix build based on Lantern Engine")'
    substituteInPlace launcher/windows/LanternLauncher/Views/EnginePage.cs \
      --replace-fail 'Lantern Engine by Awaken (github.com/Awakenchan/LanternEngine).' \
        'Modified Nix build, based on Lantern Engine by Awaken (https://github.com/Awakenchan/LanternEngine).'
    substituteInPlace launcher/windows/BloodborneLauncher/Core/Updater.cs \
      --replace-fail 'public static bool Supported => OperatingSystem.IsWindows() || OperatingSystem.IsLinux();' \
        'public static bool Supported => false;'
  '';
  dotnetBuildFlags = [ "-p:AssemblyName=LanternEngine" "-p:Version=${version}" ];
  dotnetInstallFlags = [ "-p:AssemblyName=LanternEngine" "-p:Version=${version}" ];
  executables = [ "LanternEngine" ];
  runtimeDeps = [ libGL libx11 libxcursor libxext libxi libxrandr libice libsm ];
  meta.platforms = [ "x86_64-linux" ];
}
