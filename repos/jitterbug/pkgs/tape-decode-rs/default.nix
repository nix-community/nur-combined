{
  maintainers,
  lib,
  fetchFromGitHub,
  rustPlatform,
  ...
}:
let
  pname = "tape-decode-rs";
  version = "0.1.0";

  rev = version;
  hash = "sha256-Es3/HkEU1uZ4e4wpKXcdZGBuM1RUahk2cinYAdpaECs=";
  cargoHash = "sha256-AKq1HcrD7hW1bE9CPC2Xt3gQTi5OknpGKtO+kRKvHjY=";
in
rustPlatform.buildRustPackage {
  inherit pname version cargoHash;

  src = fetchFromGitHub {
    inherit hash rev;
    owner = "namazso";
    repo = "tape-decode-rs";
  };

  meta = {
    inherit maintainers;
    mainprogram = "tape-decode";
    description = "Extract video from RAW RF captures of colour-under & composite modulated tapes.";
    homepage = "https://github.com/namazso/tape-decode-rs";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
  };
}
