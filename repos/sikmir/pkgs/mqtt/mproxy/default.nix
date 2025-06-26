{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "mproxy";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "mainflux";
    repo = "mproxy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ImZbgl+8W2ApqF5s70WGYVLbS1kN5VEXOO28LYtGozM=";
  };

  vendorHash = null;

  postInstall = ''
    mv $out/bin/{cmd,mproxy}
    mv $out/bin/{client,mproxy-client}
  '';

  meta = {
    description = "MQTT proxy";
    homepage = "https://github.com/mainflux/mproxy";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "mproxy";
  };
})
