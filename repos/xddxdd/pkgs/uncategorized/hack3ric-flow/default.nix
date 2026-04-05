{
  sources,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  inherit (sources.hack3ric-flow) pname version src;

  cargoHash = "sha256-FEc5j2tMRCfU2nRYC/0gbdk4BkF99R88dWdJzgDUoVU=";

  # Check requires netlink privileges
  doCheck = false;

  postFixup = ''
    rm -f $out/bin/DONTSHIPIT*
  '';

  meta = {
    changelog = "https://github.com/hack3ric/flow/releases/tag/v${finalAttrs.version}";
    mainProgram = "flow";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "BGP flowspec executor";
    homepage = "https://github.com/hack3ric/flow";
    license = lib.licenses.bsd2;
  };
})
