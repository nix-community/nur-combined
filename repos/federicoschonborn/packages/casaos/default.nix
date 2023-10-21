{ lib
, buildGoModule
, fetchFromGitHub
, nix-update-script
}:

buildGoModule rec {
  pname = "casaos";
  version = "0.4.4-3";

  src = fetchFromGitHub {
    owner = "IceWhaleTech";
    repo = "CasaOS";
    rev = "v${version}";
    hash = "sha256-476JkGHoyaCkoSIU98PRGE2qW1HWc6fK8hSw5uwuihg=";
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

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CasaOS - A simple, easy-to-use, elegant open-source Personal Cloud system";
    homepage = "https://github.com/IceWhaleTech/CasaOS";
    changelog = "https://github.com/IceWhaleTech/CasaOS/blob/${src.rev}/CHANGELOG.md";
    mainProgram = "CasaOS";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
