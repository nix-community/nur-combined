{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  pkg-config,
  stdenv,
}:
buildGoModule (finalAttrs: {
  pname = "zju-connect";
  version = "1.3.1";
  src = fetchFromGitHub {
    owner = "Mythologyli";
    repo = "zju-connect";
    rev = "v${finalAttrs.version}";
    hash = "sha256-BPBdydGiKRmVwRY4Fn41uCU0R06qyN/FLw5C97Sdltw=";
  };
  vendorHash = "sha256-6z7B8RC7hhZOGv+i5u/zap2qivoxRW6wHY4bCU4mLOI=";

  # TODO: remove once upstream merges the go.mod/go.sum fix:
  #   https://github.com/Mythologyli/zju-connect/pull/132
  # Upstream's go.mod/go.sum omits golang.org/x/sync, which is only pulled in
  # by github.com/miekg/dns' tools.go (//go:build tools) → golang.org/x/tools
  # → golang.org/x/sync. `go mod vendor` resolves that tool dependency and fails
  # with "missing go.sum entry", while the actual build never needs it. Using the
  # module proxy (`go mod download`) avoids vendoring those tool-only imports.
  proxyVendor = true;

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "zju-connect";
    description = "SSL VPN client based on EasierConnect";
    homepage = "https://github.com/Mythologyli/zju-connect";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.unix;
  };
})
