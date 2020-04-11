{ stdenv, fetchFromGitHub, emacs, jansson, gccjit }:

(emacs.override { srcRepo = true; }).overrideAttrs (
  o: rec {
    pname = "gccemacs";
    version = "27";
    src = fetchFromGitHub {
      owner = "emacs-mirror";
      repo = "emacs";
      # Fetching off the feature/native-comp git branch
      rev = "4abb8c822ce02cf33712bd2699c5b77a5db49e31";
      sha256 = "1w1bs358vx47nj7kgbdw5ppdiq78w96abyvl99lfqkbm0xvi41rz";
    };
    patches = [];
    buildInputs = o.buildInputs ++ [ jansson gccjit ];
    configureFlags = o.configureFlags ++ [ "--with-nativecomp" ];
  }
)
