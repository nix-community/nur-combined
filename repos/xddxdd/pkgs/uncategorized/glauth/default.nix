{ lib
, sources
, buildGoModule
}:

buildGoModule rec {
  inherit (sources.glauth) pname version src;
  vendorSha256 = "sha256-8xjnNjkHI5QrfgJmAgRb2izMkgATdGzSesnWGOvmomY=";
  modRoot = "v2";

  buildPhase = ''
    runHook preBuild
    go install
    runHook postBuild
  '';

  doCheck = false;

  meta = with lib; {
    description = "A lightweight LDAP server for development, home use, or CI";
    homepage = "https://github.com/glauth/glauth";
    license = licenses.mit;
  };
}
