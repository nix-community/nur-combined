{ lib, rustPlatform, fetchFromGitHub }:
rustPlatform.buildRustPackage rec {
  pname = "stalwart-cli";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "stalwartlabs";
    repo = "jmap-server-cli";
    rev = "v${version}";
    sha256 = "sha256-fBnvxkGUwZVDWFdU1lGDShpP8sTa0JJSi6os+1JyyhM=";
  };

  cargoSha256 = "sha256-VCcgvajelgSLtk2Fd6lM8cEQohCpWdVYaCHEb+yQhis=";

  doCheck = false;

  meta = with lib; {
    description = "Stalwart JMAP Server CLI";
    homepage = "https://stalw.art/jmap";
    license = licenses.agpl3Plus;
  };
}
