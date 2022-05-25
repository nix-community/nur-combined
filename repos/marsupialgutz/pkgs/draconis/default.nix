{ lib, fetchFromGitHub, rustPlatform, pkgconfig, dbus }:

rustPlatform.buildRustPackage rec {
  nativeBuildInputs = [
    pkgconfig
  ];

  buildInputs = [
    dbus
  ];

  pname = "draconis";
  version = "2.4.3";

  src = fetchFromGitHub {
    owner = "marsupialgutz";
    repo = "draconis";
    rev = "8612928b447ddf634610250c3b5acac56f60aa61";
    sha256 = "0ph84jlf4x1k30rhyl120f74jh7bfpmyk2pvzkfnr4bz3q2cdwwn";
  };

  cargoSha256 = "sha256-R0VHmz8DgRTD8pLsB5722HSHLH5boWJfg7PGYzZscGI=";

  meta = with lib; {
    description = "🪐 An out-of-this-world greeter for your terminal";
    homepage = "https://github.com/marsupialgutz/draconis";
    platforms = platforms.linux;
  };
}
