{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "crane";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "google";
    repo = "go-containerregistry";
    rev = "v${version}";
    sha256 = "sha256-iJG4gdkLt/tCrWZV6kClHmVFD2qVR6ZB+mhFFlYg/pk=";
  };
  modRoot = "cmd/crane";
  vendorSha256 = "sha256-pQpattmS9VmO3ZIQUFn66az8GSmB4IvYhTTCFn6SUmo=";

  ldflags = [ "-s" "-w" "-X github.com/google/go-containerregistry/cmd/crane/cmd.Version=v${version}" ];

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/crane --help
    $out/bin/crane version | grep "v${version}"
    runHook postInstallCheck
  '';

  meta = with lib; {
    homepage = "https://github.com/google/go-containerregistry/tree/main/cmd/crane";
    description = "A tool for interacting with remote images and registries";
    license = licenses.asl20;
    maintainers = with maintainers; [ jk ];
  };
}
