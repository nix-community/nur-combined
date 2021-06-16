{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "konstraint";
  version = "0.14.1";

  src = fetchFromGitHub {
    owner = "plexsystems";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-2O7F2fcGid4ub3QJwPznXjMYuzIQ84T6/DKSfezgl7M=";
  };

  vendorSha256 = "sha256-HMTDYYzlH35EoloFES2K8yeWVBfqcLCjMurrnRA5uBA=";

  # Exclude go within .github folder
  excludedPackages = ".github";

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/konstraint --help
    runHook postInstallCheck
  '';

  meta = with lib; {
    homepage = "https://github.com/plexsystems/konstraint";
    changelog = "https://github.com/plexsystems/konstraint/releases/tag/v${version}";
    description = "A policy management tool for interacting with Gatekeeper";
    longDescription = ''
      konstraint is a CLI tool to assist with the creation and management of templates and constraints when using
      Gatekeeper. Automatically copy Rego to the ConstraintTemplate. Automatically update all ConstraintTemplates with
      library changes. Enable writing the same policies for Conftest and Gatekeeper.
    '';
    license = licenses.mit;
    maintainers = with maintainers; [ jk ];
  };
}
