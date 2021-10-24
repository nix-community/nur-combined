{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "subo";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "suborbital";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-6vVMBgjAlMmDiwM4KJcI+aVMIMe3y9tZjs7zImn0LLA=";
  };

  vendorSha256 = null;

  ldflags = [ "-s" "-w" ];

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/subo --help
    runHook postInstallCheck
  '';

  meta = with lib; {
    homepage = "https://suborbital.dev";
    changelog = "https://github.com/suborbital/subo/tree/v${version}/changelogs";
    description = "The Suborbital CLI";
    longDescription = ''
      Subo is the command-line helper for working with the Suborbital
      Development Platform. Subo is used to build Wasm Runnables, generate new
      projects and config files, and more over time.
    '';
    license = licenses.asl20;
    maintainers = with maintainers; [ jk ];
  };
}
