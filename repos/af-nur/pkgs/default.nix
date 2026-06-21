{ pkgs, bun2nix ? null, ... }:
let
  rikkahubDesktop =
    if bun2nix != null then
      pkgs.callPackage ./rikkahub-desktop { inherit bun2nix; }
    else
      pkgs.stdenvNoCC.mkDerivation {
        pname = "rikkahub-desktop";
        version = "git";
        dontUnpack = true;

        buildPhase = ''
          cat >&2 <<'EOF'
          rikkahub-desktop requires the flake-provided bun2nix input.
          Build it with `nix build .#rikkahub-desktop`.
          EOF
          exit 1
        '';

        installPhase = ''
          mkdir -p $out
        '';

        meta = {
          description = "RikkaHub desktop package; requires flake-provided bun2nix to build";
          mainProgram = "rikkahub-pc";
          platforms = pkgs.lib.platforms.linux;
        };
      };
in
{
  classin = pkgs.callPackage ./classin { };
  hhsh = pkgs.callPackage ./hhsh { };
  linuxqq-clipsync = pkgs.callPackage ./linuxqq-clipsync { };
  mefrpc = pkgs.callPackage ./mefrpc { };
  xwaylandvideobridge = pkgs.callPackage ./xwaylandvideobridge { };
  rikkahub-desktop = rikkahubDesktop;
}
