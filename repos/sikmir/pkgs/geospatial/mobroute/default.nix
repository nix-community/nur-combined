{ lib, buildGoModule, fetchFromSourcehut }:

buildGoModule rec {
  pname = "mobroute";
  version = "2023-06-02";

  src = fetchFromSourcehut {
    owner = "~mil";
    repo = "mobroute";
    rev = "c9b25594bc3dbfce558a90d2d856cd8a1269b2bb";
    hash = "sha256-f2jK9chkxlvthZgahyFMSyzAzCOMU4Rmy0/KWiUklcU=";
  };

  vendorHash = "sha256-YJp4vjwASCVdcnqjbREgNosmybLLdCw+q4gSpZHsNJA=";

  meta = with lib; {
    description = "Minimal FOSS Public Transportation Router";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
