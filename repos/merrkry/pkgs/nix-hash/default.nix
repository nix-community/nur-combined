{
  lib,
  writers,
  nixVersions,
  nix-update,
}:
(writers.writePython3Bin "nix-hash" {
  flakeIgnore = [ "E501" ];
  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      nixVersions.latest
      nix-update
    ])
  ];
} ./nix_hash.py).overrideAttrs
  (old: {
    version = "0.1.0";
    meta = old.meta or { } // {
      description = "Check or update fixed-output hashes of flake packages";
      license = lib.licenses.mit;
      mainProgram = "nix-hash";
      platforms = lib.platforms.unix;
    };
  })
