{ lib, vimUtils, fetchFromGitHub }:
let
  ref = "7a926154ad53ede31df87eeb1c439cff6ecaabc7";
in vimUtils.buildVimPluginFrom2Nix {
  pname = "janet-vim";
  version = "dev-${ref}";

  src = fetchFromGitHub {
    owner = "janet-lang";
    repo = "janet.vim";
    rev = ref;
    hash = "sha256-cySG6PuwlRfhNePUFdXP0w6m5GrYIxgMRcdpgFvJ+VA=";
  };

  meta = with lib; {
    description = "Syntax files for Janet in Vim. The Janet language is in flux, and this repo will be updated with it.";
    homepage = "https://github.com/janet-lang/janet.vim";
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.darwin ++ platforms.windows;
  };
}
