/*
This is a nix expression to build Emacs and some Emacs packages I like
from source on any distribution where Nix is installed. This will install
all the dependencies from the nixpkgs repository and build the binary files
without interfering with the host distribution.

To build the project, type the following from the current directory:

$ nix-build emacs.nix

To run the newly compiled executable:

$ ./result/bin/emacs
*/
{ pkgs ? import <nixpkgs> {} }:

let
  emacsPlus = let
    patchMulticolorFonts = super.fetchurl {
        url = "https://gist.githubusercontent.com/aatxe/260261daf70865fbf1749095de9172c5/raw/214b50c62450be1cbee9f11cecba846dd66c7d06/patch-multicolor-font.diff";
        sha256 = "5af2587e986db70999d1a791fca58df027ccbabd75f45e4a2af1602c75511a8c";
    };
    # needs 10.11 sdk
    patchBorderless = super.fetchurl {
        url = "https://raw.githubusercontent.com/peel/GNU-Emacs-OS-X-no-title-bar/master/GNU-Emacs-OS-X-no-title-bar.patch";
        sha256 = "0cjmc0nzx0smc4cxmxcjy75xf83smah3fkjfyql1y14gd59c1npw";
    };
    patchPixelScrolling = super.fetchurl {
        url = "https://gist.githubusercontent.com/aatxe/ecd14e3e4636524915eab2c976650576/raw/c20527ab724ddbeb14db8cc01324410a5a722b18/emacs-pixel-scrolling.patch";
        sha256 = "34654d889e8a02aedc0c39a0f710b3cc17d5d4201eb9cb357ecca6ed1ec24684";
    };
    patch24bitColor = super.fetchurl {
        url = "https://gist.githubusercontent.com/akorobov/2c9f5796c661304b4d8aa64c89d2cd00/raw/2f7d3ae544440b7e2d3a13dd126b491bccee9dbf/emacs-25.2-term-24bit-colors.diff";
        sha256 = "ffe72c57117a6dca10b675cbe3701308683d24b62611048d2e7f80f419820cd0";
    };
  in {
      with24bitColor ? false
    , withPixelScrolling ? false
    , withBorderless ? false
    , withMulticolorFonts ? false
  }: (super.emacs
      .override{srcRepo=true;inherit (super) autoconf automake texinfo;})
      .overrideAttrs (oldAttrs: rec {
        patches = oldAttrs.patches
          ++ super.lib.optional with24bitColor patch24bitColor
          ++ super.lib.optional withPixelScrolling patchPixelScrolling
          ++ super.lib.optional withBorderless patchBorderless
          ++ super.lib.optional withMulticolorFonts patchMulticolorFonts;
      });
  emacs = (if super.stdenv.isDarwin then
    (emacsPlus {
        with24bitColor = true;
        withPixelScrolling = true;
        withBorderless = true;
        withMulticolorFonts = true;
    }) else super.emacs);
  emacsWithPackages = (pkgs.emacsPackages emacs).emacsWithPackages;
in
  emacsWithPackages (epkgs: (with epkgs.melpaStablePackages; [
    magit          # ; Integrate git <C-x g>
    zerodark-theme # ; Nicolas' theme
  ]) ++ (with epkgs.melpaPackages; [
    undo-tree      # ; <C-x u> to show the undo tree
    zoom-frm       # ; increase/decrease font size for all buffers %lt;C-x C-+>
  ]) ++ (with epkgs.elpaPackages; [
    auctex         # ; LaTeX mode
    beacon         # ; highlight my cursor when scrolling
    nameless       # ; hide current package name everywhere in elisp code
  ]) ++ [
    pkgs.notmuch   # From main packages set
  ])
