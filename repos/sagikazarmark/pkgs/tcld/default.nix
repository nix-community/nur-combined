{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "tcld";
  version = "0.32.0";

  src = fetchFromGitHub {
    owner = "temporalio";
    repo = "tcld";
    rev = "v${version}";
    sha256 = "sha256-lynKAfk6A5rV66+mdiLLnBTdz+E7tzAd73qFkptYHDE=";
  };

  vendorHash = "sha256-BrlKbIY+DFfsJgXWdNxYwLWZoSr6CIuNSaPpLgzniTQ=";

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
