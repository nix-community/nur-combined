# based on:
#https://github.com/NixOS/nixpkgs/blob/8ce73368d1efd4d657e9064d29b144a52046b4e8/pkgs/by-name/tm/tmux/package.nix
{
  lib,
  stdenv,
  fetchFromGitea,
  autoreconfHook,
  bison,
  lowdown,
  libevent,
  ncurses,
  pkg-config,
  runCommand,
  withSystemd ? lib.meta.availableOn stdenv.hostPlatform systemdLibs,
  systemdLibs,
  # broken on i686-linux https://github.com/tmux/tmux/issues/4597
  withUtf8proc ? !(stdenv.hostPlatform.is32bit),
  utf8proc, # gets Unicode updates faster than glibc
  withUtempter ? stdenv.hostPlatform.isLinux,
  libutempter,
  withSixel ? true,
  versionCheckHook,
  #common-updater-scripts,
  writeShellScript,
  curl,
  jq,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "opentmux";
  version = "0.1";

  outputs = [
    "out"
    "man"
  ];

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "opentmux";
    repo = "opentmux";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zGa/MTRzs2lxDKLvzdLWf0hWcDxikIdE3IBrz9TwDy0=";
  };

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
    bison
    lowdown
  ];

  buildInputs = [
    ncurses
    libevent
  ]
  ++ lib.optionals withSystemd [ systemdLibs ]
  ++ lib.optionals withUtf8proc [ utf8proc ]
  ++ lib.optionals withUtempter [ libutempter ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ]
  ++ lib.optionals withSystemd [ "--enable-systemd" ]
  ++ lib.optionals withSixel [ "--enable-sixel" ]
  ++ lib.optionals withUtempter [ "--enable-utempter" ]
  ++ lib.optionals withUtf8proc [ "--enable-utf8proc" ];

  enableParallelBuilding = true;

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir $out/nix-support
    echo "${finalAttrs.passthru.terminfo}" >> $out/nix-support/propagated-user-env-packages
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "-V";
  doInstallCheck = true;

  passthru = {
    terminfo = runCommand "tmux-terminfo" { nativeBuildInputs = [ ncurses ]; } (
      if stdenv.hostPlatform.isDarwin then
        ''
          mkdir -p $out/share/terminfo/74
          cp -v ${ncurses}/share/terminfo/74/tmux $out/share/terminfo/74
          # macOS ships an old version (5.7) of ncurses which does not include tmux-256color so we need to provide it from our ncurses.
          # However, due to a bug in ncurses 5.7, we need to first patch the terminfo before we can use it with macOS.
          # https://gpanders.com/blog/the-definitive-guide-to-using-tmux-256color-on-macos/
          tic -o $out/share/terminfo -x <(TERMINFO_DIRS=${ncurses}/share/terminfo infocmp -x tmux-256color | sed 's|pairs#0x10000|pairs#32767|')
        ''
      else
        ''
          mkdir -p $out/share/terminfo/t
          ln -sv ${ncurses}/share/terminfo/t/{tmux,tmux-256color,tmux-direct} $out/share/terminfo/t
        ''
    );
    #updateScript = writeShellScript "update-tmux" ''
    #  latest=$(${lib.getExe curl} --silent ''${GITHUB_TOKEN:+--header "Authorization: Bearer $GITHUB_TOKEN"} https://api.github.com/repos/tmux/tmux/releases/latest | ${lib.getExe jq} -r .tag_name)
    #  ${lib.getExe' common-updater-scripts "update-source-version"} tmux "$latest"
    #'';
  };

  meta = {
    homepage = "https://codeberg.org/opentmux/opentmux";
    downloadPage = "https://codeberg.org/opentmux/opentmux";
    description = "Terminal multiplexer (fork of tmux before AI was introduced)";
    longDescription = ''
      opentmux is a fork of tmux-3.6a before any AI was introduced into the project.

      tmux is intended to be a modern, BSD-licensed alternative to programs such as GNU screen. Major features include:
        * A powerful, consistent, well-documented and easily scriptable command interface.
        * A window may be split horizontally and vertically into panes.
        * Panes can be freely moved and resized, or arranged into preset layouts.
        * Support for UTF-8 and 256-colour terminals.
        * Copy and paste with multiple buffers.
        * Interactive menus to select windows, sessions or clients.
        * Change the current window by searching for text in the target.
        * Terminal locking, manually or after a timeout.
        * A clean, easily extended, BSD-licensed codebase, under active development.
    '';
    changelog = "https://codeberg.org/opentmux/opentmux/raw/${finalAttrs.version}/CHANGES";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
    mainProgram = "tmux";
  };
})
