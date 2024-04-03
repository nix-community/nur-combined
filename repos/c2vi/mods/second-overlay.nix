

{ nixpkgs, ... }: final: prev: {
  #at-spi2-core = prev.at-spi2-core.override {
    #withIntrospection = false;
  #};

  /*
  gsettings-desktop-schemas = prev.gsettings-desktop-schemas.override {
    withIntrospection = true;
    #gobject-introspection = prev.callPackage ./static/gobject-introspection.nix { inherit nixpkgs; };
    gobject-introspection = prev.callPackage ./static/gobject-introspection.nix { inherit nixpkgs; };
  };
  */
  /*
  gsettings-desktop-schemas = prev.gsettings-desktop-schemas.overrideAttrs (innerFinal: innerPrev: {
    nativeBuildInputs = with prev; [
      glib
      meson
      ninja
      pkg-config
      gobject-introspection
      (prev.callPackage ./static/gobject-introspection.nix { inherit nixpkgs; })
    ];
  });
  */
}
