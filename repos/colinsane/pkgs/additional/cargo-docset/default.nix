{ lib
, fetchFromGitHub
, rustPlatform
, sqlite
}:

rustPlatform.buildRustPackage rec {
  pname = "cargo-docset";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "Robzz";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-o2CSQiU9fEoS3eRmwphtYGZTwn3mstRm2Tlvval83+U=";
  };

  cargoHash = "sha256-YHrSvfHfQ7kbVeCOgggYf3E7gHq+RhVKZrzP8LqX5I0=";

  buildInputs = [
    sqlite
  ];

  meta = with lib; {
    description = "Cargo subcommand to generate a Dash/Zeal docset for your Rust packages. ";
    homepage = "https://github.com/Robzz/cargo-docset";
    license = licenses.asl20;
    maintainers = with maintainers; [ colinsane ];
  };
}
