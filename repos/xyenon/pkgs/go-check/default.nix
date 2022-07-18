{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "go-check";
  version = "2022.03.21-1";

  src = fetchFromGitHub {
    owner = "Dreamacro";
    repo = "go-check";
    rev = "b1c52d1f4dab527bd094cb00528ffe8d63981ce9";
    sha256 = "sha256-l9h5PCRXnlhCi2qSaE/8ZTv8o+lRk2rfO8/rAU8IbcM=";
  };

  vendorSha256 = "sha256-C5z7sYT2OtEtU74f+R3bpHKLsxSg89L8XIbd4IPjPGA=";
  subPackages = [ "." ];

  meta = with lib; {
    description = "Check for outdated go module";
    homepage = "https://github.com/Dreamacro/go-check";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}
