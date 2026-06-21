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
          rikkahub-desktop is currently marked broken.
          Use rikkahub-desktop-bin for the upstream prebuilt release.
          EOF
          exit 1
        '';

        installPhase = ''
          mkdir -p $out
        '';

        meta = {
          description = "RikkaHub desktop built from source";
          mainProgram = "rikkahub-pc";
          broken = true;
          license = {
            shortName = "rikkahub-segmented-dual";
            fullName = "RikkaHub Segmented Dual License";
            url = "https://github.com/yuh-G/rikkahub-desktop/blob/645f6f8439321941fed21ba7f53008bbc8b1853c/LICENSE";
            free = false;
            redistributable = true;
          };
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
  rikkahub-desktop-bin = pkgs.callPackage ./rikkahub-desktop-bin { };
}
