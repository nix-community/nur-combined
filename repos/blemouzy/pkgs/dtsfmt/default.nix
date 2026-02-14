{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "dtsfmt";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "mskelton";
    repo = "dtsfmt";
    tag = "v${version}";
    hash = "sha256-IcTap6eDzDfaSRqgAxgCpsD7ObXBp7LUodCskyQzgeQ=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-BbX/IEfn5qhyW/IkgARfxD0rTx+hcoq8TmoDmUqclHQ=";

  meta = {
    description = "Auto formatter for device tree files";
    longDescription = ''
      Auto formatter for device tree files.
    '';
    homepage = "https://github.com/mskelton/dtsfmt";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "dtsfmt";
  };
}
