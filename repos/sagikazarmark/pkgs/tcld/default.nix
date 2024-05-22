{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "tcld";
  version = "0.23.0";

  src = fetchFromGitHub {
    owner = "temporalio";
    repo = "tcld";
    rev = "v${version}";
    sha256 = "sha256-zUmnmiCNBRC8QVsLWq6na/8OeOREo4US6VCyA1BPeGw=";
  };

  vendorHash = "sha256-Erv+GGbduDMxPV7i9ywzlMv0EopCAiWMLSXqU3mZFs0=";

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
