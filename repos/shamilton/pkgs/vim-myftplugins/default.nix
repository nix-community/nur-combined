{ pkgs
, lib
, buildVimPluginFrom2Nix
, fetchFromGitHub
, coreutils
}:
buildVimPluginFrom2Nix {

  pname = "vim-myftplugins";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "vimconfig";
    rev = "79551006cc65b9fffab9971e98695fd26af010ed";
    sha256 = "180vwpk3cmx33wjjnkzkv7js9bxsqm12djrabn47h86fcc1jp3pw";
  };

  patches = [ ~/GIT/vimconfig/patch.patch ];

  buildInputs = [ coreutils ];

  postPatch = ''
    find . -maxdepth 1 | egrep -v "^\./ftplugin$|^\.$" | xargs -n1 -L1 -r -I{} rm -rf {}
  '';

  meta = with lib; {
    description = "My vim ftplugins";
    license = licenses.mit;
    homepage = "https://github.com/SCOTT-HAMILTON/vimconfig";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
