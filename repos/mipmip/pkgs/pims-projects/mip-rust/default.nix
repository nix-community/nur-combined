{ lib, glib, webkitgtk, cairo, libsoup, fetchFromGitHub, rustPlatform, udev, pkg-config, openssl }:

rustPlatform.buildRustPackage rec {
  pname = "mip";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "mipmip";
    repo = "mip.rs";
    rev = "3d77218c7404fb14fec5aa72bb91e0748cdb220b";
    hash = "sha256-84ak0EIY0v5kAQJfDuM89fe9k50Elp1+dzDYTShXzXM=";
  };

  cargoSha256 = "sha256-fzfNHukLWrmli6o9XE0iSQDheFMy91awU3R4UA9jN0k=";

  nativeBuildInputs = [ pkg-config glib cairo webkitgtk ];

  buildInputs = [ glib libsoup webkitgtk ];

  meta = with lib; {
    description = "Fast and suckless markdown viewer written in Rust.";
    homepage = "https://github.com/mipmip/mip.rs";
    license = with licenses; [ mit ];
  };

}
