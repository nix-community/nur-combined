{ lib, glib, webkitgtk, cairo, libsoup, fetchFromGitHub, rustPlatform, udev, pkg-config, openssl }:

rustPlatform.buildRustPackage rec {
  pname = "mip";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "mipmip";
    repo = "mip.rs";
    rev = "82a37b615cdfaddefc29154cbef1c752d27a97ad";
    hash = "sha256-Fh1DAmvYmuANsz0y24+VSFJTMxQnYq7xKztqFyE7hNc=";
  };

  cargoSha256 = "sha256-ih11UIFHQI7H26v1cHjTQMNeD/0L84M6d5bek6mCMsg=";

  nativeBuildInputs = [ pkg-config glib cairo webkitgtk ];

  buildInputs = [ glib libsoup webkitgtk ];

  meta = with lib; {
    description = "Fast and suckless markdown viewer written in Rust.";
    homepage = "https://github.com/mipmip/mip.rs";
    license = with licenses; [ mit ];
  };

}
