{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,

  sources,
  source ? sources.cpa-reductant,
}:
buildGoModule (finalAttrs: {
  inherit (source)
    pname
    version
    src
    vendorHash
    ;

  proxyVendor = true;

  postPatch = ''
    mkdir -p .cache
    cp -r ${finalAttrs.passthru.magpieSrc} .cache/magpie
    chmod -R u+w .cache/magpie
    for patch in patches/magpie/*.patch; do
      patch -d .cache/magpie -p1 < "$patch"
    done
  '';

  env.CGO_ENABLED = "1";

  # go install -buildmode=c-shared refuses main packages outside GOPATH without -o
  buildPhase = ''
    runHook preBuild

    go build -buildvcs=false -buildmode=c-shared \
      -ldflags "-s -w -X github.com/moraxyc/cpa-reductant/internal/config.Version=${finalAttrs.version}" \
      -o cpa-reductant${stdenv.hostPlatform.extensions.sharedLibrary} ./cmd/plugin

    runHook postBuild
  '';

  checkPhase = ''
    runHook preCheck

    export GOFLAGS=''${GOFLAGS//-trimpath/}
    go test ${
      lib.optionalString (stdenv.hostPlatform.isx86_64 || stdenv.hostPlatform.isAarch64) "-race "
    }-v ./internal/...

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    target="$out/lib/cliproxyapi/plugins/${stdenv.hostPlatform.go.GOOS}/${stdenv.hostPlatform.go.GOARCH}"
    install -Dm755 cpa-reductant${stdenv.hostPlatform.extensions.sharedLibrary} "$target/cpa-reductant${stdenv.hostPlatform.extensions.sharedLibrary}"
    install -Dm644 cpa-reductant.h "$out/include/cpa-reductant.h"

    runHook postInstall
  '';

  passthru = {
    magpieLock = (lib.importJSON source.artifacts."magpie.json").nodes.magpie.locked;
    magpieSrc = fetchFromGitHub {
      inherit (finalAttrs.passthru.magpieLock) owner repo rev;
      hash = finalAttrs.passthru.magpieLock.narHash;
    };
  };

  meta = {
    description = "CLIProxyAPI reversible redaction plugin powered by Magpie";
    homepage = "https://github.com/Moraxyc/cpa-reductant";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
