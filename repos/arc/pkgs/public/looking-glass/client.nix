{ lib, looking-glass-client, looking-glass-host }: let
  inherit (looking-glass-client) stdenv;
  inherit (stdenv) hostPlatform;
in looking-glass-client.overrideAttrs (old: {
  inherit (looking-glass-host) version src;

  NIX_CFLAGS_COMPILE = looking-glass-client.NIX_CFLAGS_COMPILE or [] ++ lib.optional hostPlatform.isLinux "-Wno-maybe-uninitialized";

  patches = [ ];
})
