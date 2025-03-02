{ lib
, buildGoModule
, fetchFromGitHub
}:
buildGoModule rec {
  pname = "go-mod-upgrade";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "oligot";
    repo = "go-mod-upgrade";
    rev = "v${version}";
    hash = "sha256-RjP9Yt3jzLcgkPKFboMnOZw0qRJQzSRstQtadj8bzlI=";
  };

  vendorHash = "sha256-Qx+8DfeZyNSTf5k4juX7+0IXT4zY2LJMuMw3e1HrxBs=";

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "Update outdated Go dependencies interactively";
    homepage = "https://github.com/oligot/go-mod-upgrade";
    license = licenses.mit;
    mainProgram = "go-mod-upgrade";
  };
}
