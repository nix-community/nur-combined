{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "etime";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "zimeg";
    repo = "emporia-time";
    rev = "refs/tags/v${version}";
    hash = "sha256-qO7/z+mULK8XGRnysJOv26VLHjoLaXJRRYQ865z0O/k=";
  };

  vendorHash = "sha256-+/nPbDlf74IIKOFWEP5VLqaZK+f2DfNQgd5PRXjaN5E=";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=v${version}"
  ];

  postInstall = ''
    mv $out/bin/emporia-time $out/bin/etime
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
