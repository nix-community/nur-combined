{ stdenv, fetchFromGitHub,
 } :

stdenv.mkDerivation rec {
  version = "git";
  pname = "superdiskindex";

  src = fetchFromGitHub {
    owner = "shamada-code";
    repo = "${pname}";
    rev = "release-0.04";
    sha512 = "05b4bsfcsw6f3l5m6wp2p56rkfydvjdq48vvg4kwgfbxm9cy39vapa2h68cw7szh5mh8k5j7y9338hvmw3giz4w5jhfb8c1fkffrcxm";
  };

  buildInputs = [  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -p superdiskindex $out/bin/
    '';

  meta = {
    homepage = https://github.com/shamada-code/superdiskindex;
    description  = "";
    #license = stdenv.lib.licenses.gpl3;
    maintainers = with stdenv.lib.maintainers; [ tokudan ];
    platforms = stdenv.lib.platforms.all;
  };
}
