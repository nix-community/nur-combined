{ lib
, sources
, buildGoModule
}:

buildGoModule rec {
  inherit (sources.glauth) pname version src;
  vendorSha256 = "sha256-bG7g9V5LNnKwb8aPVQxWG72Ul6cJRAgDCCSl5uKhAVw=";

  preBuild = ''
    rm -rf v2
    sed -i '/replace/d' go.mod
  '';

  postInstall = ''
    rm $out/bin/plugins
  '';

  doCheck = false;

  meta = with lib; {
    description = "A lightweight LDAP server for development, home use, or CI";
    homepage = "https://github.com/glauth/glauth";
    license = licenses.mit;
  };
}
