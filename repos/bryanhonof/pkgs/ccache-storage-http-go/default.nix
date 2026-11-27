{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "ccache-storage-http-go";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "ccache";
    repo = "ccache-storage-http-go";
    rev = "v${finalAttrs.version}";
    hash = "sha256-YTq8oPvf+8warK7QhLildNn8p9k22o56nl4V3l7pt3U=";
  };

  vendorHash = "sha256-wkIQuV7/Xf7wzuGjp2NbAcc3IbChuLi89Z2LoMwkNbU=";

  ldflags = [
    "-s"
    "-w"
  ];

  # The integration tests bind Unix sockets under t.TempDir(); the darwin build
  # dir is too long for sun_path's 104 bytes.
  preCheck = lib.optionalString stdenv.hostPlatform.isDarwin ''
    export TMPDIR=$(mktemp -d /tmp/c.XXXXXX)
  '';

  __darwinAllowLocalNetworking = true;

  # ccache locates the helper by URL scheme, so the binary has to be named after
  # the scheme it handles. Upstream's `make install` does the same.
  postInstall = ''
    mv $out/bin/ccache-storage-http-go $out/bin/ccache-storage-http
    ln -s ccache-storage-http $out/bin/ccache-storage-https
  '';

  meta = with lib; {
    description = "ccache remote storage helper for HTTP/HTTPS storage";
    homepage = "https://github.com/ccache/ccache-storage-http-go";
    license = licenses.mit;
    maintainers = with maintainers; [ bryanhonof ];
    platforms = platforms.unix;
    mainProgram = "ccache-storage-http";
  };
})
