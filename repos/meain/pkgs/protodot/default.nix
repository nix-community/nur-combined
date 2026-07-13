{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "protodot";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "seamia";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-UUK5mP8wGli0VpNfLLbEsXBzQaJYWg20n93oTsnHtiA=";
  };

  vendorHash = "sha256-WHA7mpTUob8bx/e1Hi5tZONaif/smyokE0idfqkh7BI=";

  subPackages = [ "." ];

  meta = with lib; {
    description = "Transforming your .proto files into .dot files";
    homepage = "https://github.com/seamia/protodot";
    license = licenses.bsd3;
    maintainers = with maintainers; [  ];
  };
}
