{
  buildPackages,
  cronet-go,
  go,
  lib,
  sing-box,
  stdenvNoCC,

  withStaticCronet ? true,
  withNaiveOutbound ? true,
}:
assert lib.assertMsg (
  withNaiveOutbound -> !withStaticCronet -> stdenvNoCC.hostPlatform.isLinux
) "Dynamic linking to cronet-go is only available on Linux.";
sing-box.overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-alpha.22";

  src = previousAttrs.src.override {
    hash = "sha256-C61s/1/GX1zdFW3xZlKGLAF70Wv/lZsFPZGO0LFUsow=";
  };

  vendorHash = "sha256-ltqwoTq5Qb43U2TUoa+axIjG30T9TxuXXIIW+UCJF+s=";

  postConfigure =
    (previousAttrs.postConfigure or "")
    + lib.optionalString withNaiveOutbound ''
      pushd vendor/github.com/sagernet/cronet-go
      chmod -R u+w .
      cp -r ${cronet-go}/ .
      # for !withStaticCronet
      patch -p1 < ${./cronet-go.patch}
      substituteInPlace internal/cronet/loader_unix.go \
        --subst-var out
      popd
    '';

  nativeBuildInputs =
    previousAttrs.nativeBuildInputs
    ++ lib.optional (withNaiveOutbound && withStaticCronet) buildPackages.rustc.llvmPackages.bintools;

  buildInputs =
    (previousAttrs.buildInputs or [ ])
    ++ lib.optional (withNaiveOutbound && withStaticCronet) cronet-go;

  tags =
    previousAttrs.tags
    ++ [ "with_cloudflared" ]
    ++ lib.optional withNaiveOutbound "with_naive_outbound"
    ++ lib.optional (withNaiveOutbound && !withStaticCronet) "with_purego";

  postInstall =
    previousAttrs.postInstall
    + lib.optionalString (withNaiveOutbound && !withStaticCronet) ''
      ln -s "${cronet-go}/lib/${go.GOOS}_${go.GOARCH}/libcronet.so" "$out/lib/"
    '';

  env =
    previousAttrs.env
    // lib.optionalAttrs (withNaiveOutbound && withStaticCronet) {
      CGO_ENABLED = 1;
      CGO_LDFLAGS = "-fuse-ld=lld";
    };
})
