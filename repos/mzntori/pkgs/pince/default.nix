{
  appimageTools,
  fetchurl,
  lib,
  stdenv,
  writeShellApplication,
  makeDesktopItem,
}:

let
  name = "pince";
  version = "0.9.1";

  pince-unwrapped = appimageTools.wrapType2 {
    pname = name;
    version = "v${version}";
    src = fetchurl {
      url = "https://github.com/korcankaraokcu/PINCE/releases/download/v0.9.1/PINCE-x86_64.AppImage";
      sha256 = "sha256-wP1QYOaZUAsaAVVBPa++jHHSrdJVIoKFwVnX/M8Vf34=";
    };
    extraPkgs = pkgs: with pkgs; [ zstd ];
  };

  wrapper-script = writeShellApplication {
    name = name;
    text = ''
      exec ${pince-unwrapped}/bin/${name}
    '';
  };
in
stdenv.mkDerivation {
  name = name;

  buildCommand =
    let
      desktop-entry = makeDesktopItem {
        name = name;
        desktopName = name;
        exec = "${wrapper-script}/bin/${name} %f";
        terminal = false;
      };
    in
    ''
        mkdir -p $out/bin
        cp ${wrapper-script}/bin/${name} $out/bin
      	mkdir -p $out/share/applications
      	cp ${desktop-entry}/share/applications/${name}.desktop $out/share/applications
    '';

  meta = {
    description = "Reverse engineering tool for linux games";
    homepage = "https://github.com/korcankaraokcu/PINCE";
    license = with lib.licenses; [
      gpl3Plus
      cc-by-30
    ];
    mainProgram = "pince";
    platforms = lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
