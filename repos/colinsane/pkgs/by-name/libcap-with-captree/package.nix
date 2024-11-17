# libcap nix package should eventually ship `captree`, but until then, patch it.
# this is a re-implementation of an outstanding PR, but in a way that doesn't force mass-rebuilds:
# - <https://github.com/NixOS/nixpkgs/pull/332399>
{
  libcap,
  go,
}: libcap.overrideAttrs (base: {
  depsBuildBuild = base.depsBuildBuild ++ [ go ];

  makeFlags = base.makeFlags ++ [
    "GOLANG=yes"
    ''GOCACHE=''${TMPDIR}/go-cache''
    "GOARCH=${go.GOARCH}"
    "GOOS=${go.GOOS}"
  ];

  postPatch = base.postPatch + ''
    # disable cross compilation for artifacts which are run as part of the build
    substituteInPlace go/Makefile \
      --replace-fail '$(GO) run' 'GOOS= GOARCH= $(GO) run'
  '';
})
