{ lib, buildGoModule, fetchgit }:
buildGoModule rec {
  pname = "dirtygit";
  version = "48184ea5211eb7f5930cffc9401d8beb65b0b9cd";

  src = fetchgit {
    url = "https://github.com/mipmip/dirtygit.git";
    rev = "${version}";
    hash = "sha256-qsT6d0d2T/f6zC24e+GyOiRiD7mLrhVvBkvIP8uN0x4=";
  };

  vendorHash = "sha256-KBu77tQfZjZsAcUatXZj+sHa+5uUNN5PuFaSk1rzIkQ=";

  meta = with lib; {
    description = ''
      Finds git repos in need of commitment
    '';
    homepage = "https://github.com/mipmip/dirtygit";
    license = licenses.mit;
  };
}
