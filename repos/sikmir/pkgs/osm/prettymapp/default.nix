{ lib, stdenv, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage rec {
  pname = "prettymapp";
  version = "2022-12-18";

  src = fetchFromGitHub {
    owner = "chrieke";
    repo = "prettymapp";
    rev = "26f945ef670cbede8f0561582d280664da09ae96";
    hash = "sha256-u5LMTQCB6aqUYC/l8z+bQjk4cGiWR7uvRNoTwLxMDlM=";
  };

  postPatch = "sed -i 's/==.*//' requirements.txt";

  propagatedBuildInputs = with python3Packages; [ osmnx ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook mock ];

  disabledTests = [
    "test_get_aoi_from_user_input_address"
    "test_get_aoi_from_user_input_rectangle"
  ];

  meta = with lib; {
    description = "Create beautiful maps from OpenStreetMap data in a webapp";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    broken = stdenv.isDarwin; # xyzservices
  };
}
