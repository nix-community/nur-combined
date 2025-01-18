{ lib, stdenvNoCC, fetchzip }:

stdenvNoCC.mkDerivation rec {
  pname = "xiv-on-mac";
  version = "5.0.2";

  src = fetchzip {
    url = "https://softwareupdate.xivmac.com/sites/default/files/update_data/XIV%20on%20Mac${version}.tar.xz";
    hash = "sha256-lDzsdy8QWUG71HIzfvyZYQGXDhoH7sn09C1wcwg3Sc0=";
    stripRoot = false;
  };

  # fixup breaks the signature, causing macOS to think it's corrupt
  dontFixup = true;

  # wrapper based on:
  # https://github.com/NixOS/nixpkgs/blob/5df43628fdf08d642be8ba5b3625a6c70731c19c/pkgs/by-name/it/iterm2/package.nix#L29
  installPhase = ''
    runHook preInstall
    APP_DIR="$out/Applications/XIV on Mac.app"
    mkdir -p "$APP_DIR" $out/bin
    cp -R "XIV on Mac.app" $out/Applications
    cat << EOF > "$out/bin/xiv-on-mac"
    #!${stdenvNoCC.shell}
    open -na "$APP_DIR" --args "$@"
    EOF
    chmod +x "$out/bin/xiv-on-mac"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Modern, open-source Final Fantasy XIV client for macOS";
    homepage = "https://www.xivmac.com";
    license = licenses.gpl3;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = [ "aarch64-darwin" ];
    mainProgram = "xiv-on-mac";
  };
}
