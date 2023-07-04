{ lib, glib, webkitgtk, cairo, libsoup, fetchFromGitHub, rustPlatform, udev, pkg-config, openssl }:

rustPlatform.buildRustPackage rec {
  pname = "mip";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "mipmip";
    repo = "mip.rs";
    rev = "c3426cfc391243f08e43465d08e320b64fca0810";
    hash = "sha256-qsXF0Ya+TNuWFEDMdXRkJHQec6DanD7ZQZNYmT+ijJo=";
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
