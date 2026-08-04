{
  lib,
  newScope,
}:

lib.makeScope newScope (self: {

  buildObsidianPlugin = self.callPackage ./mk-obsidian-plugin.nix { };

  buildObsidianTheme = self.buildObsidianPlugin.override {
    namePrefix = "obsidian-theme-";
    idAttr = "name";
    outFiles = [ "manifest.json" "theme.css" ];
  };

  obsidianManifestCheckHook = self.callPackage ./obsidian-manifest-check-hook { };

  calendar = self.callPackage ./plugins/calendar { };

  codeblock-customizer = self.callPackage ./plugins/codeblock-customizer { };

  minimal = self.callPackage ./themes/minimal { };

  minimal-settings = self.callPackage ./plugins/minimal-settings { };

  style-settings = self.callPackage ./plugins/style-settings { };

  vimrc-support = self.callPackage ./plugins/vimrc-support { };

})
