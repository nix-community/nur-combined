{
  lib,
  fetchFromGitHub,
  stdenv,
}:
let
  deriv =
    (stdenv.mkDerivation {
      name = "haproxy-lua-http";
      version = "unstable-2021-06-05";

      src = fetchFromGitHub {
        owner = "haproxytech";
        repo = "haproxy-lua-http";
        rev = "670d0d278182902f252faffc17eeb51a7ecb4b9d";
        hash = "sha256-ooHq9ORqJcu4EPFVOMtyPC5uk05adkysfm2VhiAJUtY=";
      };

      installPhase = ''
        runHook preInstall

        mkdir -p "$out"/share/lua
        cp http.lua "$out"/share/lua

        runHook postInstall
      '';

      meta = {
        description = "pure Lua HTTP 1.1 library for HAProxy";
        homepage = "https://github.com/haproxytech/haproxy-lua-http";
        license = [ lib.licenses.asl20 ];
        sourceProvenance = [ lib.sourceTypes.fromSource ];
        # no mainProgram
        platforms = lib.platforms.all;
      };
    })
    // {
      luaPath = "${deriv}/share/lua";
    };
in
deriv
