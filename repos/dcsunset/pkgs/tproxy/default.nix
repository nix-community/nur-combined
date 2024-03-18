{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "tproxy";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "kevwan";
    repo = "tproxy";
    rev = "v${version}";
    hash = "sha256-d4ZijF3clu00WZQGlurTkGkedurjt9fqfShdjbZWCSI=";
  };

  vendorHash = "sha256-tnVzX0crDdkRND7Au0CaTdmwLVxVjxU1jxCRutl48S8=";

  meta = with lib; {
    description = "A cli tool to proxy and analyze TCP connections.";
    homepage = "https://github.com/kevwan/tproxy";
    license = licenses.mit;
    mainProgram = "tproxy";
  };
}
