{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finallAttrs: {
  pname = "fabric-cli";
  version = "0-unstable-2026-08-26";

  src = fetchFromGitHub {
    owner = "Fabric-Development";
    repo = "fabric-cli";
    rev = "9f5ce4d46e146e2d3689de730cda78c75a123fb9";
    hash = "sha256-C4JO82RMuEh+S+MUUHuBaPuDhv48QKBlxRqYgrjyqPk=";
  };

  vendorHash = "sha256-5luc8FqDuoKckrmO2Kc4jTmDmgDjcr3D4v5Z+OpAOs4=";

  ldflags = [
    "-s"
    "-w"
    "-compressdwarf=false"
    "-linkmode external"
  ];

  postInstall = ''
    mv $out/bin/src $out/bin/fabric-cli
  '';

  meta = {
    description = "An alternative super-charged CLI for Fabric";
    homepage = "https://github.com/Fabric-Development/fabric-cli";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ claymorwan ];
  };
})
