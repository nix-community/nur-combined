{
  sources,
  lib,
  buildGoModule,
}:

buildGoModule {
  inherit (sources.runpodctl) pname version src;

  vendorHash = "sha256-OGUt+L0wP6eQkY/HWL+Ij9z9u+wsQ5OLK/IAq+1ezVA=";

  postFixup = ''
    rm -f $out/bin/docs
  '';

  meta = with lib; {
    description = "RunPod CLI for pod management";
    homepage = "https://www.runpod.io";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ xddxdd ];
    mainProgram = "runpodctl";
  };
}
