{ lib, stdenvNoCC, fetchzip }:

stdenvNoCC.mkDerivation rec {
  pname = "launchcontrol";
  version = "2.7";

  src = fetchzip {
    url = "https://www.soma-zone.com/download/files/LaunchControl-${version}.tar.xz";
    hash = "sha256-O11i4BDl1izEx8hsJ/SrFM4maQ0gtItpncoKbGhhNYU=";
  };

  # fixup breaks the signature, causing macOS to think it's corrupt
  dontFixup = true;

  # wrapper based on:
  # https://github.com/NixOS/nixpkgs/blob/5df43628fdf08d642be8ba5b3625a6c70731c19c/pkgs/by-name/it/iterm2/package.nix#L29
  installPhase = ''
    runHook preInstall
    APP_DIR="$out/Applications/LaunchControl.app"
    mkdir -p "$APP_DIR" $out/bin
    cp -R . "$APP_DIR"
    ln -s "$APP_DIR/Contents/MacOS/fdautil" $out/bin/fdautil
    cat << EOF > "$out/bin/launchcontrol"
    #!${stdenvNoCC.shell}
    open -na "$APP_DIR" --args "$@"
    EOF
    chmod +x "$out/bin/launchcontrol"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Create, manage and debug launchd(8) services";
    homepage = "https://www.soma-zone.com/LaunchControl/";
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = [
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "launchcontrol";
  };
}
