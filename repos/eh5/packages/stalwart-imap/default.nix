{ lib, rustPlatform, fetchFromGitHub }:
rustPlatform.buildRustPackage rec {
  pname = "stalwart-imap";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "stalwartlabs";
    repo = "imap-server";
    rev = "v${version}";
    sha256 = "sha256-XrLhriVaLNkBJKtRr/U8yD/RWdT+1OzhW0iAxITEOfc=";
  };

  cargoSha256 = "sha256-2OeAcxpHHvhoVuxhYdQbTHsI8Om2nyIz32tov+22jHA=";

  doCheck = false;

  meta = with lib; {
    description = "Stalwart IMAP server (imap4-to-jmap proxy)";
    homepage = "https://stalw.art/imap";
    license = licenses.agpl3Plus;
  };
}
