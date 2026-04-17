{
  lib,
  newScope
}:

lib.makeScope newScope (self: {

  buildObsidianPlugin = self.callPackage ./mk-obsidian-plugin.nix { };

  codeblock-customizer = self.callPackage ./codeblock-customizer { };

  style-settings = self.callPackage ./style-settings { };

})
