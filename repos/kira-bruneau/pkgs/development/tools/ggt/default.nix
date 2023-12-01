{ lib
, buildNpmPackage
, fetchFromGitHub
, nix-update-script
}:

buildNpmPackage rec {
  pname = "ggt";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "gadget-inc";
    repo = "ggt";
    rev = "refs/tags/v${version}";
    hash = "sha256-Cx3ZZnSntRugK8IrHowdgKEvU2Ep/V+OnjuzrxOGro4=";
  };

  patches = [
    ./fix-resolved.patch
  ];

  postPatch = ''
    ln -s npm-shrinkwrap.json package-lock.json
  '';

  npmDepsHash = "sha256-pblVxZivacVltZiZORfqKRMZQVPvdzepgO/IoqqSPw4=";

  npmFlags = [ "--ignore-scripts" ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "The command-line interface for Gadget";
    homepage = "https://docs.gadget.dev/guides/development-tools/cli";
    license = licenses.mit;
    maintainers = with maintainers; [ kira-bruneau ];
    mainProgram = "ggt";
  };
}
