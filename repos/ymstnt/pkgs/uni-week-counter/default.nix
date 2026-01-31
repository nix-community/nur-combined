{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule {
  pname = "uni-week-counter";
  version = "0-unstable-2026-01-30";

  src = fetchFromGitHub {
    owner = "ymstnt";
    repo =  "uni-week-counter";
    rev = "2fbd11672f0ad4654c7550322a4bfcb10f024155";
    hash = "sha256-G0yAs/2ZOhulb5DawBEJZvfBBVVBcfCZe1N3dBhqAdg=";
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
