{ lib
, buildGoModule
, installShellFiles
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "etime";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "zimeg";
    repo = "emporia-time";
    rev = "refs/tags/v${version}";
    hash = "sha256-3aEcnXC894mZw+KE2MCOt2j0ue4H1xyADGeGpBHcEsI=";
  };

  vendorHash = "sha256-quw9iD00l5bFSYZQ1mLAs3nY8Q3roiMsSjOZqmt+ED4=";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=v${version}"
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    mv $out/bin/emporia-time $out/bin/etime
    installManPage etime.1
  '';

  meta = with lib; {
    description = "an energy aware `time` command";
    homepage = "https://github.com/zimeg/emporia-time";
    changelog = "https://github.com/zimeg/emporia-time/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "etime";
  };
}
