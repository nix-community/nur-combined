{ lib, rustPlatform, fetchFromGitLab }:

rustPlatform.buildRustPackage rec {
  pname = "msyt";
  version = "unstable-2019-11-07";

  src = fetchFromGitLab {
    owner = "jkcclemens";
    repo = "msyt";
    rev = "5789bc3c2f0747adc096afb6a2c716f87dbd7b4d";
    sha256 = "0dly078x8iwzhd140633mzamwdk04qnwhdg1mmrvkz4hjsks0sz6";
  };

  cargoPatches = [
    ./json.patch
  ];

  cargoSha256 = "1gki7rssaxfqx79bfhvx02jwzp8a8bhv4cinxw2ch304dv0bqn4z";

  meta = with lib; {
    description = "A human readable and editable format for msbt files (patched to use serde_json for BCML)";
    homepage = "https://gitlab.com/jkcclemens/msyt";
    license = licenses.mit;
    maintainers = with maintainers; [ metadark ];
  };
}
