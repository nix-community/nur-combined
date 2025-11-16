{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "fabric-cli";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "Fabric-Development";
    repo = "fabric-cli";
    rev = "9f5ce4d46e146e2d3689de730cda78c75a123fb9";
    hash = "sha256-C4JO82RMuEh+S+MUUHuBaPuDhv48QKBlxRqYgrjyqPk=";
  };

  vendorHash = "sha256-5luc8FqDuoKckrmO2Kc4jTmDmgDjcr3D4v5Z+OpAOs4=";

  meta = {
    description = "An alternative super-charged CLI for Fabric ";
    longDescription = ''
      Fabric CLI is a tool to interface with running fabric instances.
      This enables e.g. invoking actions or executing python code within a running instance.
    '';
    homepage = "https://github.com/Fabric-Development/fabric-cli";
    license = lib.licenses.agpl3Only;
    mainProgram = "fabric-cli";
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
}
