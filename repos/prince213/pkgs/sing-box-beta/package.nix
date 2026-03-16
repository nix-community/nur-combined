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
  version = "1.14.0-alpha.3";

  src = previousAttrs.src.override {
    hash = "sha256-mxe5R8gj00p76+nR4y2FJNBQ1yOUn3taWxn9gGhgYG0=";
  };

  vendorHash = "sha256-jFPomA53p7OxA53Ko0b5BGA+UsTE2h/yZFBgf6W22TI=";

  preBuild =
    (previousAttrs.preBuild or "")
    + lib.optionalString withNaiveOutbound ''
      if test -d vendor; then
        cd vendor/github.com/sagernet/cronet-go
        chmod -R u+w .
        cp -r ${cronet-go}/ .
        ${lib.optionalString (!withStaticCronet) ''
          patch -p1 < ${./cronet-go.patch}
          substituteInPlace internal/cronet/loader_unix.go \
            --subst-var out
        ''}
        cd ../../../..
      fi
    '';

  nativeBuildInputs =
    previousAttrs.nativeBuildInputs
    ++ lib.optional (withNaiveOutbound && withStaticCronet) buildPackages.rustc.llvmPackages.bintools;

  buildInputs =
    (previousAttrs.buildInputs or [ ])
    ++ lib.optional (withNaiveOutbound && withStaticCronet) cronet-go;

  tags =
    previousAttrs.tags
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
