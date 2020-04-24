self: super: {
  vcsh = super.vcsh.overrideAttrs(old: {
    patchPhase = old.patchPhase or "" + ''
      sed -i -e 's@-r "$XDG_CONFIG_HOME/vcsh/config.d/$VCSH_REPO_NAME"@-f "$XDG_CONFIG_HOME/vcsh/config.d/$VCSH_REPO_NAME"@' vcsh
      '';
  });
}
