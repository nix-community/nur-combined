{ stdenv, rustPlatform, fetchFromGitHub, gtk3, gnome3, wrapGAppsHook, oldCargoVendor ? false, ... }:
rustPlatform.buildRustPackage rec {
  name = "neovim-gtk-unstable-${version}";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "daa84";
    repo = "neovim-gtk";
    rev = "6a7804c6e797142724548b09109cf2883cd6f08c";
    sha256 = "0idn0j41h3bvyhcq2k0ywwnbr9rg9ci0knphbf7h7p5fd4zrfb30";
  };

  # different hashes because of breaking change in cargo-vendor
  # https://github.com/NixOS/nixpkgs/issues/60668
  cargoSha256 = if oldCargoVendor then "0rnmfqdc6nwvbhxpyqm93gp7zr0ccj6i94p9zbqy95972ggp02df"
                                  else "0js581whb6bg65bby2zyssxxrxjcgk925mgv1ds5djdj3bin42ig";

  nativeBuildInputs = [ wrapGAppsHook ];
  buildInputs = [ gtk3 gnome3.vte ];

  meta = with stdenv.lib; {
    description = "GTK+ UI for Neovim";
    homepage = https://github.com/daa84/neovim-gtk;
    license = with licenses; [ gpl3 ];
    platforms = platforms.linux;
  };
}
