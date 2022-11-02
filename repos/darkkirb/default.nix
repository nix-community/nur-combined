# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}}: {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib {inherit pkgs;}; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  akkoma = pkgs.callPackage ./akkoma {};
  pleroma-fe = pkgs.callPackage ./akkoma/pleroma-fe {};
  admin-fe = pkgs.callPackage ./akkoma/admin-fe {};
  emoji-volpeon-blobfox = pkgs.callPackage ./art/emoji/volpeon/blobfox.nix {};
  emoji-volpeon-blobfox-flip = pkgs.callPackage ./art/emoji/volpeon/blobfox_flip.nix {};
  emoji-volpeon-bunhd = pkgs.callPackage ./art/emoji/volpeon/bunhd.nix {};
  emoji-volpeon-bunhd-flip = pkgs.callPackage ./art/emoji/volpeon/bunhd_flip.nix {};
  emoji-volpeon-drgn = pkgs.callPackage ./art/emoji/volpeon/drgn.nix {};
  emoji-volpeon-fox = pkgs.callPackage ./art/emoji/volpeon/fox.nix {};
  emoji-volpeon-raccoon = pkgs.callPackage ./art/emoji/volpeon/raccoon.nix {};
  emoji-volpeon-vlpn = pkgs.callPackage ./art/emoji/volpeon/vlpn.nix {};
  lotte-art = pkgs.callPackage ./art/lotte {};
  drone-runner-docker = pkgs.callPackage ./ci/drone-runner-docker {};
  alco-sans = pkgs.callPackage ./fonts/kreative/alco-sans.nix {};
  constructium = pkgs.callPackage ./fonts/kreative/constructium.nix {};
  fairfax = pkgs.callPackage ./fonts/kreative/fairfax.nix {};
  fairfax-hd = pkgs.callPackage ./fonts/kreative/fairfax-hd.nix {};
  kreative-square = pkgs.callPackage ./fonts/kreative/kreative-square.nix {};
  nasin-nanpa = pkgs.callPackage ./fonts/nasin-nanpa {};
  matrix-media-repo = pkgs.callPackage ./matrix/matrix-media-repo {};
  mautrix-discord = pkgs.callPackage ./matrix/mautrix-discord {};
  mautrix-whatsapp = pkgs.callPackage ./matrix/mautrix-whatsapp {};
  mautrix-signal = pkgs.callPackage ./matrix/mautrix-signal {};
  mautrix-telegram = pkgs.callPackage ./matrix/mautrix-telegram {};
  python-mautrix = pkgs.python3Packages.callPackage ./python/mautrix.nix {};
  python-tulir-telethon = pkgs.python3Packages.callPackage ./python/tulir-telethon.nix {};
  papermc = pkgs.callPackage ./minecraft/papermc {};
  python-plover-stroke = pkgs.python3Packages.callPackage ./plover/plover-stroke.nix {};
  python-rtf-tokenize = pkgs.python3Packages.callPackage ./python/rtf-tokenize.nix {};
  plover = pkgs.python3Packages.callPackage ./plover/plover {};
  plover-plugins-manager = pkgs.python3Packages.callPackage ./plover/plover-plugins-manager.nix {};
  python-simplefuzzyset = pkgs.python3Packages.callPackage ./python/simplefuzzyset.nix {};
  plover-plugin-emoji = pkgs.python3Packages.callPackage ./plover/plover-emoji.nix {};
  plover-plugin-tapey-tape = pkgs.python3Packages.callPackage ./plover/plover-tapey-tape.nix {};
  plover-plugin-yaml-dictionary = pkgs.python3Packages.callPackage ./plover/plover-yaml-dictionary.nix {};
  plover-plugin-machine-hid = pkgs.python3Packages.callPackage ./plover/plover-machine-hid.nix {};
  plover-plugin-rkb1-hid = pkgs.python3Packages.callPackage ./plover/plover-rkb1-hid.nix {};
  plover-dict-didoesdigital = pkgs.callPackage ./plover/didoesdigital-dictionary.nix {};
  miifox-net = pkgs.python3Packages.callPackage ./web/miifox-net.nix {};
  old-homepage = pkgs.callPackage ./web/old-homepage.nix {};
  clean-s3-cache = pkgs.python3Packages.callPackage ./scripts/clean-s3-cache.nix {};
  python-instagram = pkgs.python3Packages.callPackage ./python/instagram.nix {};
  moa = pkgs.python3Packages.callPackage ./moa {};
}
