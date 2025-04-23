{
  fetchFromGitHub,
  lib,
  libglvnd,
  libxkbcommon,
  nix-update-script,
  rustPlatform,
  vulkan-loader,
  wayland,
}:

rustPlatform.buildRustPackage {
  pname = "mslicer";
  version = "0.2.1-unstable-2025-04-13";

  src = fetchFromGitHub {
    owner = "connorslade";
    repo = "mslicer";
    rev = "ce1f43e61ca83b727561ff0aa193512c8b164331";
    hash = "sha256-VgbHFUQpxlQcYh3TNyw1IX7vyaWrHRxl4Oe5jake9Qg=";
  };

  cargoHash = "sha256-Bs/mQTMEQxRvKK9ibIAf4KLv9jzGv3hnduXFYEdjljc=";
  useFetchCargoVendor = true;

  buildInputs = [
    libglvnd
    libxkbcommon
    vulkan-loader
    wayland
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

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = with lib; {
    description = "An experimental open source slicer for masked stereolithography (resin) printers.";
    homepage = "https://connorcode.com/projects/mslicer";
    maintainers = with maintainers; [ colinsane ];
  };
}
