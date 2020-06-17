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
    rev = "master";
    sha256 = "0sm13yfa813y8p91v33iaf6px4y4b6zhwbqhwg05wjz09nrd3ggn";
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
