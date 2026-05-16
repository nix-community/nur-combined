{
  lib,
  buildGoLatestModule,
  callPackage,
  clang,
  gotools,
  nixpkgs,

  sources,
  source ? sources.daed,
}:

buildGoLatestModule (finalAttrs: {
  inherit (source) pname version src;

  sourceRoot = "${finalAttrs.src.name}/wing";

  prePatch = ''
    substituteInPlace graphql/service/config/global/global.go \
      --replace-fail "go run -mod=mod golang.org/x/tools/cmd/goimports" "goimports"
  '';

  postConfigure = ''
    rm -rf dist
    cp -r ${finalAttrs.passthru.web} dist
    chmod -R u+w dist
  '';

  vendorHash = "sha256-+YQ/Ia54N/QKwd9p4AePg3CMjQvc4mFE1EcA/JPc8Po=";
  proxyVendor = true;

  nativeBuildInputs = [
    clang
    gotools
  ];

  hardeningDisable = [ "zerocallusedregs" ];

  buildPhase = ''
    runHook preBuild

    make SHELL="$SHELL" \
      CFLAGS="-D__REMOVE_BPF_PRINTK -fno-stack-protector -Wno-unused-command-line-argument" \
      NOSTRIP=y \
      WEB_DIST=dist \
      AppName=daed \
      VERSION=${finalAttrs.version} \
      OUTPUT=$out/bin/daed \
      bundle

    runHook postBuild
  '';

  postInstall = ''
    install -Dm444 $src/install/daed.service -t $out/lib/systemd/system
    substituteInPlace $out/lib/systemd/system/daed.service --replace-fail /usr/bin $out/bin
  '';

  passthru = {
    # nix-update auto --subpackage=web.pnpmDeps
    web = callPackage ./web.nix {
      inherit (finalAttrs) pname version src;
    };
    _ignoreOverride = true;
  };

  meta = nixpkgs.daed.meta // {
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
