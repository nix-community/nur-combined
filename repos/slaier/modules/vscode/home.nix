{ config, pkgs, lib, nixosConfig, ... }: {
  home.sessionVariables.EDITOR = "code -w";
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    extensions = (
      with pkgs.vscode-extensions; [
        eamodio.gitlens
        file-icons.file-icons
        jnoortheen.nix-ide
        llvm-vs-code-extensions.vscode-clangd
        mkhl.direnv
        ms-python.python
        ms-vscode-remote.remote-containers
        ms-vscode-remote.remote-ssh
        ms-vscode.makefile-tools
        redhat.vscode-yaml
        shardulm94.trailing-spaces
        tamasfe.even-better-toml
        timonwong.shellcheck
        tyriar.sort-lines
        yzhang.markdown-all-in-one
      ]
    );
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
    ];
    userSettings = {
      "editor.bracketPairColorization.enabled" = true;
      "editor.formatOnPaste" = true;
      "editor.formatOnType" = true;
      "editor.guides.bracketPairs" = "active";
      "editor.inlayHints.enabled" = "off";
      "editor.minimap.enabled" = false;
      "editor.renderWhitespace" = "all";
      "editor.rulers" = [ 80 120 ];
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

      "clangd.path" = pkgs.clang-tools + "/bin/clangd";
      "dev.containers.defaultExtensions" = [
        "Tyriar.sort-lines"
        "eamodio.gitlens"
        "shardulm94.trailing-spaces"
      ];
      "dev.containers.dockerComposePath" = lib.getExe pkgs.podman-compose;
      "dev.containers.dockerPath" = lib.getExe pkgs.podman;
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "${lib.getExe pkgs.nil}";
      "nix.serverSettings" = {
        nil.formatting.command = [ (lib.getExe pkgs.nixpkgs-fmt) ];
        nix = {
          autoEvalInputs = true;
          nixpkgsInputName = "nixpkgs";
        };
      };
      "redhat.telemetry.enabled" = false;
    };
  };
}
