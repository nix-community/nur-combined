{ stdenv, lib, fetchurl, iosevka, unzip
}:

let
  name = "sgr-iosevka-term";
  variantHashes = import ./variants.nix;
in
stdenv.mkDerivation rec {
  pname = "iosevka-term";
  version = "9.0.1";

  src = fetchurl {
    url = "https://github.com/be5invis/Iosevka/releases/download/v${version}/ttc-${name}-${version}.zip";
    sha256 = variantHashes.${name};
  };

  nativeBuildInputs = [ unzip ];

  dontInstall = true;

  unpackPhase = ''
    mkdir -p $out/share/fonts
    unzip -d $out/share/fonts/truetype $src
  '';

  meta = iosevka.meta // {
    maintainers = with lib.maintainers; [
      suhr
    ];
  };
}
