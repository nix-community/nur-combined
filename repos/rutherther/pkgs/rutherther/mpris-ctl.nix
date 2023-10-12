{ lib
, pkgs
, stdenv
, clangStdenv
, rustPlatform
, hostPlatform
, targetPlatform
, pkg-config
, dbus
, rustfmt
, cargo
, rustc
}:

rustPlatform.buildRustPackage rec {
  name = "mpris-ctl";
  version = "0.1.0";

  src = pkgs.fetchFromGitHub {
    owner = "Rutherther";
    repo = "mpris-ctl";
    rev = "c5731a17d99553d79810791e5a5aff61344669d5";
    hash = "sha256-vxNpZ6VsGxqFoxl1IpWTqU4iS2g4rfepLXuzPrpvbko=";
  };

  cargoHash = "sha256-QvnaySHqErWuwPBzd1l/asfBbt86c53TKwIyFBvBwQ0=";

  nativeBuildInputs = [
    rustfmt
    pkg-config
    cargo
    rustc
    dbus
  ];

  checkInputs = [ cargo rustc dbus ];
  doCheck = true;
}
