{ lib
, fetchFromGitHub
, rustPlatform
, installShellFiles
}:

rustPlatform.buildRustPackage rec {
  pname = "quickserve";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "meain";
    repo = pname;
    rev = version;
    sha256 = "sha256-FIb3wkSkwR/TOuvOvLZDetOUabMp97E7Dt+6J0VhU8g=";
  };

  cargoSha256 = "sha256-JdZfQPNy6lZocottRxahh5we2jc76diQahaX+YQProw=";

  doInstallCheck = true;

  meta = with lib; {
    homepage = "https://github.com/meain/quickserve";
    description = "Serve a directory over http, quickly";
    license = licenses.asl20;
  };
}
