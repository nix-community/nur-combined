self: super: {
  elementary-gtk-theme = super.elementary-gtk-theme.overrideAttrs(o: rec {
    name = o.name + "-git";
    src = super.fetchFromGitHub {
      owner = "elementary";
      repo = "stylesheet";
      rev = "d8be6eb36531e347e777f412f6f0d8af05553371";
      sha256 = "106lsayy6gcwfnv7ixxm7lgzwyi57by0sa37rzw9naa8fr7a2ki5";
    };

    nativeBuildInputs = with self; [ meson ninja ];
    buildInputs = [ self.gtk3 ];
    installPhase = null;
    dontBuild = false;
  });
}
