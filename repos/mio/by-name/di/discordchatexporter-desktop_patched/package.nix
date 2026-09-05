{
  lib,
  stdenv,
  discordchatexporter-desktop,
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

discordchatexporter-desktop.overrideAttrs (old: {
  pname = "discordchatexporter-desktop_patched";


  # Avoid wrapping Avalonia native dylibs as if they were CLI entry points.
  executables = [ "DiscordChatExporter" ];

  env = lib.optionalAttrs stdenv.hostPlatform.isLinux {
    XDG_CONFIG_HOME = "$HOME/.config";
  };

  patches = (old.patches or [ ]) ++ [ ./hidpi-scale.patch ];

  nativeBuildInputs =
    (old.nativeBuildInputs or [ ])
    ++ [
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

  postInstall =
    (old.postInstall or "")
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      install -Dm644 favicon.ico $out/share/icons/hicolor/256x256/apps/discordchatexporter.ico
    '';

  # On Darwin the Nix store is case-insensitive, so discordchatexporter collides
  # with DiscordChatExporter. Linux needs the lowercase alias for mainProgram.
  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    ln -s DiscordChatExporter $out/bin/discordchatexporter
  '';

  meta = (old.meta or { }) // {
    description = "Tool to export Discord chat logs to a file (GUI, HiDPI + Darwin)";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
})
