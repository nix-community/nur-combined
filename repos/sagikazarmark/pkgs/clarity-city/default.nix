{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "clarity-city";
  version = "v1.0.0";

  src = fetchFromGitHub {
    owner = "vmware";
    repo = "clarity-city";
    rev = "${version}";
    sha256 = "sha256-1POSdd2ICnyNNmGadIujezNK8qvARD0kkLR4yWjs5kA=";
  };

  installPhase = ''
    install -Dm644 TrueType/*.ttf -t $out/share/fonts/truetype
    install -Dm644 OpenType/*.otf -t $out/share/fonts/opentype
    install -Dm644 Webfonts/EOT/*.eot -t $out/share/fonts/eot
    install -Dm644 Webfonts/WOFF/*.woff -t $out/share/fonts/woff
    install -Dm644 Webfonts/WOFF2/*.woff2 -t $out/share/fonts/woff
  '';

  meta = with lib; {
    description = "Clarity City";
    homepage = "https://github.com/vmware/clarity-city";
    license = licenses.ofl;
    platforms = platforms.all;
    maintainers = with maintainers; [ sagikazarmark ];
  };
}
