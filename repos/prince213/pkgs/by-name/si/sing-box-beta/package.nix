{
  lib,
  go,
  sing-box,
  stdenvNoCC,

  # nativeBuildInputs
  buildPackages,

  # buildInputs
  cronet-go,

  withStaticCronet ? true,
  withNaiveOutbound ? true,
}:
assert lib.assertMsg (
  withNaiveOutbound -> !withStaticCronet -> stdenvNoCC.hostPlatform.isLinux
) "Dynamic linking to cronet-go is only available on Linux.";
sing-box.overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-beta.3";
  __structuredAttrs = true;

  src = previousAttrs.src.override {
    hash = "sha256-uEeFbAVCUJRGpORNjNgc6fu6k8pJytrIK4LEeNDijVQ=";
  };

  vendorHash = "sha256-n3w21uR5kwKyYU9OgiyuiImA1jPnf6eGIWzXbjWOloE=";

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
    ++ [
      "with_cloudflared"
      "with_usbip"
      "with_openvpn"
      "with_openconnect"
    ]
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
