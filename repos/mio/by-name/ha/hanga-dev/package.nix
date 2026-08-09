{
  pkgs,
  lib,
  pkg-config,
  udev,
  alsa-lib,
  vulkan-loader,
  xorg,
  wayland,
  libxkbcommon,
  makeWrapper,
}:

let
  # Import the generated Cargo.nix file
  cargoNix = import ../hanga/Cargo.nix {
    inherit pkgs;
  };
in
cargoNix.workspaceMembers.hanga.build.override {
  crateOverrides = pkgs.defaultCrateOverrides // {
    hanga = attrs: {
      nativeBuildInputs = (attrs.nativeBuildInputs or []) ++ [ pkg-config makeWrapper ];
      buildInputs = (attrs.buildInputs or []) ++ [
        udev
        alsa-lib
        vulkan-loader
        xorg.libX11
        xorg.libXcursor
        xorg.libXi
        xorg.libXrandr
        wayland
        libxkbcommon
      ];
      postInstall = ''
        wrapProgram $out/bin/hanga \
          --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ vulkan-loader wayland libxkbcommon alsa-lib udev ]}
      '';
    };
    wayland-sys = attrs: {
      nativeBuildInputs = (attrs.nativeBuildInputs or []) ++ [ pkg-config ];
      buildInputs = (attrs.buildInputs or []) ++ [ wayland ];
    };
    alsa-sys = attrs: {
      nativeBuildInputs = (attrs.nativeBuildInputs or []) ++ [ pkg-config ];
      buildInputs = (attrs.buildInputs or []) ++ [ alsa-lib ];
    };
    x11-dl = attrs: {
      buildInputs = (attrs.buildInputs or []) ++ [ xorg.libX11 ];
    };
  };
}
