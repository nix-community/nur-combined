{
  lib,
  buildGoModule,
}:
(buildGoModule {
  pname = "realm-helper";
  version = "0.1.0";

  src = lib.cleanSource ./.;
  # The helper uses the Go standard library only, so there is nothing to vendor.
  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Realm workload helper: socket bridge, container adapter, SPIRE enrollment";
    license = lib.licenses.mit;
    mainProgram = "realm-helper";
    platforms = lib.platforms.linux;
  };
}).overrideAttrs
  (previous: {
    # buildGoModule replaces the whole environment when `env` is passed as an
    # argument, so the static-linking switch is applied here instead. A static
    # binary is required: it is mounted into arbitrary container images and into
    # sandboxes that have no C library of their own.
    env = (previous.env or { }) // {
      CGO_ENABLED = "0";
    };
  })
