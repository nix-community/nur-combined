{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "xgen";
  version = "unstable-2023-07-02";

  src = fetchFromGitHub {
    owner = "xuri";
    repo = "xgen";
    rev = "db840e1a460537cf4f90c2a88cffe11ef354dd9f";
    hash = "sha256-S5F7I6rDxtLSVlq7VLJkfghX+scudK9WZmOcDHmehM8=";
  };

  vendorHash = "sha256-YU/iQnZs4/oUiJw3syW1jxEpeQLyOMElsjzWCNsucds=";

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "XSD (XML Schema Definition) parser and Go/C/Java/Rust/TypeScript code generator";
    homepage = "https://github.com/xuri/xgen/tree/master";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
    mainProgram = "xgen";
  };
}
