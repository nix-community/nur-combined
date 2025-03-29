{ pkgs, lib, ... }:
let
  getName = x: x.meta.mainProgram or (lib.getName x);
in
{
  home.sessionVariables.EDITOR = "code -w";
  home.packages = with pkgs; [
    clang
    clang-tools
    jsonnet-language-server
    meson
    muon
    ninja
    pkg-config
    podman
    podman-compose
    pkgs.nur.repos.bandithedoge.mesonlsp-bin
  ];
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.overrideAttrs (prev: {
      preFixup = prev.preFixup + ''
        gappsWrapperArgs+=(
          --unset NIXOS_OZONE_WL
          --set DISPLAY :0
        )
      '';
    });
    extensions = (
      with pkgs.vscode-extensions; [
        eamodio.gitlens
        file-icons.file-icons
        github.copilot
        github.copilot-chat
        grafana.vscode-jsonnet
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
        shardulm94.trailing-spaces
        shd101wyy.markdown-preview-enhanced
        skellock.just
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
      "diffEditor.ignoreTrimWhitespace" = false;
      "editor.bracketPairColorization.enabled" = true;
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

      "dev.containers.defaultExtensions" = [
        "Tyriar.sort-lines"
        "eamodio.gitlens"
        "shardulm94.trailing-spaces"
      ];
      "dev.containers.dockerComposePath" = getName pkgs.podman-compose;
      "dev.containers.dockerPath" = getName pkgs.podman;
      "direnv.restart.automatic" = true;
      "jsonnet.languageServer.enableAutoUpdate" = false;
      mesonbuild = {
        buildFolder = "build";
        downloadLanguageServer = false;
        formatting.enabled = true;
        linter.muon.enabled = true;
      };
      "markdown-preview-enhanced.previewTheme" = "monokai.css";
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
  home.file.".vscode/argv.json".text = builtins.toJSON {
    password-store = "gnome-libsecret";
    enable-crash-reporter = false;
    crash-reporter-id = "ed2b3d47-3938-47db-a79b-19c13fe3bc1f";
  };
}
