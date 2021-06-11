{ lib
, buildVimPluginFrom2Nix
, fetchFromGitHub
}:
buildVimPluginFrom2Nix {

  pname = "vim-super-retab";
  version = "2013-11-8";

  src = fetchFromGitHub {
    owner = "rhlobo";
    repo = "vim-super-retab";
    rev = "ca763a978123992b213c0fb87b44f5d7807d3514";
    sha256 = "0x257iqjx7i28fr7qky0fq4f7sfzgf8zhf5nkzjv2cgfhp27h5is";
  };

  meta = with lib; {
    description = "Identation conversion: tabs to spaces or spaces to tabs";
    license = licenses.mit;
    homepage = "https://vim.fandom.com/wiki/Super_retab";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
