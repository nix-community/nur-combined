{
  sources,
  lib,
  buildGoModule,
}:

buildGoModule rec {
  inherit (sources.runpodctl) pname version src;

  vendorHash = "sha256-8/OrM8zrisAfZdeo6FGP6+quKMwjxel1BaRIY+yJq5E=";

  postFixup = ''
    rm -f $out/bin/docs
  '';

  meta = {
    changelog = "https://github.com/runpod/runpodctl/releases/tag/v${version}";
    description = "RunPod CLI for pod management";
    homepage = "https://www.runpod.io";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "runpodctl";
  };
}
