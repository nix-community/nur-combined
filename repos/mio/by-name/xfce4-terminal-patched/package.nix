{
  xfce4-terminal,
  fetchpatch,
}:

xfce4-terminal.overrideAttrs (oldAttrs: {
  pname = "xfce4-terminal-patched";

  patches = (oldAttrs.patches or [ ]) ++ [
    (fetchpatch {
      name = "Add Set Title to the tab context menu";
      url = "https://github.com/realrossmanngroup/xfce4-terminal/commit/621cbdbb70f3f5b37efb98bea08e7c6bdd6c38ce.patch";
      hash = "sha256-6BD8f5e0AX8bmo988norEtc1bWQ57Z6tKVeMVEu/U1Y=";
      derivationArgs.allowSubstitutes = false;
    })
  ];
})
