{ pkgs, fetchFromGitHub }:

pkgs.stdenv.mkDerivation rec {
  pname = "adi1090x-plymouth";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "adi1090x";
    repo = "plymouth-themes";
    rev = "bf2f570bee8e84c5c20caac353cbe1d811a4745f";
    sha256 = "sha256-VNGvA8ujwjpC2rTVZKrXni2GjfiZk7AgAn4ZB4Baj2k=";
  };

  buildInputs = [
    pkgs.git
  ];

  configurePhase = ''
    mkdir -p $out/share/plymouth/themes/
  '';

  buildPhase = ''
  '';

  installPhase = ''
    cp -r pack_1/cuts $out/share/plymouth/themes
    cp -r pack_2/{hexagon,green_loader,deus_ex} $out/share/plymouth/themes
    cp -r pack_4/{spinner_alt,sphere} $out/share/plymouth/themes
    for p in $out/share/plymouth/themes/*; do
      theme=$(basename $p)
      sed -i "s@\/usr\/@$out\/@" $out/share/plymouth/themes/$theme/$theme.plymouth
    done
  '';
}
