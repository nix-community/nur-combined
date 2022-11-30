{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "pigo";
  version = "1.4.6";

  src = fetchFromGitHub {
    owner = "esimov";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-0K1d/VCsUaYj/uQ2yUIsc8KdGOQVqAUSaIRnyRYdt+s=";
  };

  vendorSha256 = "sha256-MkJVs/i0dPRUz5kUhSFYU+eR1SuVgO01U5ubWVWMUfk=";

  deleteVendor = true;

  postInstall = ''
    mv $out/bin/http $out/bin/pigo-http
  '';

  meta = with lib; {
    description =
      "Fast face detection, pupil/eyes localization and facial landmark points detection library in pure Go";
    homepage = "https://github.com/esimov/pigo";
    license = with licenses; [ mit ];
  };
}
