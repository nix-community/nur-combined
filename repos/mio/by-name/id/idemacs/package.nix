{
  lib,
  stdenvNoCC,
  fetchFromGitea,
  fetchFromGitHub,
  emacsPackages,
  git,
  gnugrep,
  makeWrapper,
  dejavu_fonts,
  copyDesktopItems,
  makeDesktopItem,
  curl,
  jq,
  nix,
  python3,
  writeShellApplication,
}:

let
  emacs = emacsPackages.emacsWithPackages (
    epkgs:
    (with epkgs; [
      adjust-parens
      anaconda-mode
      blamer
      breadcrumb
      centaur-tabs
      company
      consult
      consult-eglot
      dashboard
      diff-hl
      diminish
      drag-stuff
      eat
      expand-region
      flycheck-eglot
      gcmh
      geiser
      geiser-chicken
      geiser-guile
      helpful
      hideshowvis
      highlight-indent-guides
      highlight-parentheses
      idle-highlight-mode
      lsp-pyright
      magit
      marginalia
      markdown-mode
      mmm-mode
      multiple-cursors
      nameless
      orderless
      org-modern
      paredit
      pdf-tools
      rainbow-mode
      sly
      smartparens
      treemacs
      treemacs-magit
      treesit-auto
      undo-tree
      untitled-new-buffer
      vertico
      vscode-dark-plus-theme
      webpaste
      whole-line-or-region
      window-numbering
    ])
    ++ lib.optional isLinux dejavu_fonts
    ++ [
      # IDEmacs installs this directly from Git upstream.
      (epkgs.trivialBuild {
        pname = "explain-pause-mode";
        version = "0.1-unstable-2025-02-02";
        src = fetchFromGitHub {
          owner = "lastquestion";
          repo = "explain-pause-mode";
          rev = "ac3eb69f36f345506aad05a6d9bc3ef80d26914b";
          hash = "sha256-6FDYnE9rT12f2Lx3yg2tpDVm9txF2VoVxZvADpm4BoM=";
        };
      })
    ]
  );

  inherit (stdenvNoCC.hostPlatform) isLinux;
in
stdenvNoCC.mkDerivation {
  pname = "idemacs";
  version = "0-unstable-2025-11-16";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "IDEmacs";
    repo = "IDEmacs";
    rev = "e1db4094f40710f4f5ea50bc0785b9445ebe25c6";
    hash = "sha256-9V/DBOXesYukpGLmvWTvjGeZdO/sU7GGtkg23DaIdfw=";
  };

  nativeBuildInputs = [ makeWrapper ] ++ lib.optional isLinux copyDesktopItems;

  desktopItems = lib.optional isLinux (makeDesktopItem {
    name = "idemacs";
    desktopName = "IDEmacs";
    exec = "idemacs %F";
    icon = "idemacs";
    categories = [
      "Development"
      "TextEditor"
    ];
  });

  patches = [ ./nix-profile.patch ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/share/idemacs"
    cp -r vscode/init.el vscode/lisp "$out/share/idemacs/"
    install -Dm644 README.org "$out/share/doc/idemacs/README.org"
  ''
  + lib.optionalString isLinux ''
    install -Dm644 ${emacs}/share/icons/hicolor/scalable/apps/emacs.svg \
      "$out/share/icons/hicolor/scalable/apps/idemacs.svg"
  ''
  + ''

    substitute ${./launcher.sh} "$out/bin/idemacs" \
      --subst-var out \
      --subst-var-by shell ${stdenvNoCC.shell} \
      --subst-var-by emacs ${emacs}/bin/emacs
    chmod +x "$out/bin/idemacs"
    wrapProgram "$out/bin/idemacs" --prefix PATH : ${
      lib.makeBinPath [
        git
        gnugrep
      ]
    }

    runHook postInstall
  '';

  passthru.updateScript = writeShellApplication {
    name = "update-idemacs";
    runtimeInputs = [
      curl
      jq
      nix
      python3
    ];
    text = ''
      set -euo pipefail

      pkg_file="by-name/id/idemacs/package.nix"
      api_url="https://codeberg.org/api/v1/repos/IDEmacs/IDEmacs/commits?sha=production&limit=1"

      commit_json="$(curl -fsSL "$api_url")"
      latest_rev="$(jq -r '.[0].sha' <<<"$commit_json")"
      commit_ts="$(jq -r '.[0].commit.committer.date' <<<"$commit_json")"
      commit_date="$(python3 -c '
      from datetime import datetime, timezone
      import sys
      print(datetime.fromisoformat(sys.argv[1]).astimezone(timezone.utc).strftime("%Y-%m-%d"))
      ' "$commit_ts")"
      latest_version="0-unstable-$commit_date"

      current_rev="$(python3 -c '
      import re, sys
      text = open(sys.argv[1]).read()
      m = re.search(r"fetchFromGitea\s*\{[^}]*\brev\s*=\s*\"([^\"]+)\"", text, re.S)
      print(m.group(1) if m else "")
      ' "$pkg_file")"

      if [[ "$latest_rev" == "$current_rev" ]]; then
        echo "idemacs is already up to date ($latest_version / $latest_rev)"
        exit 0
      fi

      latest_hash="$(nix store prefetch-file --unpack --json \
        "https://codeberg.org/IDEmacs/IDEmacs/archive/$latest_rev.tar.gz" | jq -r '.hash')"

      python3 - "$pkg_file" "$latest_version" "$latest_rev" "$latest_hash" <<'PY'
      import re, sys
      path, version, rev, hash_ = sys.argv[1:5]
      text = open(path).read()
      text, n1 = re.subn(
          r'(pname = "idemacs";\n\s*version = )"[^"]+";',
          rf'\g<1>"{version}";',
          text,
          count=1,
      )
      text, n2 = re.subn(
          r'(fetchFromGitea \{[^}]*rev = )"[^"]+";(\n\s*hash = )"[^"]+";',
          rf'\g<1>"{rev}";\g<2>"{hash_}";',
          text,
          count=1,
          flags=re.S,
      )
      assert n1 == 1 and n2 == 1, f"Expected 1 replacement each, got {n1}, {n2}"
      open(path, "w").write(text)
      PY

      echo "Updated idemacs to $latest_version ($latest_rev)"
    '';
  };

  meta = {
    description = "Emacs configuration with a VS Code-inspired workflow";
    homepage = "https://codeberg.org/IDEmacs/IDEmacs";
    license = lib.licenses.unlicense;
    mainProgram = "idemacs";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
