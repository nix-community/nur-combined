{
  lib,
  buildPythonApplication,
  fetchFromGitHub,
  setuptools,
  requests,
  pyyaml,
  packaging,
  nix-update-script,
}:
buildPythonApplication rec {
  pname = "nix-update-docker-image";
  version = "0.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "AtaraxiaSjel";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-1FtbqEoAPSYDE7DGHptOxoGsxiRvd6teB2JkL2kPmE4=";
  };

  build-system = [ setuptools ];

  dependencies = [
    packaging
    pyyaml
    requests
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "A tool to update Docker image digests in Nix files.";
    homepage = "https://github.com/AtaraxiaSjel/nix-update-docker-image";
    license = licenses.mit;
    maintainers = with maintainers; [ ataraxiasjel ];
    mainProgram = "nix-update-docker-image";
  };
}
