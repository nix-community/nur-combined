{ lib, rustPlatform, fetchFromGitLab }:

rustPlatform.buildRustPackage rec {
  pname = "msjt";
  version = "unstable-2019-10-25";

  src = fetchFromGitLab {
    owner = "jkcclemens";
    repo = "msyt";
    rev = "5789bc3c2f0747adc096afb6a2c716f87dbd7b4d";
    sha256 = "0dly078x8iwzhd140633mzamwdk04qnwhdg1mmrvkz4hjsks0sz6";
  };

  cargoPatches = [
    ./json.patch
  ];

  cargoSha256 = "1dc410g2p88hyxmyyg10xyj3jsiqdj2ygmkjz1psk1bvfkpzr05i";

  meta = with lib; {
    description = "A human readable and editable format for msbt files";
    homepage = "https://gitlab.com/jkcclemens/msyt";
    license = licenses.mit;
    maintainers = with maintainers; [ metadark ];
    platforms = platforms.all;
  };
}
