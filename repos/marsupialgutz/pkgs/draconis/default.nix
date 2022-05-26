{ lib, fetchFromGitHub, rustPlatform, pkgconfig, dbus }:

rustPlatform.buildRustPackage rec {
  nativeBuildInputs = [
    pkgconfig
  ];

  buildInputs = [
    dbus
  ];

  pname = "draconis";
  version = "2.4.4";

  src = fetchFromGitHub {
    owner = "marsupialgutz";
    repo = "draconis";
    rev = "035ef1db0d4226f6d553fa96c3014b53430f97ef";
    sha256 = "1fcnrdjgqkr1ah1wg1jvs1vs94nlkxkdjbqxphilhw7hj1mkdbam";
  };

  cargoSha256 = "AI2hOPGtLIewbu+ggGa2PBb5kVTA5TGUX5Rp9VXSW2o=";

  meta = with lib; {
    description = "🪐 An out-of-this-world greeter for your terminal";
    homepage = "https://github.com/marsupialgutz/draconis";
    platforms = platforms.linux;
  };
}
