{ lib, glib, webkitgtk, cairo, libsoup, fetchFromGitHub, rustPlatform, udev, pkg-config, openssl }:

rustPlatform.buildRustPackage rec {
  pname = "mip";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "mipmip";
    repo = "mip.rs";
    rev = "fed2c56f0d1b2151f9add15eacf2cb000ffc12ea";
    hash = "sha256-t2qDn6x4eNbMF6LLhgVarJbEt3qwqQJOzi8JEbU+yiE=";
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
