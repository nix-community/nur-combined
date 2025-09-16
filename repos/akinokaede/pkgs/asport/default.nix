{ lib
, stdenv
, fetchFromGitHub
, rustPlatform
, darwin
}:

rustPlatform.buildRustPackage rec {
  pname = "asport";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "AkinoKaede";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-HD0c4MlGDd3c9HjgzAL5v3Hlgjdo8cU8ZNrSWsv6gd4=";
  };

  cargoHash = "sha256-Rg0wdsTkH9L327CWi3VN0fGkB+zW48/D98V74GRlwTQ=";
  
  meta = with lib; {
    description = "A quick and secure reverse tunnel based on QUIC.";
    homepage = "https://github.com/AkinoKaede/asport";
    licenses = licenses.gpl3Plus;
    maintainers = [ "Kaede Akino" ];
  };
}