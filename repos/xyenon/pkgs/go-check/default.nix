{ lib, fetchFromGitHub, buildGoModule }:

let
  pname = "go-check";
in
buildGoModule {
  pname = pname;
  version = "2023.01.05-1";

  src = fetchFromGitHub {
    owner = "Dreamacro";
    repo = pname;
    rev = "a62daa7f5376a1b21d56a344e8b82fb038bbbf1b";
    hash = "sha256-bUj5cr2SYWN2Jv3LjZx5lJYXWX9S5vGOMY8iwr7YalY=";
  };

  vendorHash = "sha256-P91+lPalXhkZgFuMBjTUDp2zgksOkF2G9rqnHZWSDYo=";
  subPackages = [ "." ];

  meta = with lib; {
    description = "Check for outdated go module";
    homepage = "https://github.com/Dreamacro/go-check";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}
