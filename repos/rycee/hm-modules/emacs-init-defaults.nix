# A collection of "uncontroversial" configurations for selected packages.

{ pkgs, ... }:

{
  programs.emacs.init.usePackage = {
    csharp-mode = { mode = [ ''"\\.cs\\'"'' ]; };

    dap-lldb = {
      config = ''
        (setq dap-lldb-debug-program "${pkgs.lldb}/bin/lldb-vscode")
      '';
    };

    deadgrep = {
      config = ''
        (setq deadgrep-executable "${pkgs.ripgrep}/bin/rg")
      '';
    };

    dhall-mode = { mode = [ ''"\\.dhall\\'"'' ]; };

    dockerfile-mode = { mode = [ ''"Dockerfile\\'"'' ]; };

    elm-mode = { mode = [ ''"\\.elm\\'"'' ]; };

    ggtags = {
      config = ''
        (setq ggtags-executable-directory "${pkgs.global}/bin")
      '';
    };

    idris-mode = {
      config = ''
        (setq idris-interpreter-path "${pkgs.idris}/bin/idris")
      '';
    };

    markdown-mode = {
      mode = [ ''"\\.mdwn\\'"'' ''"\\.markdown\\'"'' ''"\\.md\\'"'' ];
    };

    nix-mode = { mode = [ ''"\\.nix\\'"'' ]; };

    notmuch = {
      config = ''
        (setq notmuch-command "${pkgs.notmuch}/bin/notmuch")
      '';
    };

    octave = { mode = [ ''("\\.m\\'" . octave-mode)'' ]; };

    ob-plantuml = {
      config = ''
        (setq org-plantuml-jar-path "${pkgs.plantuml}/lib/plantuml.jar")
      '';
    };

    org-roam = {
      config = ''
        (setq org-roam-graph-executable "${pkgs.graphviz}/bin/dot")
      '';
    };

    pandoc-mode = {
      config = ''
        (setq pandoc-binary "${pkgs.pandoc}/bin/pandoc")
      '';
    };

    plantuml-mode = {
      config = ''
        (setq plantuml-jar-path "${pkgs.plantuml}/lib/plantuml.jar")
      '';
    };

    protobuf-mode = { mode = [ ''"'\\.proto\\'"'' ]; };

    ripgrep = {
      config = ''
        (setq ripgrep-executable "${pkgs.ripgrep}/bin/rg")
      '';
    };

    rust-mode = { mode = [ ''"\\.rs\\'"'' ]; };

    terraform-mode = { mode = [ ''"\\.tf\\'"'' ]; };

    yaml-mode = { mode = [ ''"\\.\\(e?ya?\\|ra\\)ml\\'"'' ]; };
  };
}
