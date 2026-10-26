{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  version,
  hashes,
  extraPassthru ? { },
}:

let
  platform = with stdenv.hostPlatform.go; "${GOOS}-${if GOARCH == "arm" then "armv6l" else GOARCH}";
in
stdenv.mkDerivation {
  pname = "go-bin";
  inherit version;

  src = fetchurl {
    url = "https://go.dev/dl/go${version}.${platform}.tar.gz";
    hash =
      hashes.${platform} or (throw ''
        go-bin: Go ${version} has no recorded hash for platform ${platform}.
        Supply it from https://go.dev/dl/ with:

          pkgs.go-bin.fromGoRelease {
            version = "${version}";
            hashes."${platform}" = "sha256-…";
          }
      '');
  };

  # Preserve code signatures on Darwin.
  dontStrip = stdenv.hostPlatform.isDarwin;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/go $out/bin
    cp -r . $out/share/go

    # cmd/go downloads and switches to a different release when go.mod asks for
    # one. That defeats the point of pinning the toolchain here, so make
    # GOTOOLCHAIN=local the default. A caller that sets GOTOOLCHAIN explicitly
    # still gets that value. The real binary stays in share/go so GOROOT is
    # inferred correctly.
    makeWrapper $out/share/go/bin/go $out/bin/go --set-default GOTOOLCHAIN local
    ln -s $out/share/go/bin/gofmt $out/bin/gofmt

    runHook postInstall
  '';

  inherit (stdenv.hostPlatform.go) GOOS GOARCH;
  CGO_ENABLED = 1;

  passthru = extraPassthru // {
    inherit version;
  };

  meta = {
    description = "Go toolchain (prebuilt binary)";
    homepage = "https://go.dev/";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
    maintainers = [ ];
    mainProgram = "go";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
