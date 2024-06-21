{ pkgs ? import <nixpkgs> { }
, arc ? (import ../canon.nix { inherit pkgs; })
, self ? arc.pkgs
, super ? arc.super.pkgs
, lib ? arc.super.lib
}: with lib; let
  overrides' = import ./overrides.nix { inherit arc; };
  overrides = builtins.mapAttrs (_: o: (overlayOverride (o // {
    inherit self super;
  })).${o.attr}) overrides';
  packages' = {
    personal = import ./personal;
    public = import ./public;
    customized = import ./customized;
  };
  callPackages = builtins.mapAttrs (_: attrs: arc.callPackageAttrs attrs { });
  packages = callPackages packages';
  groups' = {
    vimPlugins = import ./vimPlugins.nix;
    kakPlugins = import ./kakPlugins.nix;
    mpvScripts = import ./mpvScripts.nix;
    polybarScripts = import ./polybarScripts.nix;
    kernelPatches = import ./kernelPatches.nix;
    rxvt-unicode-plugins = import ./urxvt;
    obs-studio-plugins = import ./obs;
    zsh-plugins = import ./zsh;
    gitAndTools = import ./git;
    weechatScripts = import ./public/weechat/scripts.nix;
  };
  groups = callPackages groups';
  groupsWithoutGit =
    # changed in nixpkgs to an alias on 2021-01-14
    if versionAtLeast version "21.03pre"
    then builtins.removeAttrs groups [ "gitAndTools" ]
    else groups;
  customization = {
    pythonOverrides = import ./python;
  };
  select = {
    inherit overrides;
    inherit groups;
    toplevel = packages.personal // packages.public // packages.customized;
    exported = packages.public // packages.customized;
    all = attrsets.mergeAttrsList (attrValues packages ++ attrValues groups);
  };
  extendWith = super: select.exported //
    builtins.mapAttrs (makeOrExtend super) groupsWithoutGit //
    builtins.mapAttrs (attr: group: super.${attr} or { } // group) customization;
  extendWithOverrides = self: super: {
    callPackageOverrides = super.callPackageOverrides or { } // mapAttrs' (k: o:
      nameValuePair o.withAttr { ${k} = self.${o.superAttr} or super.${k} or (o.fallback { }); }
    ) (filterAttrs (_: o: o.withAttr or null != null) overrides');
  } // attrsets.mergeAttrsList (mapAttrsToList (_: o: overlayOverride (o // {
      inherit self super;
    })) overrides');
in lib.recurseIntoAttrs or lib.id select.toplevel // {
  groups =
    builtins.mapAttrs (_: lib.dontRecurseIntoAttrs or lib.id) (packages // select) //
    builtins.mapAttrs (_: lib.recurseIntoAttrs or lib.id) groups;
  customization =
    builtins.mapAttrs (_: lib.dontRecurseIntoAttrs or lib.id) customization;
  personal = lib.dontRecurseIntoAttrs or lib.id packages.personal;
  inherit extendWith;
  inherit extendWithOverrides;
}
