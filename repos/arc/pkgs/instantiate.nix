{ self, super, lib }: with lib; let
  packages = import ./default.nix;
  flatPackages = {
    inherit (packages) personal public vimPlugins kakPlugins gitAndTools rxvt-unicode-plugins weechatScripts shells;
  };
  callPackage = name: p: self.callPackage p { };
  flat = builtins.mapAttrs (_: flat: builtins.mapAttrs callPackage flat) flatPackages;
  overrides = packages.overrides.instantiate { inherit self super; };
  groups = [ "kakPlugins" "vimPlugins" "weechatScripts" "rxvt-unicode-plugins" "shells" ] ++
    optional (! versionAtLeast version "21.03pre") "gitAndTools";
  merge = mapListToAttrs (key: nameValuePair key ((super.${key} or {}) // flat.${key}))
    groups;
in flat.public // merge // overrides // {
  arc'private = flat.personal;
}
