{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "ingress2gateway";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "kubernetes-sigs";
    repo = "ingress2gateway";
    rev = "v${version}";
    hash = "sha256-qQti1kgMRw7CUyjCe5/TaXhzn7w3Slw9Adw0iAH4oYQ=";
  };

  vendorHash = "sha256-fq2KqsHtrQNHozECt3qYypOscdLSf7o7Ku0aVkpfdRw=";

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "Convert Ingress resources to Gateway API resources";
    homepage = "https://github.com/kubernetes-sigs/ingress2gateway";
    changelog = "https://github.com/kubernetes-sigs/ingress2gateway/blob/${src.rev}/CHANGELOG.md";
    license = licenses.asl20;
    mainProgram = "ingress2gateway";
  };
}