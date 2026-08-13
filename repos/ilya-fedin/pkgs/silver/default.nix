{ lib, fetchFromGitHub, rustPlatform, pkg-config, openssl }:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "silver";
  version = "2.0.0-unstable-2024-02-21";

  src = fetchFromGitHub {
    owner = "reujab";
    repo = finalAttrs.pname;
    rev = "68d2f014cdf9f659dc4355bf08af3d20a35e6d23";
    hash = "sha256-1KHSr52fL4+6SwSOvLcECyk0vKqD3lREV2M+xNOKRRQ=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  cargoHash = "sha256-H7kVTXsLYoLH0mjIG/u6ZkUwr9L6zpSFFd3TJYY5eko=";

  meta = with lib; {
    description = "A cross-shell customizable powerline-like prompt with icons";
    homepage = https://github.com/reujab/silver;
    license = licenses.unlicense;
    platforms = platforms.unix;
  };
})
