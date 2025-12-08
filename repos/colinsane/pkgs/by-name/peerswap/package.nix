# based on: <https://github.com/fort-nix/nix-bitcoin/pull/462>
{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:

buildGoModule rec {
  pname = "peerswap";
  # the don't do releases yet
  version = "unstable-20240111";

  src = fetchFromGitHub {
    owner = "ElementsProject";
    repo = "peerswap";
    rev = "4d1270b9dd2986ce683f61e684996b5961b05db0";
    hash = "sha256-lnmimWtkc2hy+SPzXMeybetZldSLbcPEN5apKGFYo7k=";
  };

  subPackages = [
    "cmd/peerswaplnd/peerswapd"
    "cmd/peerswaplnd/pscli"
    "cmd/peerswap-plugin"  # this becomes the actual `peerswap` binary
  ];

  vendorHash = "sha256-OOwXWsFVxieOtzF7arXVNeWo4YB/EQbxQMAIxDVIhfg=";
  proxyVendor = true;

  postPatch = ''
    # upstream Makefile builds with `-ldflags "-X main.GitCommit=<hash>"`, but we bypass Makefile and have to do that manually.
    # GOFLAGS or CGO_LDFLAGS could both sort of do this, but they struggle with the spaces/quoting of the above,
    # so instead i manually patch in the values
    substituteInPlace cmd/peerswap-plugin/main.go \
      --replace-fail 'var GitCommit string' 'var GitCommit string = "${src.rev}"'
    substituteInPlace cmd/peerswaplnd/peerswapd/main.go \
      --replace-fail 'var GitCommit string' 'var GitCommit string = "${src.rev}"'
    substituteInPlace cmd/peerswaplnd/pscli/main.go \
      --replace-fail 'var GitCommit string' 'var GitCommit string = "${src.rev}"'
  '';

  postInstall = ''
    # the upstream Makefile compiles peerswap-plugin/main.go into a binary named `peerswap`,
    # but since we use buildGoModule, that doesn't go through the Makefile and we have to manually rename.
    mv $out/bin/peerswap-plugin $out/bin/peerswap
  '';

  meta = with lib; {
    description = "PeerSwap enables Lightning Network nodes to balance their channels by facilitating atomic swaps with direct peers.";
    homepage = "https://peerswap.dev";
    maintainers = with maintainers; [ colinsane ];
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
