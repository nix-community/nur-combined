{
  lib,
  fetchFromGitHub,
  stdenv,
  haproxy-lua-http,
}:
stdenv.mkDerivation {
  name = "haproxy-auth-request";
  version = "0-unstable-2026-02-20";

  src = fetchFromGitHub {
    owner = "TimWolla";
    repo = "haproxy-auth-request";
    rev = "cdb891cf52995780bb6128c2a7495d36325e4ff2";
    hash = "sha256-1JibFpzfDljK8gMJUilQaWHuxQ0hRvQesu8wCB4MbCI=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"/share/lua
    cp auth-request.lua "$out"/share/lua
    ln -s ${haproxy-lua-http}/share/lua/http.lua "$out"/share/lua/http.lua

    runHook postInstall
  '';

  meta = {
    description = "Lua script for HAProxy to add access control to your HTTP services based on a subrequest";
    homepage = "https://github.com/TimWolla/haproxy-auth-request";
    license = [ lib.licenses.mit ];
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    # no mainProgram
    platforms = lib.platforms.all;
  };
}
