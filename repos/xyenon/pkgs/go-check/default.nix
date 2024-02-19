{ lib, fetchFromGitHub, buildGoModule, nix-update-script }:

buildGoModule rec {
  pname = "go-check";
  version = "unstable-2024-02-17";

  src = fetchFromGitHub {
    owner = "Dreamacro";
    repo = pname;
    rev = "35658c02e9a59254acc6082da7b1f16e402599b8";
    hash = "sha256-tA1dHPkiDpAG6fKk4GjHD8NDDw2VooRyTT1Aij2Y4lA=";
  };

  vendorHash = "sha256-rmUdtKKjPa1j1kw6UoIEAX3CEdggUsnoN2uKVqEECEg=";

  subPackages = [ "." ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version" "branch" ]; };

  meta = with lib; {
    description = "Check for outdated go module";
    homepage = "https://github.com/Dreamacro/go-check";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}
