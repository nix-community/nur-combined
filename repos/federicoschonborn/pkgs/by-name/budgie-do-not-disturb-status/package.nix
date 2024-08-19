{
  lib,
  buildGo123Module,
  fetchFromSourcehut,
  nix-update-script,
}:

let
  version = "1.0.1";
in

buildGo123Module {
  pname = "budgie-do-not-disturb-status";
  inherit version;

  src = fetchFromSourcehut {
    owner = "~ianmjones";
    repo = "budgie-do-not-disturb-status";
    rev = "v${version}";
    hash = "sha256-VUMnRuR+eUWaorFTC0iRQ2kRk1KhEPyk58DK+G+AhRY=";
  };

  vendorHash = "sha256-LMhkQgLkUtG1jFM0R1Yn9Be6T0Mhfv2QukYL3haAOaE=";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "budgie-do-not-disturb-status";
    description = "";
    homepage = "https://git.sr.ht/~ianmjones/budgie-do-not-disturb-status";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
