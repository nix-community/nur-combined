{
  # cairo,
  fetchFromGitHub,
  # gtk3,
  lib,
  libglvnd,
  # libgbm,
  libxkbcommon,
  # fontconfig,
  # freetype,
  # pango,
  pkg-config,
  rustPlatform,
  # vulkan-headers,
  vulkan-loader,
  wayland,
  wayland-scanner,
  wayland-protocols,
  # wrapGAppsHook3,
  # xorg,
}:

rustPlatform.buildRustPackage rec {
  pname = "mslicer";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "connorslade";
    repo = pname;
    rev = version;
    hash = "sha256-x46k1O7EqXMEwNATG4b7zHIYaMDVveRiq/Z5KPih0Fo=";
  };

  cargoHash = "sha256-mRbEwxR6bMkybxe7H1dX4Qa1elGiw/lSSz9sSTtp1zw=";
  useFetchCargoVendor = true;

  buildInputs = [
    # cairo
    # gtk3
    libglvnd
    # libgbm
    libxkbcommon
    # xorg.libX11
    # xorg.libXcursor
    # xorg.libXi
    # xorg.libxcb
    # xorg.libXrender
    # fontconfig
    # freetype
    # openssl
    # pango
    # vulkan-headers
    vulkan-loader
    wayland
    # wayland-protocols
  ];

  # from pkgs/by-name/al/alvr/package.nix, to get it to actually link against wayland
  # RUSTFLAGS = map (a: "-C link-arg=${a}") [
  #   "-Wl,--push-state,--no-as-needed"
  #   # "-lEGL"
  #   "-lwayland-client"
  #   # "-lxkbcommon"
  #   "-Wl,--pop-state"
  # ];

  # Force linking to libEGL, which is always dlopen()ed, and to
  # libwayland-client & libxkbcommon, which is dlopen()ed based on the
  # winit backend.
  # from <repo:nixos/nixpkgs:pkgs/by-name/uk/ukmm/package.nix>
  NIX_LDFLAGS = [
    "--push-state"
    "--no-as-needed"
    "-lEGL"
    "-lvulkan"
    "-lwayland-client"
    "-lxkbcommon"
    "--pop-state"
  ];

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    # spot-check the binaries
    $out/bin/goo_format --help
    # these other binaries can't be invoked w/ interactivity or real data:
    test -x $out/bin/mslicer
    test -x $out/bin/remote_send
    test -x $out/bin/slicer

    runHook postInstallCheck
  '';

  strictDeps = true;

  meta = with lib; {
    description = "An experimental open source slicer for masked stereolithography (resin) printers.";
    homepage = "https://connorcode.com/projects/mslicer";
    maintainers = with maintainers; [ colinsane ];
  };
}
