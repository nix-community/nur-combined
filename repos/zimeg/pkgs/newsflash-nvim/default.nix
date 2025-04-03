{
  lib,
  fetchFromGitHub,
  vimUtils,
}:

vimUtils.buildVimPlugin rec {
  pname = "newsflash.nvim";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "zimeg";
    repo = "newsflash.nvim";
    rev = "v${version}";
    hash = "sha256-lXVnTY/sJc2OqrNrW1UjOJe+P6/VlJUSDYY31mBnUWA=";
  };

  meta = with lib; {
    homepage = "https://github.com/zimeg/newsflash.nvim";
    description = "open the current selected file in front";
    license = licenses.mit;
  };
}
