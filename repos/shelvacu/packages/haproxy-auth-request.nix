{
  lib,
  fetchFromGitHub,
  stdenv,
  haproxy-lua-http,
}:
stdenv.mkDerivation {
  name = "haproxy-auth-request";
  version = "unstable-2024-12-17";

  src = fetchFromGitHub {
    owner = "TimWolla";
    repo = "haproxy-auth-request";
    rev = "215afeb4ae9dbd6f05d0f7a8bf67ea3d34637f13";
    hash = "sha256-Shmd+vJy8y0AidX4dQyeVRCthwJ+rPq4U9L+Y/mvhZQ=";
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
