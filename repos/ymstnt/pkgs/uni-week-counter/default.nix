{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule {
  pname = "uni-week-counter";
  version = "1.3.0-unstable-2026-05-24";

  src = fetchFromGitHub {
    owner = "ymstnt";
    repo =  "uni-week-counter";
    rev = "37e7d41818f89478928c0ccfd25632321b8f7bda";
    hash = "sha256-ul9SuA8/yZ/xHoTPmJOFcZnPJoKmjTQdn1sMFxPLcNo=";
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
