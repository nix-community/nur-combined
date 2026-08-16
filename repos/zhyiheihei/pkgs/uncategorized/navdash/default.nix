{
  lib,
  buildGoModule,
  sources,
}:
buildGoModule (finalAttrs: {
  pname = "navdash";
  inherit (sources.navdash) version src;

  # Pure Go standard library only; no dependencies to vendor.
  vendorHash = null;

  env.CGO_ENABLED = "0";

  ldflags = [
    "-s"
    "-w"
    "-buildid="
  ];

  meta = {
    description = "Personal service portal with native OIDC login and Nix-generated service cards";
    homepage = "https://github.com/zhyiheihei/navdash";
    changelog = "https://github.com/zhyiheihei/navdash/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [
      {
        github = "zhyiheihei";
        name = "zhyiheihei";
      }
    ];
    mainProgram = "navdash";
    platforms = lib.platforms.linux;
  };
})
