{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script,
}:

buildNpmPackage rec {
  pname = "ggt";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "gadget-inc";
    repo = "ggt";
    rev = "refs/tags/v${version}";
    hash = "sha256-wHzkjcHC1VgWh51Uggzk7FmrqcWYBm+e6xOAHSKVPno=";
  };

  postPatch = ''
    ln -s npm-shrinkwrap.json package-lock.json
  '';

  npmDepsHash = "sha256-Ml4Z/r1NQN8gaBrPKIE2e5GjpoxlrXV8jOx18Y7OzVs=";

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Command-line interface for Gadget";
    homepage = "https://docs.gadget.dev/guides/development-tools/cli";
    changelog = "https://github.com/gadget-inc/ggt/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ kira-bruneau ];
    mainProgram = "ggt";
  };
}
