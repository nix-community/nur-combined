{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "tcld";
  version = "0.14.3";

  src = fetchFromGitHub {
    owner = "temporalio";
    repo = "tcld";
    rev = "v${version}";
    sha256 = "sha256-PvZ9VRKgSQctodfy3ho2HHv/4i507zb9dd+PJjWMEAA=";
  };

  vendorSha256 = "sha256-zF6tjA4539ekfZk2PVmkC8exO8pkGLOHGQOJu6NUyK4=";

  ldflags = [
    "-X github.com/temporalio/tcld/app.date=unknown"
    "-X github.com/temporalio/tcld/app.commit=unknown"
    "-X github.com/temporalio/tcld/app.version=v${version}"
  ];

  subPackages = [ "./cmd/tcld" ];

  doCheck = false;

  meta = with lib; {
    description = "The temporal cloud cli. ";
    homepage = "https://temporal.io";
    changelog = "https://github.com/temporalio/tcld/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ sagikazarmark ];
  };
}
