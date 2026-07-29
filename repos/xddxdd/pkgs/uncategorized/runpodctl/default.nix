{
  sources,
  lib,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  inherit (sources.runpodctl) pname version src;

  vendorHash = "sha256-aCrN521urP1FioTmbcR1BNKg+OCith1mabyayuC9FtI=";

  postFixup = ''
    rm -f $out/bin/docs
  '';

  meta = {
    changelog = "https://github.com/runpod/runpodctl/releases/tag/v${finalAttrs.version}";
    description = "RunPod CLI for pod management";
    homepage = "https://www.runpod.io";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "runpodctl";
  };
})
