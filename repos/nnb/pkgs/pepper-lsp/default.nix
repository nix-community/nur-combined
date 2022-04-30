{ lib, fetchCrate, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "pepper-plugin-lsp";
  version = "0.10.0";

  src = fetchCrate {
    inherit pname version;
    sha256 = "16m2ggh0i699lnbf8hhfan9l4c6nkiwfaybd8scpgvw82v192f97";
  };

  cargoSha256 = "1pfdv2hkx5asflmach0hhnyj0ndv82bchcpd2bylwjv8shsy773s";

  meta = with lib; {
    description = "Pepper editor with Language Server Protocol plugin";
    homepage = "https://vamolessa.github.io/pepper/";
    license = licenses.gpl3Plus;
  };
}
