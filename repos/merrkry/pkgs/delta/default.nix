{
  pkgs,
  lib,
  callPackage,
  source ? callPackage ./source.nix { },
  githubReleaseUpdater ? callPackage ../../lib/github-release-updater.nix { },
}:

let
  # Fetch during evaluation so the top-level NUR package does not require IFD.
  upstreamSource = builtins.fetchTarball {
    inherit (source.src) url;
    sha256 = source.src.outputHash;
  };
  # The upstream flake only imports nixpkgs. Reuse the caller's package set,
  # including its overlays and configuration.
  upstream = builtins.scopedImport {
    import = _: _: pkgs;
  } "${upstreamSource}/flake.nix";
  outputs = upstream.outputs {
    self = outputs;
    nixpkgs = { inherit lib; };
  };
in
outputs.packages.${pkgs.stdenv.hostPlatform.system}.delta.overrideAttrs (old: {
  __structuredAttrs = true;
  strictDeps = true;

  passthru = (old.passthru or { }) // {
    updateScript = [
      (lib.getExe githubReleaseUpdater)
      "--owner"
      "zed-industries"
      "--repo"
      "delta-nix"
      "--attribute"
      "delta"
      "--tag-pattern"
      "v(\\d+\\.\\d+\\.\\d+)"
      "--"
      "--file=pkgs/delta/update.nix"
      "--override-filename=pkgs/delta/source.nix"
    ];
  };

  meta = old.meta // {
    changelog = "https://github.com/zed-industries/delta-nix/releases/tag/v${source.version}";
    maintainers = with lib.maintainers; [ merrkry ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
