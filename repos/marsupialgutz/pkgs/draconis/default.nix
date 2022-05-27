{ lib, fetchFromGitHub, rustPlatform, pkgconfig, dbus }:

rustPlatform.buildRustPackage rec {
  nativeBuildInputs = [
    pkgconfig
  ];

  buildInputs = [
    dbus
  ];

  pname = "draconis";
  version = "2.4.7";

  src = fetchFromGitHub {
    owner = "marsupialgutz";
    repo = "draconis";
    rev = "918fdc4bec4e79fa185b38679034f005747b44fa";
    sha256 = "1d3lmr9kd95dxfps0llljwmp9cb4ib3zdnlbmhqyn8gacklanp9s";
  };

  cargoSha256 = "im2N5i/c6Z7bUC2so6b5CuLQDt2PqjMhNbfV4hiA9UQ=";

  meta = with lib; {
    description = "🪐 An out-of-this-world greeter for your terminal";
    homepage = "https://github.com/marsupialgutz/draconis";
    platforms = platforms.linux;
  };
}
