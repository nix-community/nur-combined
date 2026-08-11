{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "anacrolix-torrent";
  version = "1.59.1";

  src = fetchFromGitHub {
    owner = "anacrolix";
    repo = "torrent";
    rev = "v${version}";
    # the go.work file was added on 2025-08-21
    # the last stable release 1.59.1 is from 2025-08-18
    # rev = "414bd5781457f9b0fd7d3a20dab019f6963018cc";
    hash = "sha256-en0p7i7Wvvw+s6226vqV+fKDZv5IuJ+VnakeOYQw8F8=";
    # no: main module (github.com/anacrolix/torrent) does not contain package github.com/anacrolix/torrent/storage/possum/lib/go
    # fetchSubmodules = true;
  };

  # no: main module (github.com/anacrolix/torrent) does not contain package github.com/anacrolix/torrent/storage/possum/lib/go
  # fix: go: 'go mod vendor' cannot be run in workspace mode. Run 'go work vendor' to vendor the workspace or set 'GOWORK=off' to exit workspace mode.
  # https://github.com/NixOS/nixpkgs/issues/299096
  # env.GOWORK = "off";

  vendorHash = "sha256-tC7mJYi9uFALJsb/9t1GPWABmYgXF5Pb8UQvuOZnjPs=";

  # FIXME go: go.work requires go >= 1.24.5 (running go 1.24.4; GOTOOLCHAIN=local)
  /*
  # fix: main module (github.com/anacrolix/torrent) does not contain package github.com/anacrolix/torrent/storage/possum/lib/go
  # https://github.com/NixOS/nixpkgs/pull/291409
  overrideModAttrs = (_: {
    buildPhase = ''
      go work vendor -e
    '';
  });
  */

  # fix: main module (github.com/anacrolix/torrent) does not contain package github.com/anacrolix/torrent/tests/add-webseed-after-priorities
  # fix: main module (github.com/anacrolix/torrent) does not contain package github.com/anacrolix/torrent/tests/webseed-partial-seed
  preBuild = ''
    rm -rf tests
  '';

  # fix: torrentfs_test.go:108: fusermount: exec: "fusermount": executable file not found in $PATH
  doCheck = false;

  ldflags = [ "-s" "-w" ];

  meta = {
    description = "Full-featured BitTorrent client package and utilities";
    homepage = "https://github.com/anacrolix/torrent";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "torrent";
  };
}
