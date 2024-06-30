{ lib
, fetchFromGitHub
, vimUtils
}:

vimUtils.buildVimPlugin {
  pname = "proximity.nvim";
  version = "unreleased";

  src = fetchFromGitHub {
    owner = "zimeg";
    repo = "proximity.nvim";
    rev = "bd47a30b82e6ff73758e3248995c83c098fb75e6";
    sha256 = "sha256-k18izBl9qDWFmp5/CPmzPkbckMpmvvdykyePL4h1aFQ=";
  };

  meta = with lib; {
    homepage = "https://github.com/zimeg/proximity.nvim";
    description = "find the nearest matching file fast";
    license = licenses.mit;
  };
}
