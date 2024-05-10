{ lib, stdenv, fetchurl }:
stdenv.mkDerivation rec {
  pname = "kanata-bin";
  version = "1.6.1";

  src = fetchurl {
	url = "https://github.com/jtroo/kanata/releases/download/v${version}/kanata_macos_arm64";
	sha256 = "sha256-6gYIItqnDAKjTCsuqF81qmvaYpYLJ5ipetKo7lXvR/Y=";
  };

  phases = [ "installPhase" ];

  sourceRoot = ".";

  installPhase = ''
	mkdir -p $out/bin
	cp $src $out/bin/kanata
	chmod +x $out/bin/kanata
  '';

  meta = with lib; {
  	description = "Improve keyboard comfort and usability with advanced customization ";
	homepage = "https://github.com/jtroo/kanata";
	license = licenses.gpl3Only;
	maintainers = with maintainers; [ jpyke3 ];
	platforms = platforms.darwin;
  };
}
