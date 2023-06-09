{ lib, stdenv, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "csv2html";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "dbohdan";
    repo = "csv2html";
    rev = "v${version}";
    hash = "sha256-7pEVMdF7rUXKsDrxGFfqwQDIVykgG/x4kh0En1D9VxU=";
  };

  cargoPatches = [ ./cargo-lock.patch ];
  cargoHash = "sha256-2Qhu+7Lb6Pvs1a9qH5WmcakxeQVB2bm4fPGZXwh3cgA=";

  meta = with lib; {
    description = "Convert CSV files to HTML tables";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
