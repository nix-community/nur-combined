pkgs-final: pkgs-prev: final: prev: rec {
  # this function is modified from nix official implementation
  # https://github.com/NixOS/nix/blob/56dc6ed8410510033b835d48b3bd22766e8349a0/src/libexpr/flake/call-flake.nix#L7-L61
  importFlake =
    {
      path,
      inputs,
      narHash,
    }:
    let
      flake = import (path + "/flake.nix");
      outputs = flake.outputs (inputs // { self = result; });
      result = outputs // {
        outPath = path;
        inherit inputs outputs narHash;
        _type = "flake";
      };
    in
    result;
  patchFlake =
    {
      flake,
      patchesToFetch,
    }:
    let
      src = pkgs-prev.applyPatches {
        name = "patched-flake";
        src = flake;
        patches = [ (map pkgs-prev.fetchpatch patchesToFetch) ];
      };
      narHashDrv = pkgs-prev.stdenvNoCC.mkDerivation {
        name = "narHash";
        nativeBuildInputs = [ pkgs-prev.nix ];
        unpackPhase = "true";
        installPhase = ''
          echo \"sha256- > $out
          nix-hash --type sha256 --base64 ${src} >> $out
          echo \" >> $out
        '';
      };
      narHash = import "${narHashDrv}";
    in
    importFlake {
      inherit narHash;
      inherit (flake) inputs;
      path = src;
    };
}
