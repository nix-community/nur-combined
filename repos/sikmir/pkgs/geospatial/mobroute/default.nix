{ lib, buildGoModule, fetchFromSourcehut }:

buildGoModule rec {
  pname = "mobroute";
  version = "2023-01-27";

  src = fetchFromSourcehut {
    owner = "~mil";
    repo = "mobroute";
    rev = "dded2d14dd3209515644d7f7492eaf58f7b4a9f5";
    hash = "sha256-rjhVdt1JwFDTbOiqTnNTsBToFM3slyys6X2fEr9qYOQ=";
  };

  vendorHash = "sha256-YJp4vjwASCVdcnqjbREgNosmybLLdCw+q4gSpZHsNJA=";

  meta = with lib; {
    description = "Minimal FOSS Public Transportation Router";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
