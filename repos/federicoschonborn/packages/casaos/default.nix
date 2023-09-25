{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "casaos";
  version = "0.4.4-2";

  src = fetchFromGitHub {
    owner = "IceWhaleTech";
    repo = "CasaOS";
    rev = "v${version}";
    hash = "sha256-5I9zeXJ68xYD2BOIhmflIzoirAs+tRT6rWS/1KfvUpo=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-UJiYSLu8KLuG3i8xueOWAc9cO/7BEI/wsuUymdoP0Os=";

  postPatch = ''
    # Disable tests that require network access.
    rm service/health_test.go
  '';

  ldflags = [
    "-X=main.commit=${src.rev}"
    "-X=main.date=1970-01-01T00:00:00Z"
    "-s"
    "-w"
    "-extldflags"
    "-static"
  ];

  meta = with lib; {
    description = "CasaOS - A simple, easy-to-use, elegant open-source Personal Cloud system";
    homepage = "https://github.com/IceWhaleTech/CasaOS";
    changelog = "https://github.com/IceWhaleTech/CasaOS/blob/${src.rev}/CHANGELOG.md";
    mainProgram = "CasaOS";
    platforms = platforms.linux;
    license = licenses.asl20;
  };
}
