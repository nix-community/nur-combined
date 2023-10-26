{ vimUtils, fetchFromGitHub }:

_final: _prev: {
  gruvbox-nvim = vimUtils.buildVimPlugin {
    pname = "gruvbox.nvim";
    version = "2023-10-07";

    src = fetchFromGitHub {
      owner = "ellisonleao";
      repo = "gruvbox.nvim";
      rev = "477c62493c82684ed510c4f70eaf83802e398898";
      sha256 = "0250c24c6n6yri48l288irdawhqs16qna3y74rdkgjd2jvh66vdm";
    };

    patches = [
      # Inspired by https://github.com/ellisonleao/gruvbox.nvim/pull/291
      ./colours.patch
    ];

    meta = {
      homepage = "https://github.com/ellisonleao/gruvbox.nvim/";
    };
  };
}
