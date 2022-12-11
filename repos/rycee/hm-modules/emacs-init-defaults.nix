# A collection of "uncontroversial" configurations for selected packages.

{ pkgs, lib, config, ... }:

{
  programs.emacs.init.usePackage = {
    all-the-icons = { extraPackages = [ pkgs.emacs-all-the-icons-fonts ]; };

    cmake-mode.mode = [
      ''"\\.cmake\\'"'' # \
      ''"CMakeLists.txt\\'"''
    ];

    csharp-mode.mode = [ ''"\\.cs\\'"'' ];

    cue-mode = {
      package = epkgs:
        epkgs.trivialBuild {
          pname = "cue-mode.el";
          src = pkgs.fetchurl {
            url =
              "https://raw.githubusercontent.com/russell/cue-mode/9c803ee8fa4a6e99c7dc9ae373c6178569583b7a/cue-mode.el";
            sha256 = "0swhpknkg1vwbchblzrwynixf5grg95jy1bkc8w92yfpb1jch7m7";
          };
          preferLocalBuild = true;
          allowSubstitutes = true;
        };
      command = [ "cue-mode" ];
      mode = [ ''"\\.cue\\'"'' ];
      hook = [ "(cue-mode . subword-mode)" ];
    };

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

    dhall-mode.mode = [ ''"\\.dhall\\'"'' ];

    dockerfile-mode.mode = [ ''"Dockerfile\\'"'' ];

    elm-mode.mode = [ ''"\\.elm\\'"'' ];

    emacsql-sqlite3 = {
      enable =
        lib.mkDefault config.programs.emacs.init.usePackage.org-roam.enable;
      defer = lib.mkDefault true;
      config = ''
        (setq emacsql-sqlite3-executable "${pkgs.sqlite}/bin/sqlite3")
      '';
    };

    ggtags = {
      config = ''
        (setq ggtags-executable-directory "${pkgs.global}/bin")
      '';
    };

    idris-mode = {
      mode = [ ''"\\.idr\\'"'' ];
      config = ''
        (setq idris-interpreter-path "${pkgs.idris}/bin/idris")
      '';
    };

    kotlin-mode = {
      mode = [ ''"\\.kts?\\'"'' ];
      hook = [ "(kotlin-mode . subword-mode)" ];
    };

    latex.mode = [ ''("\\.tex\\'" . latex-mode)'' ];

    lsp-eslint = {
      config = ''
        (setq lsp-eslint-server-command '("node" "${pkgs.vscode-extensions.dbaeumer.vscode-eslint}/share/vscode/extensions/dbaeumer.vscode-eslint/server/out/eslintServer.js" "--stdio"))
      '';
    };

    markdown-mode = {
      mode = [ ''"\\.mdwn\\'"'' ''"\\.markdown\\'"'' ''"\\.md\\'"'' ];
    };

    nix-mode.mode = [ ''"\\.nix\\'"'' ];

    notmuch = {
      package = epkgs: lib.getOutput "emacs" pkgs.notmuch;
      config = ''
        (setq notmuch-command "${pkgs.notmuch}/bin/notmuch")
      '';
    };

    octave.mode = [ ''("\\.m\\'" . octave-mode)'' ];

    ob-plantuml = {
      config = ''
        (setq org-plantuml-jar-path "${pkgs.plantuml}/lib/plantuml.jar")
      '';
    };

    org-roam = {
      defines = [ "org-roam-graph-executable" ];
      config = ''
        (setq org-roam-graph-executable "${pkgs.graphviz}/bin/dot")
      '';
    };

    pandoc-mode = {
      config = ''
        (setq pandoc-binary "${pkgs.pandoc}/bin/pandoc")
      '';
    };

    php-mode.mode = [ ''"\\.php\\'"'' ];

    plantuml-mode = {
      mode = [ ''"\\.puml\\'"'' ];
      config = ''
        (setq plantuml-default-exec-mode 'executable
              plantuml-executable-path "${pkgs.plantuml}/bin/plantuml")
      '';
    };

    protobuf-mode.mode = [ ''"\\.proto\\'"'' ];

    purescript-mode.mode = [ ''"\\.purs\\'"'' ];

    ripgrep = {
      config = ''
        (setq ripgrep-executable "${pkgs.ripgrep}/bin/rg")
      '';
    };

    rust-mode.mode = [ ''"\\.rs\\'"'' ];

    terraform-mode.mode = [ ''"\\.tf\\'"'' ];

    yaml-mode.mode = [ ''"\\.\\(e?ya?\\|ra\\)ml\\'"'' ];
  };
}
