{
  fetchFromGitHub,
  lib,
  buildGoModule,
  unstableGitUpdater,
}:
buildGoModule (finalAttrs: {
  pname = "ldap-auth-proxy";
  version = "0.2.0-unstable-2020-07-29";
  src = fetchFromGitHub {
    owner = "pinepain";
    repo = "ldap-auth-proxy";
    rev = "66a8236af574f554478fe376051b95f61235efc9";
    hash = "sha256-kV3P3hRmfFH5g+BzjxZGstVHoQ4KMn9DVup5cInin+Y=";
  };
  vendorHash = "sha256-drLTMaRelaz36ORl1qKndGYN2i6qRgJxy2D+wTDzmWA=";

  postPatch = ''
    cp ${./go.mod} go.mod
    cp ${./go.sum} go.sum
  '';

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/pinepain/ldap-auth-proxy";
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Simple drop-in HTTP proxy for transparent LDAP authentication which is also a HTTP auth backend";
    homepage = "https://github.com/pinepain/ldap-auth-proxy";
    license = lib.licenses.mit;
    mainProgram = "ldap-auth-proxy";
  };
})
