{ self, super, lib }: with lib; let
  packages = import ./default.nix;
  flatPackages = {
    inherit (packages) personal public vimPlugins kakPlugins gitAndTools rxvt-unicode-plugins weechatScripts shells;
  };
  callPackage = name: p: self.callPackage p { };
  flat = builtins.mapAttrs (_: flat: builtins.mapAttrs callPackage flat) flatPackages;
  overrides = packages.overrides.instantiate { inherit self super; };
  merge = mapListToAttrs (key: nameValuePair key ((super.${key} or {}) // flat.${key}))
    [ "gitAndTools" "kakPlugins" "vimPlugins" "weechatScripts" "rxvt-unicode-plugins" "shells" ];
in flat.public // merge // overrides // {
  arc'private = flat.personal;
}
