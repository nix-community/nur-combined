_: final: prev: {
  opencode-nvim = prev.opencode-nvim.overrideAttrs (_: {
    passthru._ignoreDupe = true;
  });
}
