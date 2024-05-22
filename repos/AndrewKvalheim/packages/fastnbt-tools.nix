{ fetchCrate
, lib
, nix-update-script
, rustPlatform
}:

rustPlatform.buildRustPackage rec {
  pname = "fastnbt-tools";
  version = "0.27.0";

  src = fetchCrate {
    inherit pname version;
    sha256 = "sha256-KnbJXiMPHjk/pReurP5WdE9I1GgLMhGEHKtZwFekzzM=";
  };

  cargoHash = "sha256-5iSDo43JFMnuYhUYcOLcqnCbMWD9ogffD+FMoKN1+vY=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "tools built with fastnbt";
    homepage = "https://github.com/owengage/fastnbt";
    license = lib.licenses.mit;
  };
}
