{
  # keep-sorted start
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

    cargoHash = "sha256-5UOrvLYnUaf64fiDAaN4FqKxqp2B1G+uBSU/7MjBg6Q=";
  }
