{ config, lib, pkgs, ... }:

let
  inherit (builtins) listToAttrs tail;
  inherit (config.fonts) fontconfig;
  inherit (lib) concatMapStringsSep escapeShellArg getExe getExe' hm makeBinPath nameValuePair range;

  palette = import ../library/palette.lib.nix { inherit lib pkgs; };

  userDir = "${config.xdg.configHome}/VSCodium/User";

  biome = {
    "editor.defaultFormatter" = "biomejs.biome";
  };
  inert = {
    "editor.autoClosingBrackets" = "never";
    "editor.autoClosingQuotes" = "never";
    "editor.autoIndent" = "none";
    "editor.autoSurround" = "never";
  };
  monospace = {
    "editor.fontFamily" = concatMapStringsSep ", " (f: "'${f}'") fontconfig.defaultFonts.monospace;
    "editor.wrappingStrategy" = "simple";
  };
  prettier = {
    "editor.defaultFormatter" = "esbenp.prettier-vscode";
  };
in
{
  nixpkgs.config.allowUnfreePackages = [
    "vscode-extension-mhutchie-git-graph"
    "vscode-extension-ms-vsliveshare-vsliveshare"
  ];

  programs.vscodium = {
    enable = true;
    mutableExtensionsDir = false;

    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      extensions = with pkgs.vscode-extensions; [
        (andrewkvalheim.monokai-achromatic-gray.override { blackLevel = palette.rgb.black.g; })
        bierner.markdown-checkbox
        bierner.markdown-mermaid
        bierner.markdown-preview-github-styles
        biomejs.biome
        bpruitt-goddard.mermaid-markdown-syntax-highlighting
        charliermarsh.ruff
        compilouit.xkb
        coolbear.systemd-unit-file
        csstools.postcss
        denoland.vscode-deno
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
        jacobpfeifer.pfeifer-hurl
        jjk.jjk
        joaompinto.vscode-graphviz
        jock.svg
        jnbt.vscode-rufo
        jnoortheen.nix-ide
        karunamurti.haml
        kdl-org.kdl
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
        sissel.shopify-liquid
        stkb.rewrap
        streetsidesoftware.code-spell-checker
        stylelint.vscode-stylelint
        syler.sass-indented
        sysoev.language-stylus
        tamasfe.even-better-toml
        timonwong.shellcheck
        unifiedjs.vscode-mdx
        # volkerdobler.insertnums # FIXME: Unavailable
        webfreak.advanced-local-formatters
        xaver.clang-format
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
        # Permissions
        "json.schemaDownload.trustedDomains" = {
          "https://biomejs.dev" = true;
          "https://json-schema.org/" = true;
          "https://json.schemastore.org/" = true;
          "https://www.schemastore.org/" = true;
        };

        # Dependencies
        "biome.lsp.bin" = getExe pkgs.biome;
        "clang-format.executable" = getExe' pkgs.clang-tools "clang-format";
        "deno.path" = getExe pkgs.deno;
        "flow.pathToFlow" = getExe pkgs.flow;
        "hadolint.hadolintPath" = getExe pkgs.hadolint;
        "jjk.jjPath" = getExe pkgs.jujutsu;
        "nix.serverPath" = getExe pkgs.nil;
        "nix.serverSettings".nil.formatting.command = [ (getExe pkgs.nixpkgs-fmt) ];
        "php.validate.executablePath" = getExe pkgs.php;
        "prettier.prettierPath" = "${pkgs.prettier}/lib/node_modules/prettier/index.cjs";
        "python.formatting.blackPath" = getExe pkgs.black;
        "rubyLsp.customRubyCommand" = "PATH=${makeBinPath (with pkgs; [ nodejs ruby ruby-lsp ])}:$PATH";
        "ruff.path" = [ (getExe pkgs.ruff) ];
        "ruff.nativeServer" = true;
        "rufo.exe" = getExe pkgs.rufo;
        "rust-analyzer.server.path" = getExe pkgs.rust-analyzer;
        "shellcheck.executablePath" = getExe pkgs.shellcheck;
        "stylelint.stylelintPath" = "${pkgs.stylelint}/lib/node_modules/stylelint";

        # Custom formatters
        "advancedLocalFormatters.formatters" = with pkgs; [
          { languages = [ "diff" ]; command = [ (getExe' patchutils "rediff") "-" ]; }
          { languages = [ "hurl" ]; command = [ (getExe' hurl "hurlfmt") ]; }
          { languages = [ "kdl" ]; command = [ (getExe kdlfmt) "format" "-" ]; }
        ];

        # Advertisements
        "chat.commandCenter.enabled" = false; # Microsoft GitHub Copilot

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
        "editor.fontFamily" = concatMapStringsSep ", " (f: "'${f}'") ([ "Iosevka Custom Proportional" ] ++ tail fontconfig.defaultFonts.sansSerif);
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
        "window.titleSeparator" = " · ";
        "workbench.activityBar.location" = "hidden";
        "workbench.colorTheme" = "Monokai Achromatic Gray";
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
        "jjk.enableAnnotations" = false;
        "scm.diffDecorationsIgnoreTrimWhitespace" = "true";

        # Colors
        "workbench.colorCustomizations" = {
          "terminal.foreground" = ansi.white;
          "terminal.background" = ansi.black;
          "terminal.ansiblack" = ansi.black;
          "terminal.ansired" = ansi.red;
          "terminal.ansigreen" = ansi.green;
          "terminal.ansiyellow" = ansi.yellow;
          "terminal.ansiblue" = ansi.blue;
          "terminal.ansimagenta" = ansi.magenta;
          "terminal.ansicyan" = ansi.cyan;
          "terminal.ansiwhite" = ansi.white;
          "terminal.ansibrightblack" = ansi.bright.black;
          "terminal.ansibrightred" = ansi.bright.red;
          "terminal.ansibrightgreen" = ansi.bright.green;
          "terminal.ansibrightyellow" = ansi.bright.yellow;
          "terminal.ansibrightblue" = ansi.bright.blue;
          "terminal.ansibrightmagenta" = ansi.bright.magenta;
          "terminal.ansibrightcyan" = ansi.bright.cyan;
          "terminal.ansibrightwhite" = ansi.bright.white;
          "tab.inactiveBackground" = "#00000000";
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
          "editorGhostText.foreground" = blue-dim;
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
        "nix.hiddenLanguageServerErrors" = [ "textDocument/documentSymbol" ]; # Workaround for nix-community/vscode-nix-ide#387
        "python.formatting.provider" = "black";
        "rubyLsp.rubyVersionManager".identifier = "custom";
        "rust-analyzer.check.command" = "clippy";
        "[coffeescript]" = monospace;
        "[cpp]" = monospace;
        "[css]" = biome;
        "[diff]" = monospace;
        "[git-commit]" = monospace // { "editor.rulers" = [ 50 72 ]; "rewrap.wrappingColumn" = 72; };
        "[html]" = prettier // { "editor.formatOnSave" = false; /* Workaround for kristoff-it/superhtml#33 */ };
        "[javascript]" = biome;
        "[json]" = biome;
        "[jsonc]" = biome;
        "[markdown]" = monospace // { "editor.tabSize" = 4; };
        "[plaintext]" = inert // monospace;
        "[postcss]" = prettier;
        "[ruby]" = monospace // { "editor.defaultFormatter" = "jnbt.vscode-rufo"; "editor.formatOnSave" = false; };
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
          "**/.jj" = true;
          "**/.parcel-cache" = true;
          "**/.ruff_cache" = true;
          "**/.Trash-*" = true;
          "**/.vagrant" = true;
          "**/.venv" = true;
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

      languageSnippets = rec {
        git-commit = {
          "Co-authored-by" = {
            "prefix" = "co";
            "body" = [ "Co-authored-by: $1 <$2>" ];
          };
        };
        jj-commit = git-commit;
      };
    };
  };

  home.sessionVariables = rec {
    EDITOR = "${getExe pkgs.vscodium} --wait";
    VISUAL = EDITOR;
  };

  programs.zsh.shellAliases.code = "codium";

  programs.git.settings."mergetool \"code\"".cmd = "${getExe pkgs.vscodium} --wait --merge $REMOTE $LOCAL $BASE $MERGED";

  home.activation.biome = hm.dag.entryAfter [ "writeBoundary" ] ''
    if [[ -d ${escapeShellArg userDir}'/globalStorage/biomejs.biome/tmp-bin' ]]; then
      ${getExe' pkgs.uutils-findutils "find"} ${escapeShellArg userDir}'/globalStorage/biomejs.biome/tmp-bin' \
        -mindepth '1' \
        -printf 'Purge %p\n' \
        -delete
    fi
  '';
}
