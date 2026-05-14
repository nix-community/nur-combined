{ fetchCrate
, lib
, nix-update-script
, rustPlatform
}:

let
  inherit (lib) licenses;
in
rustPlatform.buildRustPackage (fastnbt-tools: {
  pname = "fastnbt-tools";
  version = "0.27.0";
  meta = {
    description = "Command-line utilities for reading Minecraft data files";
    homepage = "https://github.com/owengage/fastnbt";
    license = licenses.mit;
  };

  passthru.updateScript = nix-update-script { };

  src = fetchCrate {
    inherit (fastnbt-tools) pname version;
    sha256 = "sha256-KnbJXiMPHjk/pReurP5WdE9I1GgLMhGEHKtZwFekzzM=";
  };

  cargoHash = "sha256-u1Lj7Gv3ucvjHub4IpLxD5FI98DFaKKuXWhBHXsHK2c=";
})
