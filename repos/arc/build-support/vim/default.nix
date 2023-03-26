{ self, super, lib, ... }: with lib; mapAttrs (_: flip self.callPackage { }) {
  buildVimSpell = ./mkspell.nix;
}
