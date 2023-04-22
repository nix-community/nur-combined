{ vimUtils
, fetchFromGitHub
, lib
,
}:
vimUtils.buildVimPlugin {
  name = "nvim-scrollbar";
  src = fetchFromGitHub {
    owner = "petertriho";
    repo = "nvim-scrollbar";
    rev = "ce0df6954a69d61315452f23f427566dc1e937ae";
    hash = "sha256-EqHoR/vdifrN3uhrA0AoJVXKf5jKxznJEgKh8bXm2PQ=";
  };

  meta = with lib; {
    description = "an extensible Neovim scrollbar";
    homepage = "https://github.com/petertriho/nvim-scrollbar";
    license = licenses.mit;
  maintainers = with maintainers; [ minion3665 ];
  };
}
