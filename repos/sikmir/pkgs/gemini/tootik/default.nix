{ lib, buildGoModule, fetchFromGitHub, openssl }:

buildGoModule rec {
  pname = "tootik";
  version = "0.4.5";

  src = fetchFromGitHub {
    owner = "dimkr";
    repo = "tootik";
    rev = version;
    hash = "sha256-mg3DYGYp8zgQW2fQiUG/UM18DTQIP3Z3hS26dxBO9hc=";
  };

  vendorHash = "sha256-hmW2I8ToS6gbjekb8JRj+DFm7sOIGPMXzNggJsifyQk=";

  nativeBuildInputs = [ openssl ];

  preBuild = ''
    go generate ./migrations
  '';

  meta = with lib; {
    description = "A federated nanoblogging service with a Gemini frontend";
    inherit (src.meta) homepage;
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
  };
}
