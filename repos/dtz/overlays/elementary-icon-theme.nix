self: super: {
  elementary-icon-theme = super.elementary-icon-theme.overrideAttrs(o: rec {
    name = o.name + "-git";
    src = super.fetchFromGitHub {
      owner = "elementary";
      repo = "icons";
      rev = "8afc3260c031ff045c6aa1d7c5599226b41c3e70";
      sha256 = "0ab7a8c6s29xh4z7p71gr1r778mw5v212jjsr0l867zilgnjkcam";
    };

    nativeBuildInputs = with self; [ meson ninja python3 ];
    buildInputs = [ self.gtk3 ];
    postPatch = ''
      chmod +x ./meson/*
      patchShebangs ./meson/
    '';
    # Don't install these into root prefix (?!)
    mesonFlags = [ "-Dvolume_icons=false" ];
    postFixup = null;
  });
}
