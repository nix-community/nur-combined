{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "package-assistant";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "patryk-s";
    repo = pname;
    rev = "refs/tags/${version}";
    hash = "sha256-v4cC/QQ6CEn5kCju39taSVMj6MAUhMGGj+OYveEe5XE=";
  };

  cargoHash = "sha256-dTDLRV6AMauilOjIYT/JOlDQMMnvv6jqHg1uCIYfXBU=";
  cargoBuildFlags = [
    "--locked"
  ];

  meta = {
    description = "Manage your package managers";
    longDescription = ''
      Provides a consistent CLI interface for all supported package managers,
      across multiple OSes, so you don't have to remember the specific syntax on a given system.
    '';
    homepage = "https://github.com/patryk-s/package-assistant";
    license = lib.licenses.mit;
    # maintainers = [ ];
    mainProgram = "pa";
  };
}
