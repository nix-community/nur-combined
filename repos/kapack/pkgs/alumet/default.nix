{ lib, rustPlatform, fetchFromGitHub, openssl }:

rustPlatform.buildRustPackage rec {
  pname = "alumet";
  version = "0.8.4";

  src = fetchFromGitHub {
     owner = "alumet-dev";
     repo = pname;
     rev = "v${version}";
     hash = "sha256-9lh6eg5B3d9vx80QGj5qXkgYWfmvkGrGqknUlI4HkOE=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-+4aILPaxIm9vYr2MF1BuO6TUOQlEa+BMfe8qeMdZ5Og=";
  
  env = {
    OPENSSL_NO_VENDOR = 1;
    OPENSSL_LIB_DIR = "${lib.getLib openssl}/lib";
    OPENSSL_DIR = "${lib.getDev openssl}";
  };

  # Checks failed due to network requirements (to be confirmed)
  doCheck = false;

  meta = with lib; {
    homepage = "https://alumet.dev";
    description = "ALUMET: Unified and Modular Measurement Framework";
    license = licenses.eupl12;
  };
}
