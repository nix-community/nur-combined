{ lib, pkgs, ... }:

let
  inherit (builtins) listToAttrs;
  inherit (lib) makeBinPath nameValuePair range;

  palette = import ../resources/palette.nix { inherit lib pkgs; };

  biome = {
    "editor.defaultFormatter" = "biomejs.biome";
  };
  monospace = {
    "editor.fontFamily" = "'Iosevka Custom Mono'";
    "editor.wrappingStrategy" = "simple";
  };
  prettier = {
    "editor.defaultFormatter" = "esbenp.prettier-vscode";
  };
in
{
  allowedUnfree = [
    "vscode-extension-mhutchie-git-graph"
    "vscode-extension-ms-vsliveshare-vsliveshare"
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    enableUpdateCheck = false;

    mutableExtensionsDir = false;
    enableExtensionUpdateCheck = false;
    extensions = with pkgs.vscode-extensions; [
      bierner.markdown-checkbox
      bierner.markdown-mermaid
      bierner.markdown-preview-github-styles
      biomejs.biome
      bpruitt-goddard.mermaid-markdown-syntax-highlighting
      charliermarsh.ruff
      compilouit.xkb
      coolbear.systemd-unit-file
      csstools.postcss
      earshinov.permute-lines
      earshinov.simple-alignment
      editorconfig.editorconfig
      esbenp.prettier-vscode
      eseom.nunjucks-template
      exiasr.hadolint
      dbaeumer.vscode-eslint
      fabiospampinato.vscode-highlight
      flowtype.flow-for-vscode
      hashicorp.terraform
      irongeek.vscode-env
      joaompinto.vscode-graphviz
      jock.svg
      jnbt.vscode-rufo
      jnoortheen.nix-ide
      karunamurti.haml
      kokakiwi.vscode-just
      leighlondon.eml
      loriscro.super
      matthewpi.caddyfile-support
      mechatroner.rainbow-csv
      mhutchie.git-graph
      mitchdenny.ecdc
      ms-pyright.pyright
      ms-python.isort
      ms-python.python
      ms-vscode.wasm-wasi-core # Dependency of loriscro.super
      ms-vsliveshare.vsliveshare
      pkief.material-icon-theme
      ronnidc.nunjucks
      rust-lang.rust-analyzer
      samuelcolvin.jinjahtml
      shopify.ruby-lsp
      silvenon.mdx
      sissel.shopify-liquid
      stkb.rewrap
      streetsidesoftware.code-spell-checker
      stylelint.vscode-stylelint
      syler.sass-indented
      tamasfe.even-better-toml
      theaflowers.qalc
      timonwong.shellcheck
      volkerdobler.insertnums
    ];

    keybindings = [
      { key = "alt+pagedown"; command = "workbench.action.navigateForward"; when = "canNavigateForward"; }
      { key = "alt+pageup"; command = "workbench.action.navigateBack"; when = "canNavigateBack"; }
      { key = "ctrl+j"; command = "-workbench.action.togglePanel"; }
      { key = "ctrl+j"; command = "editor.action.joinLines"; }
      { key = "shift+alt+m"; command = "editor.emmet.action.wrapWithAbbreviation"; }
      { key = "shift+alt+down"; command = "-editor.action.insertCursorBelow"; }
      { key = "shift+alt+down"; command = "editor.action.copyLinesDownAction"; }
      { key = "shift+alt+up"; command = "-editor.action.insertCursorAbove"; }
      { key = "shift+alt+up"; command = "editor.action.copyLinesUpAction"; }
      { key = "ctrl+k i"; command = "editor.action.formatChanges"; }
      { when = "isInDiffEditor"; key = "ctrl+t"; command = "git.stageSelectedRanges"; }
    ];

    userSettings = with palette.hex; {
      # Dependencies
      "biome.lsp.bin" = "${pkgs.biome}/bin/biome";
      "flow.pathToFlow" = "${pkgs.flow}/bin/flow";
      "hadolint.hadolintPath" = "${pkgs.hadolint}/bin/hadolint";
      "nix.serverPath" = "${pkgs.nil}/bin/nil";
      "nix.serverSettings".nil.formatting.command = [ "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt" ];
      "php.validate.executablePath" = "${pkgs.php}/bin/php";
      "prettier.prettierPath" = "${pkgs.nodePackages.prettier}/lib/node_modules/prettier/index.cjs"; # Pending prettier/prettier-vscode#3100
      "python.formatting.blackPath" = "${pkgs.black}/bin/black";
      "qalc.path" = "${pkgs.libqalculate}/bin/qalc";
      "rubyLsp.customRubyCommand" = "PATH=${makeBinPath (with pkgs; [ nodejs ruby ruby-lsp ])}:$PATH";
      "ruff.path" = [ "${pkgs.ruff}/bin/ruff" ];
      "ruff.nativeServer" = true;
      "rufo.exe" = "${pkgs.rufo}/bin/rufo";
      "shellcheck.executablePath" = "${pkgs.shellcheck}/bin/shellcheck";
      "stylelint.stylelintPath" = "${pkgs.nodePackages.stylelint}/lib/node_modules/stylelint";

      # Application
      "breadcrumbs.enabled" = false;
      "debug.showBreakpointsInOverviewRuler" = true;
      "diffEditor.diffAlgorithm" = "advanced";
      "diffEditor.experimental.showMoves" = true;
      "diffEditor.renderSideBySide" = false;
      "editor.acceptSuggestionOnCommitCharacter" = false;
      "editor.acceptSuggestionOnEnter" = "off";
      "editor.copyWithSyntaxHighlighting" = false;
      "editor.cursorSurroundingLines" = 10;
      "editor.dragAndDrop" = false;
      "editor.fontFamily" = "'Iosevka Custom Proportional'";
      "editor.fontLigatures" = true;
      "editor.fontSize" = 15;
      "editor.inlayHints.enabled" = "off";
      "editor.linkedEditing" = true;
      "editor.minimap.enabled" = false;
      "editor.multiCursorModifier" = "ctrlCmd";
      "editor.occurrencesHighlight" = "multiFile";
      "editor.suggest.localityBonus" = true;
      "editor.unfoldOnClickAfterEndOfLine" = true;
      "editor.wrappingStrategy" = "advanced";
      "explorer.confirmDelete" = false;
      "markdown.preview.linkify" = false;
      "search.useIgnoreFiles" = false;
      "security.workspace.trust.banner" = "never";
      "terminal.integrated.fontFamily" = "'Iosevka Custom Term'";
      "terminal.integrated.scrollback" = 100000;
      "update.mode" = "none";
      "window.customMenuBarAltFocus" = false;
      "window.enableMenuBarMnemonics" = false;
      "window.titleBarStyle" = "custom";
      "window.titleSeparator" = " · ";
      "workbench.activityBar.location" = "hidden";
      "workbench.colorTheme" = "Monokai";
      "workbench.editor.closeEmptyGroups" = false;
      "workbench.editor.tabActionCloseVisibility" = false;
      "workbench.editor.tabSizing" = "shrink";
      "workbench.editor.empty.hint" = "hidden";
      "workbench.enableExperiments" = false;
      "workbench.iconTheme" = "material-icon-theme";
      "workbench.sideBar.location" = "right";
      "workbench.startupEditor" = "none";
      "workbench.tips.enabled" = false;

      # Formatting
      "editor.tabSize" = 2;
      "files.insertFinalNewline" = true;
      "html.format.extraLiners" = "";
      "html.format.indentInnerHtml" = true;

      # Version control
      "diffEditor.ignoreTrimWhitespace" = false;
      "git.alwaysShowStagedChangesResourceGroup" = true;
      "git.enableStatusBarSync" = false;
      "git.showActionButton" = { commit = false; publish = false; sync = false; };
      "git.suggestSmartCommit" = false;

      # Colors
      "workbench.colorCustomizations" = {
        # "activitybarbadge.background" = "#ff7042";
        # "editor.selectionhighlightbackground" = "#54320a";
        # "editorsuggestwidget.highlightforeground" = "#ff7042";
        # "list.activeselectionforeground" = "#ff7042";
        # "list.highlightforeground" = "#ff7042";
        # "list.inactiveselectionforeground" = "#ff7042";
        # "pickergroup.foreground" = "#ff7042";
        # "progressbar.background" = "#ff7042";
        # "scrollbarslider.activebackground" = "#ff704250";
        # "tab.activeborder" = "#ff7042";
        # "tab.inactivebackground" = "#1e1f1c";
        # "textlink.foreground" = "#ff7042";
        "terminal.foreground" = white;
        "terminal.background" = black;
        "terminal.ansiblack" = white-dark;
        "terminal.ansired" = red;
        "terminal.ansigreen" = green;
        "terminal.ansiyellow" = yellow;
        "terminal.ansiblue" = blue;
        "terminal.ansimagenta" = orange;
        "terminal.ansicyan" = purple;
        "terminal.ansiwhite" = white;
        "terminal.ansibrightblack" = white-dim;
        "terminal.ansibrightred" = red;
        "terminal.ansibrightgreen" = green;
        "terminal.ansibrightyellow" = yellow;
        "terminal.ansibrightblue" = blue;
        "terminal.ansibrightmagenta" = orange;
        "terminal.ansibrightcyan" = purple;
        "terminal.ansibrightwhite" = white;
        "tab.inactiveBackground" = black;
        "editorGroupHeader.tabsBackground" = black;
        "editorGutter.addedBackground" = blue;
        "editorGutter.deletedBackground" = blue;
        "editorGutter.modifiedBackground" = blue;
        "editorOverviewRuler.addedForeground" = blue;
        "editorOverviewRuler.deletedForeground" = blue;
        "editorOverviewRuler.modifiedForeground" = blue;
        "gitDecoration.modifiedResourceForeground" = blue;
        "gitDecoration.untrackedResourceForeground" = blue-dark;
        "editorInfo.foreground" = purple;
        "editorMarkerNavigationWarning.background" = orange;
        "editorOverviewRuler.warningForeground" = orange;
        "editorWarning.foreground" = orange;
        "list.warningForeground" = orange;
        "diffEditor.removedLineBackground" = "${vermilion}11";
        "diffEditor.removedTextBackground" = "${vermilion}33";
        "diffEditor.insertedTextBackground" = "${teal}33";
        "diffEditor.insertedLineBackground" = "${teal}11";
        "commandCenter.background" = "#1b1b1b";
        "commandCenter.border" = "#00000000";
        "commandCenter.inactiveBorder" = "#00000000";
        "sideBar.border" = "#00000000";
        "statusBar.border" = "#00000000";
        "statusBarItem.remoteBackground" = "#00000000";
        "titleBar.border" = "#00000000";
        "editor.findMatchHighlightBackground" = "#00000000";
        "editor.findMatchHighlightBorder" = "#aaaaaa";
        "editor.selectionHighlightBackground" = "#464646cc";
        "editorError.foreground" = red;
        "editorMarkerNavigationError.background" = red-dark;
        "editorOverviewRuler.errorForeground" = red;
        "gitDecoration.conflictingResourceForeground" = red;
        "inputValidation.errorBackground" = red-dark;
        "list.errorForeground" = red;
        "list.invalidItemForeground" = red;
        "editorBracketHighlight.unexpectedBracket.foreground" = red;
        "editorBracketHighlight.foreground1" = teal;
        "editorBracketHighlight.foreground2" = purple;
        "editorBracketHighlight.foreground3" = teal;
        "editorBracketHighlight.foreground4" = purple;
        "editorBracketHighlight.foreground5" = teal;
        "editorBracketHighlight.foreground6" = purple;
      };
      "editor.tokenColorCustomizations" = {
        textMateRules = [
          { scope = "constant.numeric"; settings = { foreground = yellow; }; }
          { scope = "constant.other.caps"; settings = { foreground = platinum; }; }
          { scope = "entity.name.function.macro"; settings = { foreground = blue; }; }
          { scope = "entity.name.namespace"; settings = { foreground = purple; }; }
          { scope = "entity.name.type.lifetime"; settings = { foreground = orange; fontStyle = "italic"; }; }
          { scope = "entity.name.type.numeric"; settings = { foreground = purple; fontStyle = ""; }; }
          { scope = "entity.name.type.primitive"; settings = { foreground = purple; fontStyle = ""; }; }
          { scope = "entity.name.type"; settings = { foreground = purple; fontStyle = "underline"; }; }
          { scope = "keyword.operator.access.dot"; settings = { foreground = platinum; }; }
          { scope = "keyword.operator.attribute"; settings = { foreground = blue; }; }
          { scope = "keyword.operator.borrow"; settings = { foreground = orange; }; }
          { scope = "keyword.operator.namespace"; settings = { foreground = platinum; }; }
          { scope = "meta.attribute"; settings = { foreground = blue; }; }
          { scope = "meta.interpolation"; settings = { foreground = platinum; }; }
          { scope = "punctuation.brackets.angle.rust, keyword.operator.namespace.rust"; settings = { foreground = purple; }; }
          { scope = "punctuation.definition.interpolation"; settings = { foreground = red; }; }
          { scope = "punctuation.definition.lifetime"; settings = { foreground = orange; fontStyle = "italic"; }; }
          { scope = "storage.type"; settings = { foreground = red; fontStyle = ""; }; }
          { scope = "storage.modifier"; settings = { foreground = orange; }; }
          { scope = "variable.language.self, variable.language.super"; settings = { foreground = purple; fontStyle = "italic"; }; }
        ];
      };
      "cSpell.useCustomDecorations" = false;

      # Language-specific
      "emmet.includeLanguages" = { postcss = "css"; };
      "flow.useNPMPackagedFlow" = false;
      "files.associations" =
        (listToAttrs (map (n: nameValuePair "*.log.${toString n}" "log") (range 1 10))) // {
          ".ansible-lint" = "yaml";
          ".htmlnanorc" = "json";
          ".mapcss" = "css";
          ".parcelrc" = "jsonc";
          ".postcssrc" = "json";
          "*.bu" = "yaml";
        };
      "markdown-mermaid.darkModeTheme" = "default";
      "nix.enableLanguageServer" = true;
      "python.formatting.provider" = "black";
      "rubyLsp.rubyVersionManager" = "custom";
      "rust-analyzer.checkOnSave.command" = "clippy";
      "[css]" = biome;
      "[diff]" = monospace;
      "[git-commit]" = monospace // { "editor.rulers" = [ 50 72 ]; "rewrap.wrappingColumn" = 72; };
      "[html]" = prettier // { "editor.formatOnSave" = false; /* Workaround for kristoff-it/superhtml#33 */ };
      "[javascript]" = biome;
      "[json]" = biome;
      "[jsonc]" = biome;
      "[markdown]" = monospace // { "editor.tabSize" = 4; };
      "[plaintext]" = monospace;
      "[postcss]" = prettier;
      "[ruby]" = monospace;
      "[typescript]" = biome;
      "[typescriptreact]" = biome;
      "[yaml]" = monospace;

      # Highlights
      "editor.unicodeHighlight.allowedCharacters" = {
        "’" = true;
        "×" = true;
      };
      "highlight.minDelay" = 2000; # Workaround for fabiospampinato/vscode-highlight#139
      "highlight.decorations" = { rangeBehavior = 1; };
      "highlight.regexFlags" = "g";
      "highlight.regexes" = {
        "(FIXME)" = {
          decorations = [{
            backgroundColor = red;
            color = black;
            fontStyle = "italic";
            fontWeight = "bold";
            overviewRulerColor = red;
          }];
        };
        "(OPTIMIZE)" = {
          decorations = [{
            backgroundColor = orange;
            color = black;
            fontStyle = "italic";
            fontWeight = "bold";
            overviewRulerColor = orange;
          }];
        };
        "(TODO)" = {
          decorations = [{
            backgroundColor = orange;
            color = black;
            fontStyle = "italic";
            fontWeight = "bold";
            overviewRulerColor = orange;
          }];
        };
        "((?<=^|\\S) $)" = {
          regexFlags = "gm";
          filterLanguageRegex = "markdown";
          decorations = [{
            backgroundColor = "${orange}66";
            overviewRulerColor = orange;
          }];
        };
        "((?<=^|\\S)  $)" = {
          regexFlags = "gm";
          filterLanguageRegex = "markdown";
          decorations = [{
            backgroundColor = "${white}66";
          }];
        };
        "((?<=^|\\S)(?:   +|[ \\t]*\\t[ \\t]*)$)" = {
          regexFlags = "gm";
          filterLanguageRegex = "markdown";
          decorations = [{
            backgroundColor = "${orange}66";
            overviewRulerColor = orange;
          }];
        };
        "([ \\t]+$)" = {
          regexFlags = "gm";
          filterLanguageRegex = ".*(?<!markdown)$";
          decorations = [{
            backgroundColor = "${orange}66";
            overviewRulerColor = orange;
          }];
        };
        "(\\t)" = {
          decorations = [{
            after = {
              contentText = "​";
              backgroundColor = "${white}22";
              margin = "0 1px 0 -3px";
              width = "2px";
            };
          }];
        };
        "([\\u00a0\\u00ad\\u115f\\u2000-\\u200e\\u202f\\u205f\\u2060-\\u2061\\u2800\\u3000\\u3164\\ufeff\\uffa0])" = {
          decorations = [{
            backgroundColor = "${purple}66";
            border = "1px solid ${purple}";
          }];
        };
        "([^\\s|#/]|[^/]/)( {2,})([^\\s|])" = {
          decorations = [{ }
            {
              backgroundColor = "${black}88";
              overviewRulerColor = "${black}88";
            }
            { }];
        };
      };

      # Environment
      "files.exclude" = {
        "**/.~lock.*" = true;
        "**/.bundle" = true;
        "**/.cache" = true;
        "**/.direnv" = true;
        "**/.parcel-cache" = true;
        "**/.ruff_cache" = true;
        "**/.Trash-*" = true;
        "**/.vagrant" = true;
        "**/.vscode" = true;
        "**/.yarn" = true;
        "**/__pycache__" = true;
        "**/node_modules" = true;
        "**/result" = true;
      };
      "rust-client.disableRustup" = true;
      "shellcheck.disableVersionCheck" = true;

      # Icons
      "material-icon-theme.files.associations" = {
        "*.🡕" = "Http";
        ".envrc" = "Tune";
      };
      "material-icon-theme.folders.associations" = {
        "[post]" = "Docs";
        "benches" = "Benchmark";
        "browser-extension" = "Plugin";
        "endpoints" = "Routes";
        "entrypoints" = "Routes";
        "hosts" = "Server";
        "local" = "Environment";
        "migration" = "Database";
        "site" = "Public";
      };
    };
  };

  home.sessionVariables = rec {
    EDITOR = "${pkgs.vscodium}/bin/codium --wait";
    VISUAL = EDITOR;
  };

  programs.zsh.shellAliases.code = "codium";

  programs.git.extraConfig."mergetool \"code\"".cmd = "${pkgs.vscodium}/bin/codium --wait --merge $REMOTE $LOCAL $BASE $MERGED";
}
