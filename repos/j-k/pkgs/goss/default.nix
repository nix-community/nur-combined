{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "goss";
  version = "0.3.16";

  src = fetchFromGitHub {
    owner = "aelsabbahy";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-10jbMOIzE/SJiZzdT71vDx9MMyIomAmj2nYmVvkuvNQ=";
  };

  vendorSha256 = "sha256-Z2fYtTu7puWgRwzUyImrXSMNTxlmZ891kctDJPmU2NM=";

  preBuild = ''
    buildFlagsArray+=("-ldflags" "-s -w -X main.version=v${version}")
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/goss --help
    $out/bin/goss --version | grep "goss version v${version}"
    runHook postInstallCheck
  '';

  meta = with lib; {
    homepage = "https://github.com/aelsabbahy/goss";
    changelog = "https://github.com/aelsabbahy/goss/releases/tag/v${version}";
    description = "Quick and Easy server testing/validation";
    longDescription = ''
      Goss is a YAML based serverspec alternative tool for validating a server’s configuration. It eases the process of
      writing tests by allowing the user to generate tests from the current system state. Once the test suite is written
      they can be executed, waited-on, or served as a health endpoint.
    '';
    license = licenses.asl20;
    maintainers = with maintainers; [ jk ];
  };
}
