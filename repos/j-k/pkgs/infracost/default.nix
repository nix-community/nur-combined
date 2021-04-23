{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "infracost";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "infracost";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-RMX4fMZ38Pmqws4i9ZAOdSN9AWFlpUZnQmPHIX+zn7M=";
  };

  vendorSha256 = "sha256-8WUpmcUwpW7Mg+gQjWKXncGkNGJmV/iWubZ51dae5Ac=";

  preBuild = ''
    buildFlagsArray+=("-ldflags" "-s -w -X github.com/infracost/infracost/internal/version.Version=v${version}")
  '';

  # Tests run terraform init which attempts to create files
  doCheck = false;

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    # Add statefile to avoid remote update checks
    export HOME="$TMPDIR"
    INFRACOST_DIR="$HOME/.config/infracost"
    mkdir -p "$INFRACOST_DIR"
    echo '{
      "installId": "00000000-0000-0000-0000-000000000000",
      "latestReleaseVersion": "v${version}",
      "latestReleaseCheckedAt": "1970-01-01T00:00:00Z"
    }' > "$INFRACOST_DIR/.state.json"

    $out/bin/infracost --help
    $out/bin/infracost --version | grep "Infracost v${version}"
    runHook postInstallCheck
  '';

  meta = with lib; {
    homepage = "https://infracost.io";
    changelog = "https://github.com/infracost/infracost/releases/tag/v${version}";
    description = "Cloud cost estimates for Terraform in your CLI and pull requests";
    longDescription = ''
      Infracost shows hourly and monthly cost estimates for a Terraform project.
      This helps developers, DevOps et al. quickly see the cost breakdown and compare different deployment options upfront.
    '';
    license = licenses.asl20;
    maintainers = with maintainers; [ jk ];
  };
}
