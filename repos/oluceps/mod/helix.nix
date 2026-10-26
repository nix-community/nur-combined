{
  flake.modules.nixos = {
    base-pkgs =
      { pkgs, ... }:
      {
        nixpkgs.overlays = [
          (
            _final: prev:
            let
              editor = prev.steelix;
              grammars = prev.helix.tree-sitter-grammars;
              # These parsers match the queries in the pinned Steelix source.
              runtime = prev.runCommand "steelix-runtime" { } ''
                mkdir -p $out/grammars
                ln -s ${editor.runtime}/queries $out/queries
                ln -s ${editor.runtime}/grammars/*.so $out/grammars/
                ln -sfn ${grammars.tree-sitter-nix}/parser $out/grammars/nix.so
                ln -sfn ${grammars.tree-sitter-regex}/parser $out/grammars/regex.so
              '';
            in
            {
              steelix = editor.overrideAttrs (old: {
                buildCommand = prev.lib.replaceStrings [ "${editor.runtime}" ] [ "${runtime}" ] old.buildCommand;
                passthru = old.passthru // {
                  inherit runtime;
                  tree-sitter-grammars = editor.tree-sitter-grammars // {
                    inherit (grammars) tree-sitter-nix tree-sitter-regex;
                  };
                };
              });
            }
          )
        ];
        environment.systemPackages = [ pkgs.steelix ];
      };

    home =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        cogs = {
          helix-fcitx-focus = pkgs.helix-fcitx-focus;
          helix-file-watcher = pkgs.helix-file-watcher;
          oil = pkgs.helix-oil;
          notify = pkgs.helix-oil;
        };
        nativeLibraries = {
          libhelix_fcitx_focus = pkgs.helix-fcitx-focus;
          libhelix_file_watcher = pkgs.helix-file-watcher;
        };
      in
      {
        hjem.users.${config.identity.user} = {
          xdg.config.files = lib.mapAttrs' (
            name: package:
            lib.nameValuePair "helix/${name}" {
              source = "${package}/share/steel/cogs/${name}";
            }
          ) cogs;
          xdg.data.files = lib.mapAttrs' (
            name: package:
            lib.nameValuePair "steel/native/${name}.so" {
              source = "${package}/lib/${name}.so";
            }
          ) nativeLibraries;
        };
      };
  };
}
