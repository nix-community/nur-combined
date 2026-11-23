{
  # keep-sorted start
  lib,
  rustPlatform,
  src,
  # keep-sorted end
}: let
  inherit (rustPlatform) buildRustPackage;

  root = "${src}/native/render";
in
  buildRustPackage {
    pname = "albedo-render";
    version = "0.1.0";

    src = root;

    meta.license = import ./license.nix {inherit lib;};

    postInstall = import ./install-notices.nix {
      dependencyRoot = "$cargoDeps";
      pname = "albedo-render";
      inherit src;
    };

    cargoHash = "sha256-zCG5qPdG2bpG8elx//sXczRiTITh4Rp2MozmPLGCgtk=";

    # Fat LTO and one codegen unit trade build time for runtime speed over
    # upstream's thin LTO.
    env = {
      # keep-sorted start
      CARGO_PROFILE_RELEASE_CODEGEN_UNITS = "1";
      CARGO_PROFILE_RELEASE_LTO = "fat";
      # keep-sorted end
    };
  }
