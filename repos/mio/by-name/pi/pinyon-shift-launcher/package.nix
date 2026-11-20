{
  lib,
  stdenv,
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
  fontconfig,
  freetype,
  gtk3,
  libice,
  libsm,
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxrandr,
  libxrender,
  nix-update-script,
  zip,
}:

buildDotnetModule rec {
  pname = "pinyon-shift-launcher";
  version = "0.9.5";

  src = fetchFromGitHub {
    owner = "arcanite24";
    repo = "pinyon-shift";
    tag = "v${version}";
    hash = "sha256-0OcrJO0rM/PZfBeaPaqpCnW+GiQPJV9Hrye7mqK61z4=";
  };

  # The Windows launcher in ../PinyonShift.Launcher needs WPF; this is the
  # Avalonia one for Linux and macOS, which shares ../Shared with it.
  projectFile = "launcher/PinyonShift.Launcher.Desktop/PinyonShift.Launcher.Desktop.csproj";

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;

  nugetDeps = ./deps.json;

  # The project publishes a self-contained compressed single file for the
  # release zips. Keep the assemblies separate here so the launcher runs on the
  # nixpkgs runtime that the wrapper points at.
  dotnetFlags = [
    "/p:PublishSingleFile=false"
    "/p:EnableCompressionInSingleFile=false"
  ];

  executables = [ "PinyonShiftLauncher" ];

  nativeBuildInputs = [ zip ];

  # The launcher unpacks its source payload from pinyon-shift-source.zip, which
  # it looks for beside the assembly (or in Contents/Resources inside a macOS
  # bundle); the release zip ships one. Build the same archive from the
  # checkout so setup needs no separate download.
  postInstall = ''
    payload="$out/lib/$pname/pinyon-shift-source.zip"
    mkdir -p "$(dirname "$payload")"
    (cd ${src} && zip -qr "$payload" .)
  '';

  # Avalonia draws through X11/GTK on Linux and the bundled AppKit code on macOS.
  runtimeDeps = lib.optionals stdenv.hostPlatform.isLinux [
    fontconfig
    freetype
    gtk3
    libice
    libsm
    libx11
    libxcursor
    libxext
    libxi
    libxrandr
    libxrender
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Launcher that builds and runs Pinyon Shift from your own Forza Horizon disc";
    longDescription = ''
      Pinyon Shift recompiles the Xbox 360 release of Forza Horizon ahead of
      time and runs it natively, with no emulator. The game code has to be
      generated from a disc the player owns, so this package is the launcher
      only: point it at your own image, confirm ownership and it installs the
      build tools, generates and compiles the game in your home directory, then
      starts it. No game data is included in, or downloaded by, this package.
    '';
    homepage = "https://github.com/arcanite24/pinyon-shift";
    changelog = "https://github.com/arcanite24/pinyon-shift/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "PinyonShiftLauncher";
  };
}
