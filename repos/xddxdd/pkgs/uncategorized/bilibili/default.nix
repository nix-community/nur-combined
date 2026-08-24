{
  fetchFromGitHub,
  fetchurl,
  nix-update-script,
  stdenv,
  electron,
  lib,
  makeWrapper,
}:
let
  bilibiliSrcSrc = fetchFromGitHub {
    owner = "msojocs";
    repo = "bilibili-linux";
    tag = "v1.18.0-1";
    hash = "sha256-JRXf1C587OWC5aIUfaf8YPjYlnGxGC1KIvzAXZmCtMg=";
  };

  res = "${bilibiliSrcSrc}/res";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "bilibili";
  version = "1.18.0-1";
  src = fetchurl {
    url = "https://github.com/msojocs/bilibili-linux/releases/download/v1.18.0-1/bilibili-asar-v1.18.0-1.tar.gz";
    hash = "sha256-t0l4R9toyvfZmKKIH/tZlQ5hln/BXR9hH9th1cmMJfk=";
  };
  buildInputs = [ makeWrapper ];

  sourceRoot = ".";

  postInstall = ''
    mkdir -p $out
    cp -r app $out/opt

    install -Dm644 ${res}/bilibili.desktop $out/share/applications/bilibili.desktop
    sed -i "s|Exec=.*|Exec=$out/bin/bilibili|" $out/share/applications/bilibili.desktop

    for FILE in ${res}/icons/*.png; do
      BASENAME=$(basename $FILE)
      SIZE=''${BASENAME%.png}
      install -Dm644 ${res}/icons/$SIZE.png $out/share/icons/hicolor/$SIZE/apps/bilibili.png
    done

    mkdir -p $out/bin
    makeWrapper ${lib.getExe electron} $out/bin/bilibili \
      --argv0 "bilibili" \
      --add-flags "$out/opt/app.asar" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--enable-features=UseOzonePlatform --ozone-platform=wayland}}"
  '';

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/msojocs/bilibili-linux/releases/tag/${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Desktop client for Bilibili";
    homepage = "https://app.bilibili.com/";
    license = lib.licenses.unfreeRedistributable;
    mainProgram = "bilibili";
  };
})
