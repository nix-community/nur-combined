{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "casaos";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "IceWhaleTech";
    repo = "CasaOS";
    rev = "v${version}";
    hash = "sha256-TyuGAKHMSp3V6ZSv7ZK3YKYTvAy9ttPX3QxfwnGP3zw=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-qd9nessQ4mVYlI9RjQqtVcARot2j2cAbiKqTPaW496U";

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
