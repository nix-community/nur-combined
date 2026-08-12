{
  lib,
  fetchFromGitHub,
  vimUtils,
}:

vimUtils.buildVimPlugin rec {
  pname = "proximity.nvim";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "zimeg";
    repo = "proximity.nvim";
    rev = "v${version}";
    hash = "sha256-ZPH//f0cAVGGWcw80yr7KZ7vIHJ5IERd5Ez+/F4dgL8=";
  };

  meta = with lib; {
    homepage = "https://github.com/zimeg/proximity.nvim";
    description = "find the nearest matching file fast";
    license = licenses.mit;
  };
}
