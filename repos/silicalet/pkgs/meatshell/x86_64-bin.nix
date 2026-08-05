{
  lib,
  appimageTools,
  fetchurl,
  fontconfig,
  freetype,
  gtk3,
  libGL,
  libx11,
  libxcb,
  libxcursor,
  libxfixes,
  libxi,
  libxkbcommon,
  libxrandr,
  libxrender,
  nix-update-script,
  udev,
  wayland,
}:

appimageTools.wrapType2 rec {
  pname = "meatshell";
  version = "0.6.10";

  src = fetchurl {
    url = "https://github.com/yituorou/meatshell/releases/download/v${version}/meatshell-v${version}-linux-x86_64.AppImage";
    hash = "sha256-ARqGGFdYbDIW0f5VnnchGE5Zdulwnm3JwbuUsaB9SI4=";
  };

  extraPkgs = _: [
    fontconfig
    freetype
    gtk3
    libGL
    libx11
    libxcb
    libxcursor
    libxfixes
    libxi
    libxkbcommon
    libxrandr
    libxrender
    udev
    wayland
  ];

  extraInstallCommands =
    let
      contents = appimageTools.extractType2 {
        inherit pname version src;
      };
    in
    ''
      desktopFile="$(find ${contents} -path '*/share/applications/*.desktop' -print -quit)"
      if [ -n "$desktopFile" ]; then
        install -Dm444 "$desktopFile" "$out/share/applications/meatshell.desktop"
        sed -i \
          -e 's|^Exec=.*|Exec=meatshell|' \
          "$out/share/applications/meatshell.desktop"
      fi

      if [ -d ${contents}/usr/share/icons ]; then
        cp -r ${contents}/usr/share/icons "$out/share/"
      fi
    '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--use-github-releases" ];
  };

  meta = {
    description = "Lightweight FinalShell-style SSH and terminal client";
    homepage = "https://github.com/yituorou/meatshell";
    changelog = "https://github.com/yituorou/meatshell/releases/tag/v${version}";
    license = with lib.licenses; [
      mit
      asl20
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "meatshell";
    platforms = [ "x86_64-linux" ];
  };
}
