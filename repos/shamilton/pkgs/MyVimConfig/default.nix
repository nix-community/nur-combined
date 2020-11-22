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
    rev = "79551006cc65b9fffab9971e98695fd26af010ed";
    sha256 = "180vwpk3cmx33wjjnkzkv7js9bxsqm12djrabn47h86fcc1jp3pw";
  };


  propagatedBuildInputs = [ coreutils ];

  patches = [ ./remove-pathogen.patch ~/GIT/vimconfig/patch.patch ];

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
