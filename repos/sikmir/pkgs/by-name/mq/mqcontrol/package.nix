{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "mqcontrol";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "albertnis";
    repo = "mqcontrol";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qztn2DSsna7VJnHPSQJn2vUVIAIOC+D4YLihcsagonk=";
  };

  vendorHash = "sha256-oLko4fdABrcrSs/hm8p4ELvhzB/VgWvEjIlA3u7DCGk=";

  meta = {
    description = "Cross-platform utility to execute commands remotely using MQTT";
    homepage = "https://github.com/albertnis/mqcontrol";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "mqcontrol";
  };
})
