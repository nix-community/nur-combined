{ lib
, stdenv
, fetchFromGitHub
, coreutils
}:
stdenv.mkDerivation {

  pname = "Myvimconfig";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "vimconfig";
    rev = "master";
    sha256 = "1c0mr3sd1jz1dncxnzdsbm1lmv48hxqbbll2lx20i4lic8xl8rlx";
  };

  propagatedBuildInputs = [ coreutils ];

  patches = [ ./remove-pathogen.patch ];

  postPatch = ''
    find . -maxdepth 1 | egrep -v "^\./ftplugin$|^\./vimrc$|^\.$" | xargs -n1 -L1 -r -I{} rm -rf {}
    echo "let g:lsp_settings_servers_dir='\$XDG_CACHE_HOME/vim/lsp-servers'" >> ./vimrc
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
