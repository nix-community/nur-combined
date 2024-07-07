{ lib
, stdenv
, fetchFromGitHub
, coreutils
}:
stdenv.mkDerivation rec {

  pname = "Myvimconfig";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "vimconfig";
    rev = "56c2deba6eb830a9cc26b6c123732bb0afe7db89";
    sha256 = "1zyf3wf9v537al477p1n4bcvxpvphlynd08l7m5pgjl4g31mgzsv";
  };

  propagatedBuildInputs = [ coreutils ];

  patches = [ ./remove-pathogen.patch ];

  postPatch = ''
    find . -maxdepth 1 | egrep -v "^\./ftplugin$|^\./vimrc$|^\.$" | xargs -n1 -L1 -r -I{} rm -rf {}
  '';

  installPhase = ''
    mkdir $out
    cp -r ftplugin $out
    cp vimrc $out
  '';

  meta = with lib; {
    description = "My vim config";
    license = licenses.mit;
    homepage = "https://github.com/SCOTT-HAMILTON/vimconfig";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
