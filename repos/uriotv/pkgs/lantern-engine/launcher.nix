{ buildDotnetModule, dotnetCorePackages, lib, libGL, libx11, libxcursor, libxext, libxi, libxrandr, libice, libsm, src, version }:
buildDotnetModule {
  pname = "lantern-engine-launcher";
  inherit src version;
  projectFile = "launcher/windows/LanternLauncher/LanternLauncher.csproj";
  nugetDeps = ./deps.json;
  # Binary SDK/runtime: the source-built .NET 8 SDK at the current pin exceeds CI's time limit.
  # deps.json must be exactly what `fetch-deps` writes: it leaves out every pack the
  # SDK already ships. A hand-kept lock that also pins those packs collides with the
  # SDK in configureNuget ("ln: failed to create symbolic link ...: File exists")
  # as soon as nixpkgs ships the same .NET patch level.
  dotnet-sdk = dotnetCorePackages.sdk_8_0-bin;
  dotnet-runtime = dotnetCorePackages.runtime_8_0-bin;
  # The engine is read-only; validate and log in BB_DATA_DIR / BB_OUT_DIR instead.
  patches = [ ./writable-data.patch ];
  # Nix owns updates: never replace the source-built engine with release binaries.
  postPatch = ''
    # fetch-deps runs with a fresh, writable $HOME. The first .NET 8 CLI call then
    # runs NuGet's one-time migration under a named mutex, and .NET 8 places named
    # mutex files under the passwd home directory, not $HOME. A systemd DynamicUser
    # (the CI runner) has home "/" on a read-only root, so the mutex cannot be
    # created ("The system cannot open the device or file specified :
    # 'NuGet-Migrations'"). The migration only fixes permissions of NuGet folders
    # from older releases, which a fresh $HOME does not have: mark it done so the
    # mutex is never needed. Sandbox builds have no writable $HOME and skip this.
    if [[ -w "$HOME" ]]; then
      mkdir -p "$HOME/.local/share/NuGet/Migrations"
      : > "$HOME/.local/share/NuGet/Migrations/1"
    fi
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
