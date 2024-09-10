{
  sources,
  lib,
  buildGoModule,
}:

buildGoModule {
  inherit (sources.runpodctl) pname version src;

  vendorHash = "sha256-8/OrM8zrisAfZdeo6FGP6+quKMwjxel1BaRIY+yJq5E=";

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
