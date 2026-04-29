{
  lib,
  stdenv,
  fetchurl,
  version,
  hashes,
}:

let
  platform = with stdenv.hostPlatform.go; "${GOOS}-${if GOARCH == "arm" then "armv6l" else GOARCH}";
in
stdenv.mkDerivation {
  pname = "go-bin";
  inherit version;

  src = fetchurl {
    url = "https://go.dev/dl/go${version}.${platform}.tar.gz";
    hash = hashes.${platform} or (throw "Missing Go hash for platform ${platform}");
  };

  # Preserve code signatures on Darwin.
  dontStrip = stdenv.hostPlatform.isDarwin;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/go $out/bin
    cp -r . $out/share/go
    ln -s $out/share/go/bin/go $out/bin/go
    ln -s $out/share/go/bin/gofmt $out/bin/gofmt

    runHook postInstall
  '';

  inherit (stdenv.hostPlatform.go) GOOS GOARCH;
  CGO_ENABLED = 1;

  passthru = {
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
