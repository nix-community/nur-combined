{
  fetchFromGitHub,
  jansson,
  lib,
  mkNginxPlugin,
  openssl,
}:

mkNginxPlugin (finalAttrs: {
  pname = "nginx-auth-jwt";
  version = "0.15.0";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "kjdev";
    repo = "nginx-auth-jwt";
    tag = finalAttrs.version;
    fetchSubmodules = true;
    hash = "sha256-OfrdokFqHhHCpWVtatK91DWgiWzAgn+5CPSPeJVjJuE=";
  };

  buildInputs = [
    jansson
    openssl
  ];

  meta = {
    description = "JWT authentication module for nginx";
    homepage = "https://github.com/kjdev/nginx-auth-jwt";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xddxdd ];
  };
})
