{ stdenv, fetchFromGitHub, emacs, jansson, libgccjit }:

(emacs.override { srcRepo = true; }).overrideAttrs (
  o: rec {
    pname = "gccemacs";
    version = "27";
    src = fetchFromGitHub {
      owner = "emacs-mirror";
      repo = "emacs";
      # Fetching off the feature/native-comp git branch
      rev = "86cc9377cec397884744fcc4d0e5b555cbc3ca46";
      sha256 = "1i2xqalbz33kyq2i6rybya8gkny6kdjkfl0h3ww3pr8cj1lzilwc";
    };
    patches = [];
    buildInputs = o.buildInputs ++ [ jansson libgccjit ];
    configureFlags = o.configureFlags ++ [ "--with-nativecomp" ];
  }
)
