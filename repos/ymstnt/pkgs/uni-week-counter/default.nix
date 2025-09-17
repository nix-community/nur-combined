{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule {
  pname = "uni-week-counter";
  version = "0-unstable-2025-09-17";

  src = fetchFromGitHub {
    owner = "ymstnt";
    repo =  "uni-week-counter";
    rev = "d981d851720546a646cc7d4bcb4d3b39de68ee29";
    hash = "sha256-QVkjEtJafYITRvddvpT9bnTYgbKYnBzhZRC58XKx9ds=";
  };

  vendorHash = null;

  meta = {
    description = "University week counter API.";
    homepage = "https://github.com/ymstnt/uni-week-counter/";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ ymstnt ];
    platforms = lib.platforms.all;
    mainProgram = "uni-week-counter";
  };

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
}
