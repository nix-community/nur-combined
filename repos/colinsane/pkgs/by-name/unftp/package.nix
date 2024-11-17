{ lib
, rustPlatform
, fetchFromGitHub
}:

rustPlatform.buildRustPackage rec {
  pname = "unftp";
  version = "0.14.3";

  src = fetchFromGitHub {
    owner = "bolcom";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-+UL8xflnumOiWL5b9/azH9OW+X+6hRcxjiyWhCSWQRg=";
  };

  cargoHash = "sha256-rXCDPVi3JZrC4iqgqAirigDa3fNIbkVgSo0qWHXEnvQ=";

  meta = with lib; {
    description = "unFTP is an open-source FTP(S) (not SFTP) server aimed at the Cloud that allows bespoke extension through its pluggable authenticator, storage back-end and user detail store architectures.";
    homepage = "https://unftp.rs/";
    license = licenses.asl20;
    maintainers = with maintainers; [ colinsane ];
  };
}
