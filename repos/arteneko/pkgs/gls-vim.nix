{ lib, vimUtils, fetchFromSourcehut }:
let
  ref = "f28d125184deaf2ee722ed42f434b1901d3e076f";
in vimUtils.buildVimPluginFrom2Nix {
  pname = "gls-vim";
  version = "dev-${ref}";

  src = fetchFromSourcehut {
    owner = "~artemis";
    repo = "gls.vim";
    rev = ref;
    hash = "sha256-LHFejgmkmOAX3RTY9DT+Q+QJTBfoyPydsIzZxsub+XI=";
  };

  meta = with lib; {
    description = "gay little stories syntax highlighting vim plugin";
    homepage = "https://git.sr.ht/~artemis/gls.vim";
    license = licenses.free;
    platforms = platforms.linux ++ platforms.darwin ++ platforms.windows;
  };
}
