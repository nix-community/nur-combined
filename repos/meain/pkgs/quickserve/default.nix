{ lib
, fetchFromGitHub
, rustPlatform
, installShellFiles
}:

rustPlatform.buildRustPackage rec {
  pname = "quickserve";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "meain";
    repo = pname;
    rev = version;
    sha256 = "sha256-5mfoG1tnEOkTEsTt1C0/aF9olCRht5znJRAryTEJACk=";
  };

  cargoSha256 = "sha256-FQah5060MK2ttRbRgPC2ISdmcKoKn3RZgLYoCpAJ80E=";

  doInstallCheck = true;

  meta = with lib; {
    homepage = "https://github.com/meain/quickserve";
    description = "Serve a directory over http, quickly";
    license = licenses.asl20;
  };
}
