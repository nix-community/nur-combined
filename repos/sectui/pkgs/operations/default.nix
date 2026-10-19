{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_26,
}:
buildNpmPackage rec {
  pname = "operations";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "sectui";
    repo = "operations";
    rev = "v${version}";
    hash = "sha256-08MQei5EFKCN/v4fgq2ppAFDn6Ggff6CAEy/UlL43qc=";
  };

  npmDepsHash = "sha256-npo+tzQv7w11gPs1wyfvkhLyasZ513wT/XFL4Da/Zxs=";

  nodejs = nodejs_26;

  meta = with lib; {
    description = "CyberChef-like data transformations from the terminal";
    homepage = "https://github.com/sectui/operations";
    changelog = "https://github.com/sectui/operations/releases/tag/v${version}";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [
      {
        name = "Hadi";
        github = "anotherhadi";
        githubId = 112569860;
      }
    ];
    mainProgram = "ops";
  };
}
