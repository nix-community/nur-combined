{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage rec {
  pname = "prettymapp";
  version = "2022-08-10";

  src = fetchFromGitHub {
    owner = "chrieke";
    repo = "prettymapp";
    rev = "053b215dafb6493b9efac5093e2e80bf65c5c5b2";
    hash = "sha256-/SlXbDv0tkSMSW878zqQ1zSEzt1BAcfK1Ny8kYiUfZs=";
  };

  propagatedBuildInputs = with python3Packages; [ osmnx ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  disabledTests = [
    "test_get_aoi_from_user_input_address"
    "test_get_aoi_from_user_input_rectangle"
  ];

  meta = with lib; {
    description = "Create beautiful maps from OpenStreetMap data in a webapp";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
