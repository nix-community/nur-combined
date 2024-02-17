{ lib, fetchFromGitHub, buildGoModule, nix-update-script }:

buildGoModule rec {
  pname = "go-check";
  version = "unstable-2024-02-14";

  src = fetchFromGitHub {
    owner = "Dreamacro";
    repo = pname;
    rev = "6ff0fe2501147f941881f8f057e1cad83755e408";
    hash = "sha256-3VjSbXKoMgz5dPz5+CWo9VtsuQNW10g7710qMa0QCLM=";
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
