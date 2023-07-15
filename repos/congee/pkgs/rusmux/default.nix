{ lib
, fetchFromGitHub
, rustPlatform
}:

rustPlatform.buildRustPackage rec {
  pname = "rusmux";
  version = "0.3.7";

  src = fetchFromGitHub {
    owner = "MeirKriheli";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-EKToE7eyj6Uxdcr2EOuZ5yp1YgnznooaBc/iPzWLJjg=";
  };

  cargoSha256 = "sha256-cgCJ+v+Pw3Ew7fxL6vMzR2hlAtMu7DfL20HbRqywrCE=";

  meta = with lib; {
    description = " Tmux automation in rust ";
    homepage = "https://github.com/MeirKriheli/rusmux";
    license = licenses.mit;
    maintainers = with maintainers; [ doronbehar ];
  };
}
