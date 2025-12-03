# mimeo is an exec dispatcher like xdg-open, but which allows mapping different URL regexes to different handlers.
# my setup sets mimeo as the default http/https handler,
# and from there it dispatches specialized rules, falling back to the original http/https handler if no URL specialization exists
#
# alternative to mimeo is jaro: <https://github.com/isamert/jaro>
{ config, lib, pkgs, ... }:
let
  mimeo-open-desktop = pkgs.static-nix-shell.mkPython3 {
    pname = "mimeo-open-desktop";
    srcRoot = ./.;
    pkgs = [ "mimeo" ];
  };

  # [ProgramConfig]
  enabledPrograms = builtins.filter
    (p: p.enabled)
    (builtins.attrValues config.sane.programs);

  # [ProgramConfig]
  sortedPrograms = builtins.sort
    (l: r: l.priority or 1000 < r.priority or 1000)
    enabledPrograms;

  fmtAssoc = regex: desktop: ''
    ${lib.getExe mimeo-open-desktop} ${desktop} %U
      ${regex}
  '';
  assocs = builtins.map
    (program: lib.mapAttrsToList fmtAssoc program.mime.urlAssociations)
    sortedPrograms;
  assocs' = lib.flatten assocs;

  fmtFallbackAssoc = mimeType: desktop: if mimeType == "x-scheme-handler/http" then ''
    ${lib.getExe mimeo-open-desktop} ${desktop} %U
      ^http://.*
  '' else if mimeType == "x-scheme-handler/https" then ''
    ${lib.getExe mimeo-open-desktop} ${desktop} %U
      ^https://.*
  '' else "";
  fmtFallbackAssoc' = mimeType: desktop:
    lib.optionalString (desktop != "mimeo.desktop") (fmtFallbackAssoc mimeType desktop);

  fallbackAssocs = builtins.map
    (program: lib.mapAttrsToList fmtFallbackAssoc' program.mime.associations)
    sortedPrograms;
  fallbackAssocs' = lib.flatten fallbackAssocs;
in
{
  sane.programs.mimeo = {
    packageUnwrapped = pkgs.mimeo.overridePythonAttrs (upstream: {
      nativeBuildInputs = (upstream.nativeBuildInputs or []) ++ [
        pkgs.copyDesktopItems
      ];
      desktopItems = [
        (pkgs.makeDesktopItem {
          name = "mimeo";
          desktopName = "Mimeo";
          exec = "mimeo %U";
          comment = "Open files by MIME-type or file name using regular expressions.";
          noDisplay = true;
        })
      ];

      passthru = (upstream.passthru or {}) // {
        inherit mimeo-open-desktop;
      };
    });

    sandbox.enable = false;  # could technically sandbox with `capsh`, but that breaks the abstraction.

    fs.".config/mimeo/associations.txt".symlink.text = lib.concatStringsSep "\n" (assocs' ++ fallbackAssocs');
    mime.priority = 20;
    mime.associations."x-scheme-handler/http" = "mimeo.desktop";
    mime.associations."x-scheme-handler/https" = "mimeo.desktop";
  };
}
