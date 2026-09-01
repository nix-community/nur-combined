{
  lib,
  buildGoModule,
  fetchFromGitHub,
  unstableGitUpdater,
}:
buildGoModule (finalAttrs: {
  pname = "oidc-tester-app";
  version = "0-unstable-2026-08-31";
  src = fetchFromGitHub {
    owner = "authelia";
    repo = "oidc-tester-app";
    rev = "9c744b2d1697a73a03ef0251d976da22ca55ef14";
    hash = "sha256-Cw9fiCihurlZTcbjqXLRvwFJ/ggDcojcGTZrHILCZRU=";
  };
  vendorHash = "sha256-RPeUvZ2KJOmdnmg5K4qWD8tGxiHC7lZrhDS2cn/ufOo=";

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/authelia/oidc-tester-app";
    hardcodeZeroVersion = true;
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "OpenID Connect relying party web application for testing OIDC providers such as Authelia";
    homepage = "https://github.com/authelia/oidc-tester-app";
    license = lib.licenses.mit;
    mainProgram = "oidc-tester-app";
  };
})
