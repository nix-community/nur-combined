{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "container-diff";
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "GoogleContainerTools";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-4sk6DqScaNf0tMZQ6Hj40ZEklFTUFwAkN63v67nUFn8=";
  };
  vendorHash = null;

  # Don't build documentation tooling
  excludedPackages = "hack";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/GoogleContainerTools/container-diff/version.version=${version}"
  ];

  preCheck = ''
    # Remove test that requires networking
    rm cmd/diff_test.go
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/container-diff --help
    $out/bin/container-diff version | grep "${version}"
    runHook postInstallCheck
  '';

  meta = with lib; {
    homepage = "https://github.com/GoogleContainerTools/container-diff";
    changelog = "https://github.com/GoogleContainerTools/container-diff/blob/v${version}/CHANGELOG.md";
    description = "Diff your Docker containers";
    longDescription = ''
      container-diff is a tool for analyzing and comparing container images.
      container-diff can examine images along several different criteria, including: Docker Image History, Image file
      system, Image size, Apt packages, RPM packages, pip packages, npm packages.
      These analyses can be performed on a single image, or a diff can be performed on two images to compare. The tool
      can help users better understand what is changing inside their images, and give them a better look at what their
      images contain.
    '';
    license = licenses.asl20;
    maintainers = with maintainers; [ jk ];
  };
}
