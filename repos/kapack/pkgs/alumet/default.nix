{ lib, rustPlatform, fetchFromGitHub, openssl }:

rustPlatform.buildRustPackage rec {
  pname = "alumet";
  version = "0.8.3";

  src = fetchFromGitHub {
     owner = "alumet-dev";
     repo = pname;
     rev = "v${version}";
     hash = "sha256-du9LPNOJp6fFEmddhj2ye4Vy+gzPy8eq2CrGdrV9Ao8=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-AdzWLN5msX1dDa4ZcuRmbu8C37isC6/kd6fVED9MECo=";
  
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
