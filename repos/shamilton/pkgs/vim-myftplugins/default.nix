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
    rev = "master";
    sha256 = "0f9fpgc16hscx73qf1yisf75bg07faqgkqp7g28jr8q5qbyzzmv4";
  };

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
