{ lib, glib, webkitgtk, cairo, libsoup, fetchFromGitHub, rustPlatform, udev, pkg-config, openssl }:

rustPlatform.buildRustPackage rec {
  pname = "mip";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "mipmip";
    repo = "mip.rs";
    rev = "7c2fb9a1c984662be602be8b9ee4723e95d72010";
    hash = "sha256-2NZjlh2vQXYMue4yHvsEJCwzP7kQjIi/FnTYtBYcN1I=";
  };

  cargoSha256 = "sha256-cJzPFW46aZ/7Gs1J8fZ9Ja6HUzltWRH9+aGp6DPqPrk=";

  nativeBuildInputs = [ pkg-config glib cairo webkitgtk ];

  buildInputs = [ glib libsoup webkitgtk ];

  meta = with lib; {
    description = "Fast and suckless markdown viewer written in Rust.";
    homepage = "https://github.com/mipmip/mip.rs";
    license = with licenses; [ mit ];
  };

}
