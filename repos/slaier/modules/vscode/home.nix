{ pkgs, lib, ... }:
{
  home.sessionVariables = {
    EDITOR = "code -w";
  };
  home.packages = with pkgs; [
    clang
    clang-tools
    meson
    mesonlsp
    muon
    ninja
    pkg-config
  ];
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      anthropic.claude-code
      eamodio.gitlens
      file-icons.file-icons
      jnoortheen.nix-ide
      llvm-vs-code-extensions.vscode-clangd
      mesonbuild.mesonbuild
      mkhl.direnv
      ms-python.black-formatter
      ms-python.python
      ms-python.vscode-pylance
      ms-vscode-remote.remote-containers
      ms-vscode-remote.remote-ssh
      redhat.vscode-yaml
      rust-lang.rust-analyzer
      shardulm94.trailing-spaces
      shd101wyy.markdown-preview-enhanced
      skellock.just
      tamasfe.even-better-toml
      timonwong.shellcheck
      tyriar.sort-lines
      yzhang.markdown-all-in-one
    ];
    profiles.default = {
      keybindings = [
        {
          "key" = "ctrl+q";
          "command" = "-workbench.action.quit";
        }
        {
          "key" = "ctrl+q";
          "command" = "workbench.action.remote.close";
          "when" = "resourceScheme == 'vscode-remote'";
        }
        {
          "key" = "ctrl+q";
          "command" = "workbench.action.closeFolder";
          "when" = "resourceScheme != 'vscode-remote' && workbenchState != 'empty'";
        }
        {
          "key" = "ctrl+q";
          "command" = "workbench.action.closeWindow";
          "when" = "resourceScheme != 'vscode-remote' && workbenchState == 'empty'";
        }
        {
          key = "ctrl+enter";
          command = "-github.copilot.generate";
        }
        {
          key = "alt+\\";
          command = "github.copilot.generate";
          when = "editorTextFocus && github.copilot.activated && !commentEditorFocused && !inInteractiveInput && !interactiveEditorFocused";
        }
      ];
      userSettings = {
        "chat.disableAIFeatures" = true;
        "diffEditor.codeLens" = true;
        "diffEditor.ignoreTrimWhitespace" = false;
        "editor.bracketPairColorization.enabled" = true;
        "editor.guides.bracketPairs" = "active";
        "editor.inlayHints.enabled" = "off";
        "editor.minimap.enabled" = false;
        "editor.renderWhitespace" = "all";
        "editor.rulers" = [
          80
          120
        ];
        "extensions.autoCheckUpdates" = false;
        "extensions.autoUpdate" = false;
        "files.insertFinalNewline" = true;
        "files.trimFinalNewlines" = true;
        "files.trimTrailingWhitespace" = true;
        "search.collapseResults" = "auto";
        "telemetry.telemetryLevel" = "off";
        "terminal.integrated.automationProfile.linux" = {
          "path" = "bash";
          "icon" = "terminal-bash";
        };
        "terminal.integrated.copyOnSelection" = true;
        "terminal.integrated.defaultProfile.linux" = "fish";
        "terminal.integrated.profiles.linux" = {
          "fish" = {
            "path" = "env";
            "args" = [
              "fish"
            ];
          };
          "ash" = null;
          "sh" = null;
        };
        "update.mode" = "none";
        "workbench.colorTheme" = "Monokai";
        "workbench.commandPalette.preserveInput" = true;
        "workbench.editor.enablePreviewFromCodeNavigation" = true;
        "workbench.iconTheme" = "file-icons";

        "claudeCode.claudeProcessWrapper" = lib.getExe (
          pkgs.writeShellApplication {
            name = "claude-launcher";
            text = ''
              shift
              exec claude-mimo "$@"
            '';
          }
        );
        "claudeCode.disableLoginPrompt" = true;
        "claudeCode.preferredLocation" = "sidebar";
        "direnv.restart.automatic" = true;
        "markdown-preview-enhanced.previewTheme" = "monokai.css";
        "mesonbuild.buildFolder" = "build";
        "mesonbuild.downloadLanguageServer" = false;
        "mesonbuild.formatting.enabled" = true;
        "mesonbuild.linter.muon.enabled" = true;
        "redhat.telemetry.enabled" = false;
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "${lib.getExe pkgs.nixd}";
        "nix.serverSettings" = {
          nixd = {
            nixpkgs.expr = "import (builtins.getFlake (toString ./.)).inputs.nixpkgs { }";
            formatting.command = [ (lib.getExe pkgs.nixfmt) ];
            options.nixos.expr = "(builtins.getFlake (toString ./.)).nixosConfigurations.local.options";
          };
        };
        "nix.hiddenLanguageServerErrors" = [ "textDocument/definition" ];
        "remote.autoForwardPorts" = false;
      };
    };
  };
  home.file.".vscode/argv.json".text = builtins.toJSON {
    password-store = "gnome-libsecret";
    enable-crash-reporter = false;
    crash-reporter-id = "ed2b3d47-3938-47db-a79b-19c13fe3bc1f";
  };
}
