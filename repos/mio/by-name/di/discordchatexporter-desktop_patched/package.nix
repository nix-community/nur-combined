# Vendored from nixpkgs 044bfe75bfe4 (2026-08-14). See README.md.
{
  lib,
  stdenv,
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
  makeDesktopItem,
  copyDesktopItems,
  desktopToDarwinBundle,
  fontconfig,
  libICE,
  libSM,
  libX11,
  libXcursor,
  libXext,
  libXi,
  libXrandr,
}:

buildDotnetModule (finalAttrs: {
  pname = "discordchatexporter-desktop_patched";
  version = "2.47.3";

  src = fetchFromGitHub {
    owner = "tyrrrz";
    repo = "discordchatexporter";
    tag = finalAttrs.version;
    hash = "sha256-B/2krGBYp/6qgINRyX/38tHlEy9JxmQMAIPsDNjZF5k=";
  };

  projectFile = "DiscordChatExporter.Gui/DiscordChatExporter.Gui.csproj";
  nugetDeps = ./deps.json;
  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;
  # Avoid wrapping Avalonia native dylibs as if they were CLI entry points.
  executables = [ "DiscordChatExporter" ];

  # Same csharpier workaround as nixpkgs discordchatexporter-cli.
  dotnetBuildFlags = [
    "-p:FirstTargetFrameworks=workaround-for-csharpier-pr-1696"
  ];

  env = lib.optionalAttrs stdenv.hostPlatform.isLinux {
    XDG_CONFIG_HOME = "$HOME/.config";
  };

  patches = [
    ./settings-path.patch
    ./hidpi-scale.patch
  ];

  nativeBuildInputs = [
    copyDesktopItems
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ desktopToDarwinBundle ];

  runtimeDeps = lib.optionals stdenv.hostPlatform.isLinux [
    fontconfig
    libICE
    libSM
    libX11
    libXcursor
    libXext
    libXi
    libXrandr
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "discordchatexporter";
      desktopName = "DiscordChatExporter";
      comment = "Export Discord chat logs";
      exec = "DiscordChatExporter";
      icon = "discordchatexporter";
      categories = [
        "Network"
        "Utility"
      ];
      startupWMClass = "DiscordChatExporter";
    })
  ];

  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    install -Dm644 favicon.ico $out/share/icons/hicolor/256x256/apps/discordchatexporter.ico
  '';

  # On Darwin the Nix store is case-insensitive, so discordchatexporter collides
  # with DiscordChatExporter. Linux needs the lowercase alias for mainProgram.
  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    ln -s DiscordChatExporter $out/bin/discordchatexporter
  '';

  passthru.updateScript = ./updater.sh;

  meta = {
    changelog = "https://github.com/Tyrrrz/DiscordChatExporter/releases/tag/${finalAttrs.version}";
    description = "Tool to export Discord chat logs to a file (GUI, HiDPI + Darwin)";
    homepage = "https://github.com/Tyrrrz/DiscordChatExporter";
    license = lib.licenses.gpl3Plus;
    mainProgram = "discordchatexporter";
    maintainers = with lib.maintainers; [
      phanirithvij
      willow
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
})
