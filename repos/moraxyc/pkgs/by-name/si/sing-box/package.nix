{
  buildPackages,
  cronet-go,
  lib,
  nixpkgs,
  stdenvNoCC,

  withStaticCronet ? true,
  withNaiveOutbound ? true,
}:
assert lib.assertMsg (
  !(withNaiveOutbound && !withStaticCronet) || stdenvNoCC.hostPlatform.isLinux
) "Dynamic linking to cronet-go is only available on Linux.";
nixpkgs.sing-box.overrideAttrs (previousAttrs: {
  postConfigure =
    (previousAttrs.postConfigure or "")
    + lib.optionalString withNaiveOutbound ''
      chmod -R u+w vendor/github.com/sagernet/cronet-go
      cp -r ${cronet-go}/. vendor/github.com/sagernet/cronet-go/
    ''
    + lib.optionalString (withNaiveOutbound && withStaticCronet) ''
      install -Dm644 ${lib.getStatic cronet-go}/lib/libcronet.a \
        vendor/github.com/sagernet/cronet-go/lib/${stdenvNoCC.hostPlatform.go.GOOS}_${stdenvNoCC.hostPlatform.go.GOARCH}/libcronet.a
    ''
    + lib.optionalString (withNaiveOutbound && !withStaticCronet) ''
      substituteInPlace vendor/github.com/sagernet/cronet-go/internal/cronet/loader_unix.go \
        --replace-fail 'searchPaths = append(searchPaths, filepath.Dir(executablePath))' 'searchPaths = append(searchPaths, "${cronet-go}/lib", filepath.Dir(executablePath))' \
        --replace-fail 'searchPaths = append(searchPaths, "/usr/local/lib", "/usr/lib")' '// searchPaths = append(searchPaths, "/usr/local/lib", "/usr/lib")'
    '';

  nativeBuildInputs =
    (previousAttrs.nativeBuildInputs or [ ])
    ++ lib.optional (
      withNaiveOutbound && withStaticCronet
    ) buildPackages.buildPackages.llvmPackages.bintools;

  tags =
    (previousAttrs.tags or [ ])
    ++ [ "with_cloudflared" ]
    ++ lib.optional withNaiveOutbound "with_naive_outbound"
    ++ lib.optional (withNaiveOutbound && !withStaticCronet) "with_purego";

  env =
    (previousAttrs.env or { })
    // lib.optionalAttrs (withNaiveOutbound && withStaticCronet) {
      CGO_ENABLED = 1;
      CGO_CFLAGS = "-I${lib.getDev cronet-go}/include/cronet-go";
      CGO_LDFLAGS = "-fuse-ld=lld";
    };

  passthru = (previousAttrs.passthru or { }) // {
    _ignoreOverride = true;
  };
})
