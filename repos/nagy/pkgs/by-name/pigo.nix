{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "pigo";
  version = "1.4.6";

  src = fetchFromGitHub {
    owner = "esimov";
    repo = "pigo";
    rev = "v${finalAttrs.version}";
    hash = "sha256-0K1d/VCsUaYj/uQ2yUIsc8KdGOQVqAUSaIRnyRYdt+s=";
  };

  vendorHash = "sha256-MkJVs/i0dPRUz5kUhSFYU+eR1SuVgO01U5ubWVWMUfk=";

  deleteVendor = true;

  ldflags = [
    "-s"
    "-w"
  ];

  postInstall = ''
    mv $out/bin/http $out/bin/pigo-http
  '';

  meta = {
    description = "Fast face detection, pupil/eyes localization and facial landmark points detection library in pure Go";
    homepage = "https://github.com/esimov/pigo";
    license = lib.licenses.mit;
    mainProgram = "pigo";
  };
})
