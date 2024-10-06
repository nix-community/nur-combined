{ lib
, fetchFromGitHub
, vimUtils
}:

vimUtils.buildVimPlugin {
  pname = "telescope-git-conflicts.nvim";
  version = "2024-01-14";

  src = fetchFromGitHub {
    owner = "Snikimonkd";
    repo = "telescope-git-conflicts.nvim";
    rev = "1ac7040f601d16ab3800bdda6f5912a0e385cb29";
    sha256 = "sha256-W4rQdKEv4ydhVE1PK/R26eKQTKlqO7zVjY6EfQ/jslg=";
  };

  meta = with lib; {
    homepage = "https://github.com/Snikimonkd/telescope-git-conflicts.nvim";
    description = "Telescope git conflicts picker";
    license = licenses.mit;
  };
}
