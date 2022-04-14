{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "protodot";
  version = "87817c3d0a8e7af753af15508b51292e941bc7c6";

  src = fetchFromGitHub {
    owner = "seamia";
    repo = pname;
    rev = version;
    sha256 = "sha256-EOIyWLmUZ9xarqw5bKIiurY+ZB+NOJCkUkjFNtUXDW0=";
  };

  vendorSha256 = "sha256-v/Xoedq7PzpnGuFFCHQE96dcQy3SRJuD/VPgNAgsnOM=";

  subPackages = [ "." ];

  meta = with lib; {
    description = "Transforming your .proto files into .dot files";
    homepage = "https://github.com/seamia/protodot";
    license = licenses.bsd3;
    maintainers = with maintainers; [  ];
  };
}
