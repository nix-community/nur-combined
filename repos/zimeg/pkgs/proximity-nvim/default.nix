{ lib
, fetchFromGitHub
, vimUtils
}:

vimUtils.buildVimPlugin rec {
  pname = "proximity.nvim";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "zimeg";
    repo = "proximity.nvim";
    rev = "v${version}";
    sha256 = "sha256-jSfnsB1f08cLUVs2OzMtyCqptVLpeVWgp9Oyfp4GjBI=";
  };

  meta = with lib; {
    homepage = "https://github.com/zimeg/proximity.nvim";
    description = "find the nearest matching file fast";
    license = licenses.mit;
  };
}
