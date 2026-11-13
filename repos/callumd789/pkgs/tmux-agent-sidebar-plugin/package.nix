{
  mkTmuxPlugin,
  tmux-agent-sidebar,
}:

mkTmuxPlugin {
  pluginName = "tmux-agent-sidebar";
  inherit (tmux-agent-sidebar) version src;

  # The default is derived from pluginName with dashes turned into
  # underscores, and that file doesn't exist.
  rtpFilePath = "tmux-agent-sidebar.tmux";

  # tmux-agent-sidebar.tmux prefers bin/tmux-agent-sidebar, and runs
  # install-wizard.sh to download a release binary if it finds no binary or one
  # whose version differs from Cargo.toml. Providing one built from the same src
  # keeps the wizard from ever running.
  postInstall = ''
    mkdir -p $target/bin
    ln -s ${tmux-agent-sidebar}/bin/tmux-agent-sidebar $target/bin/
  '';

  # No passthru.updateScript: version and src come from tmux-agent-sidebar, so
  # updating that updates this too. mkTmuxPlugin in nixpkgs-unstable sets its
  # own passthru, replacing anything given here.

  meta = {
    inherit (tmux-agent-sidebar.meta)
      homepage
      changelog
      license
      platforms
      ;
    description = "Tmux plugin for tmux-agent-sidebar, a sidebar that monitors AI coding agents";
  };
}
