{ stdenv, rustPlatform, fetchFromGitHub, gtk3, gnome3, wrapGAppsHook, ... }:
rustPlatform.buildRustPackage rec {
  name = "neovim-gtk-unstable-${version}";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "daa84";
    repo = "neovim-gtk";
    rev = "6a7804c6e797142724548b09109cf2883cd6f08c";
    sha256 = "0idn0j41h3bvyhcq2k0ywwnbr9rg9ci0knphbf7h7p5fd4zrfb30";
  };

  cargoSha256 = "1gsnr2j68kfx2w2r2pv11rln0qlmgq05van2f3h0f7jk5c7rs4yb";

  nativeBuildInputs = [ wrapGAppsHook ];
  buildInputs = [ gtk3 gnome3.vte ];

  postInstall = ''
    mkdir -p $out/share/nvim-gtk/
    cp -r runtime $out/share/nvim-gtk/
    mkdir -p $out/share/applications/
    sed -e "s|Exec=nvim-gtk|Exec=$out/bin/nvim-gtk|" \
		desktop/org.daa.NeovimGtk.desktop \
        >$out/share/applications/org.daa.NeovimGtk.desktop
    mkdir -p $out/share/icons/hicolor/128x128/apps/
	cp desktop/org.daa.NeovimGtk_128.png $out/share/icons/hicolor/128x128/apps/org.daa.NeovimGtk.png
	mkdir -p $out/share/icons/hicolor/48x48/apps/
	cp desktop/org.daa.NeovimGtk_48.png $out/share/icons/hicolor/48x48/apps/org.daa.NeovimGtk.png
	mkdir -p $out/share/icons/hicolor/scalable/apps/
	cp desktop/org.daa.NeovimGtk.svg $out/share/icons/hicolor/scalable/apps/
	mkdir -p $out/share/icons/hicolor/symbolic/apps/
	cp desktop/org.daa.NeovimGtk-symbolic.svg $out/share/icons/hicolor/symbolic/apps/
  '';

  meta = with stdenv.lib; {
    description = "GTK+ UI for Neovim";
    homepage = https://github.com/daa84/neovim-gtk;
    license = with licenses; [ gpl3 ];
    platforms = platforms.linux;
  };
}
