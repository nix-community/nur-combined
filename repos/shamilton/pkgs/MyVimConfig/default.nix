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
    rev = "77fbc4befaea0654fdfcf7d6bf0f2f7f9f87904d";
    sha256 = "0cdrc72342ys7p9mxvdsw57wvl9l2x64k3gs298yx3f4j4kpx2ja";
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
