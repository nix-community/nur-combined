{
  fetchFromGitHub,
  hiredis,
  lib,
  mkNginxPlugin,
}:

mkNginxPlugin (finalAttrs: {
  pname = "nginx-oidc";
  version = "0.8.0";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "kjdev";
    repo = "nginx-oidc";
    tag = finalAttrs.version;
    fetchSubmodules = true;
    hash = "sha256-d1be3U7ybfYDCoLYdIDp9JEs29+NMFTr16SRj5vOX0w=";
  };

  # nxe-json and nxe-jwx are also compiled by nginx-auth-jwt; keep them out
  # to avoid duplicate symbols between the two modules
  postPatch = ''
    substituteInPlace config \
      --replace-fail '$nxe_json_module_srcs' "" \
      --replace-fail '$nxe_jwx_module_srcs' "" \
      --replace-fail '$nxe_json_module_libs' "" \
      --replace-fail '$nxe_jwx_module_libs' ""
  '';

  buildInputs = [ hiredis ];

  meta = {
    description = "OpenID Connect authentication module for nginx";
    homepage = "https://github.com/kjdev/nginx-oidc";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xddxdd ];
  };
})
