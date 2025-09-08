{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule {
  pname = "uni-week-counter";
  version = "0-unstable-2025-08-31";

  src = fetchFromGitHub {
    owner = "ymstnt";
    repo =  "uni-week-counter";
    rev = "d0e78c666e411f8326f9698e0681334e54a3c3c5";
    hash = "sha256-ZVAyARDxAR1hqPI5yajKOaZJ1KMVxpWQrWN3nOKNUOA=";
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
