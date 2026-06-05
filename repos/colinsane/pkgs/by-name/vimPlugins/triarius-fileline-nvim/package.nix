{
  fetchFromGitHub,
  unstableGitUpdater,
  vimUtils,
}:
vimUtils.buildVimPlugin {
  pname = "fileline.nvim";
  version = "0-unstable-2024-01-17";

  src = fetchFromGitHub {
    owner = "triarius";
    repo = "fileline.nvim";
    rev = "1c42a5ea0e2746b47e1768fd94295fdf633002af";
    hash = "sha256-+QUFS8ptYf9sr+HT0UxwEtKiZ9Z6EEdu0UUR/Ron1UM=";
  };

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    homepage = "https://github.com/triarius/fileline.nvim";
  };
}
