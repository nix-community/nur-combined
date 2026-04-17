{
  lib,
  newScope,
}:

lib.makeScope newScope (self: {

  buildObsidianPlugin = self.callPackage ./mk-obsidian-plugin.nix { };

  buildObsidianTheme = self.buildObsidianPlugin.override {
    namePrefix = "obsidian-theme-";
    outFiles = [ "manifest.json" "theme.css" ];
  };

  obsidianManifestCheckHook = self.callPackage ./obsidian-manifest-check-hook { };

  codeblock-customizer = self.callPackage ./community-plugins/codeblock-customizer { };

  minimal = self.callPackage ./themes/minimal { };

  minimal-settings = self.callPackage ./community-plugins/minimal-settings { };

  style-settings = self.callPackage ./community-plugins/style-settings { };

  vimrc-support = self.callPackage ./community-plugins/vimrc-support { };

})
