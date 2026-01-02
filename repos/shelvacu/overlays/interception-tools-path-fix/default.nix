final: prev: {
  # from https://github.com/NixOS/nixpkgs/pull/314654
  interception-tools = prev.interception-tools.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [ ./interception-tools-udevmon-path-fix.patch ];
  });
}
