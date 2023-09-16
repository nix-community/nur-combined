{ lib, fetchFromGitHub, buildGoModule, nix-update-script }:

buildGoModule rec {
  pname = "go-check";
  version = "unstable-2023-09-14";

  src = fetchFromGitHub {
    owner = "Dreamacro";
    repo = pname;
    rev = "93eb9e3cfda06610764fa4f602fa047874b48b0c";
    hash = "sha256-SqGe6Q0VdYQCTez5kdMbcEeoNTzE68ICI5FhvNtxfZU=";
  };

  vendorHash = "sha256-CbYqXZ81o0rsdridMCXEBNdU02KLRtaV1ZMNOa1WKfk=";

  subPackages = [ "." ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version" "branch" ]; };

  meta = with lib; {
    description = "Check for outdated go module";
    homepage = "https://github.com/Dreamacro/go-check";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}
