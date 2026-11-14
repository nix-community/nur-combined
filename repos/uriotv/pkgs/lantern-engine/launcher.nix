{ buildDotnetModule, dotnetCorePackages, lib, libGL, libx11, libxcursor, libxext, libxi, libxrandr, libice, libsm, src, version }:
buildDotnetModule {
  pname = "lantern-engine-launcher";
  inherit src version;
  projectFile = "launcher/windows/LanternLauncher/LanternLauncher.csproj";
  nugetDeps = ./deps.json;
  # Binary SDK/runtime: the source-built .NET 8 SDK at the current pin exceeds CI's time limit.
  # deps.json already pins every RID pack the offline restore needs, so keep the
  # binary SDK without its own target packs. Otherwise, whenever nixpkgs ships the
  # same .NET patch level as the lock, the SDK and the lock both provide the same
  # package id/version and configureNuget fails to link it twice into the fallback
  # folder ("ln: failed to create symbolic link ...: File exists").
  dotnet-sdk = dotnetCorePackages.sdk_8_0-bin // {
    packages = [ ];
  };
  dotnet-runtime = dotnetCorePackages.runtime_8_0-bin;
  # The engine is read-only; validate and log in BB_DATA_DIR / BB_OUT_DIR instead.
  patches = [ ./writable-data.patch ];
  # Nix owns updates: never replace the source-built engine with release binaries.
  postPatch = ''
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
  dotnetInstallFlags = [ "-p:AssemblyName=LanternEngine" "-p:Version=${version}" "-p:PublishAot=false" ];
  executables = [ "LanternEngine" ];
  runtimeDeps = [ libGL libx11 libxcursor libxext libxi libxrandr libice libsm ];
  meta.platforms = [ "x86_64-linux" ];
}
