{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

# The launcher runs gvproxy for the VM's user-mode network. Upstream downloads
# the official v0.8.9 release binary; build the same tag from source instead.
buildGoModule (finalAttrs: {
  pname = "gvproxy";
  version = "0.8.9";

  src = fetchFromGitHub {
    owner = "containers";
    repo = "gvisor-tap-vsock";
    rev = "v${finalAttrs.version}";
    hash = "sha256-wWsxqMpHu+YY9LaiA8SohZSDCSJgYc/FnUkx6GzfhYw=";
  };

  # Upstream vendors its Go modules in the repository.
  vendorHash = null;

  subPackages = [ "cmd/gvproxy" ];

  meta = {
    description = "User-mode networking for virtual machines (gvisor-tap-vsock)";
    homepage = "https://github.com/containers/gvisor-tap-vsock";
    license = lib.licenses.asl20;
    mainProgram = "gvproxy";
    platforms = [ "aarch64-darwin" ];
  };
})
