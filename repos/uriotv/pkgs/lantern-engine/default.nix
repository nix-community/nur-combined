{ lib, stdenvNoCC, fetchzip, callPackage, makeShellWrapper, makeDesktopItem,
  copyDesktopItems, bash, python3, coreutils, findutils, gnugrep, gnused, gawk,
  util-linux, xdg-utils, cacert }:
let
  version = "0.9.37";
  src = fetchzip {
    url = "https://github.com/Awakenchan/LanternEngine/archive/refs/tags/v${version}.tar.gz";
    hash = "sha256-3SMoo+s7i74yErvEleGgnQLUrpNecjJX8uJcw1yafV8=";
  };
  engine = callPackage ./engine.nix { inherit src version; };
  launcher = callPackage ./launcher.nix { inherit src version; };
  runtimePath = lib.makeBinPath [ bash python3 coreutils findutils gnugrep gnused gawk util-linux xdg-utils ];
in
stdenvNoCC.mkDerivation {
  pname = "lantern-engine";
  inherit version;
  dontUnpack = true;
  nativeBuildInputs = [ makeShellWrapper copyDesktopItems ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share/lantern-engine
    ln -s ${engine} $out/share/lantern-engine/engine
    cat > $out/bin/lantern-engine <<'EOF'
    #!${bash}/bin/bash
    set -euo pipefail
    export BB_DATA_DIR="''${BB_DATA_DIR:-''${XDG_DATA_HOME:-$HOME/.local/share}/lantern-engine}"
    export BB_CONFIG="''${BB_CONFIG:-$BB_DATA_DIR/lantern.ini}"
    export BB_OUT_DIR="$BB_DATA_DIR/out"
    mkdir -p "$BB_OUT_DIR"
    # Only generated game data is writable; executable files remain in the store.
    for name in bb-shader-lab bb-engine-assets gpu-cache.id; do
      ln -sfn ${engine}/out/"$name" "$BB_OUT_DIR/$name"
    done
    cd @out@/share/lantern-engine
    exec ${launcher}/bin/LanternEngine "$@"
    EOF
    substituteInPlace $out/bin/lantern-engine --replace-fail '@out@' "$out"
    chmod +x $out/bin/lantern-engine
    wrapProgram $out/bin/lantern-engine \
      --prefix PATH : ${runtimePath} \
      --set PYTHON ${python3}/bin/python3 \
      --set-default SSL_CERT_FILE ${cacert}/etc/ssl/certs/ca-bundle.crt
    mkdir -p $out/share/licenses/lantern-engine
    cp ${src}/LICENSE ${src}/NOTICE $out/share/licenses/lantern-engine/
    echo 'Modified Nix build based on Lantern Engine by Awaken (https://github.com/Awakenchan/LanternEngine); updates managed by Nix.' \
      > $out/share/licenses/lantern-engine/NIX-BUILD
    runHook postInstall
  '';
  desktopItems = [ (makeDesktopItem {
    name = "lantern-engine";
    desktopName = "Nix build based on Lantern Engine";
    comment = "Lantern Engine by Awaken; requires your own Bloodborne dump";
    exec = "lantern-engine";
    icon = "applications-games";
    categories = [ "Game" ];
  }) ];
  passthru = { inherit engine launcher; };
  meta = {
    description = "Source-built Lantern Engine by Awaken (modified Nix build); requires your own game dump";
    homepage = "https://github.com/Awakenchan/LanternEngine";
    # NOTICE adds GPL section 7 attribution, modified-version and name terms.
    license = lib.licenses.gpl3Plus // {
      fullName = "GNU GPL v3 or later, with upstream NOTICE section 7 terms";
      url = "https://github.com/Awakenchan/LanternEngine/blob/v${version}/NOTICE";
    };
    platforms = [ "x86_64-linux" ];
    mainProgram = "lantern-engine";
  };
}
