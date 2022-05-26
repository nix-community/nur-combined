{ config, lib, pkgs, ... }:

let

  inherit (lib) concatStringsSep mapAttrsToList mkDefault mkIf mkOption types;

  colors = config.theme.base16.colors;

  template = builtins.fetchurl {
    url =
      "https://raw.githubusercontent.com/base16-project/base16-emacs/26b84fc93505219517a512eb01e6370365174989/templates/default.mustache";
    sha256 = "0pl4q5cpjmgdykkfcddmx541sp2pzjakrf1b6crwpmgfwykdl61s";
  };

  themeFile = pkgs.runCommandLocal "base16-hm-theme" { } ''
    mkdir $out
    sed '${
      concatStringsSep ";"
      (mapAttrsToList (n: v: "s/#{{${n}-hex}}/#${v.hex.rgb}/g") colors
        ++ [ "s/{{scheme-slug}}/hm/g" ])
    }' ${template} > $out/base16-hm-theme.el
  '';

in {
  options.programs.emacs.enableBase16Theme = mkOption {
    type = types.bool;
    default = true;
    example = false;
    description = ''
      Build Base16 theme for Emacs. Note, this does not actually enable the
      theme.
    '';
  };

  config = mkIf config.programs.emacs.enableBase16Theme {
    programs.emacs.init.usePackage = {
      base16-hm-theme = {
        enable = true;
        defer = true;
        package = epkgs:
          epkgs.trivialBuild {
            pname = "base16-hm-theme";
            src = themeFile;
            packageRequires = [ epkgs.base16-theme ];
          };
        earlyInit = ''
          ;; Set color theme in early init to avoid flashing during start.
          (require 'base16-hm-theme)
          (enable-theme 'base16-hm)
        '';
      };
    };
  };
}
