{ config, pkgs, lib, ... }:
let
  profileCommon = {
    extensions = (
      with pkgs.vscode-extensions; [
        eamodio.gitlens
        file-icons.file-icons
        llvm-vs-code-extensions.vscode-clangd
        mesonbuild.mesonbuild
        mkhl.direnv
        ms-python.black-formatter
        ms-python.python
        ms-python.vscode-pylance
        ms-vscode-remote.remote-ssh
        redhat.vscode-yaml
        shardulm94.trailing-spaces
        shd101wyy.markdown-preview-enhanced
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
      "diffEditor.codeLens" = true;
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

      "direnv.restart.automatic" = true;
      "markdown-preview-enhanced.previewTheme" = "monokai.css";
      "mesonbuild.buildFolder" = "build";
      "mesonbuild.downloadLanguageServer" = false;
      "mesonbuild.formatting.enabled" = true;
      "mesonbuild.linter.muon.enabled" = true;
      "redhat.telemetry.enabled" = false;
    };
  };
in
{
  home.sessionVariables = {
    EDITOR = "code -w";
    CONTINUE_GLOBAL_DIR = "${config.xdg.configHome}/continue";
  };
  home.packages = with pkgs; [
    clang
    clang-tools
    jsonnet-language-server
    meson
    mesonlsp
    muon
    ninja
    pkg-config
  ];
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.overrideAttrs (prev: {
      preFixup = prev.preFixup + ''
        gappsWrapperArgs+=(
          --unset NIXOS_OZONE_WL
        )
      '';
    });
    profiles.default = lib.mkMerge [
      profileCommon
      {
        extensions = with pkgs.vscode-extensions; [
          jnoortheen.nix-ide
          ms-vscode-remote.remote-containers
          ms-vscode.cpptools
          platformio.platformio-vscode-ide
          skellock.just
        ] ++ (with pkgs.vscode-marketplace; [
          google.geminicodeassist
          wokwi.wokwi-vscode
        ]);
        userSettings = {
          "geminicodeassist.enableTelemetry" = false;
          "geminicodeassist.customCommands" = {
            "git-commit" = builtins.concatStringsSep " " [
              "You will act as a git commit message generator."
              "Commits should follow the Conventional Commits specification."
              "Changes have been staged."
              "You can run `git diff --cached` to get the changes."
              "Write your output to file `.git/COMMIT_EDITMSG`."
              "50 is the maximum number of characters of the commit title."
              "72 is the maximum character length of the commit body."
            ];
          };
          "geminicodeassist.rules" = ''
            Never ask "Would you like me to make this change for you?" Just do it.
          '';
          "geminicodeassist.inlineSuggestions.enableAuto" = false;
          "geminicodeassist.inlineSuggestions.nextEditPredictions" = false;
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "${lib.getExe pkgs.nil}";
          "nix.serverSettings" = {
            nil.formatting.command = [ (lib.getExe pkgs.nixpkgs-fmt) ];
            nix = {
              autoEvalInputs = true;
              nixpkgsInputName = "nixpkgs";
            };
          };
          "platformio-ide.customPyPiIndexUrl" = "https://mirror.nju.edu.cn/pypi/web/simple";
          "remote.autoForwardPorts" = false;
        };
      }
    ];
    profiles.work = lib.mkMerge [
      profileCommon
      {
        extensions = with pkgs.vscode-marketplace; [
          continue.continue
        ];
        userSettings = {
          "git.alwaysSignOff" = true;

          "yaml.schemas" = {
            "file://${config.home.homeDirectory}/.vscode/extensions/continue.continue/config-yaml-schema.json" = [
              ".continue/**/*.yaml"
            ];
          };
        };
      }
    ];
  };
  home.file.".vscode/argv.json".text = builtins.toJSON {
    password-store = "gnome-libsecret";
    enable-crash-reporter = false;
    crash-reporter-id = "ed2b3d47-3938-47db-a79b-19c13fe3bc1f";
  };
}
