{pkgs ? import <nixpkgs> {}, ...}: {
  chalet = pkgs.callPackage ./pkgs/chalet {};
  dmsShellPlugins = pkgs.callPackage ./pkgs/dms-shell-plugins {};
  font-etuvetica = pkgs.callPackage ./pkgs/font-etuvetica {};
  font-talyznewroman = pkgs.callPackage ./pkgs/font-talyznewroman {};
  g90updatefw = pkgs.callPackage ./pkgs/g90updatefw {};
  github-markdown-toc = pkgs.callPackage ./pkgs/github-markdown-toc {};
  goprocmgr = pkgs.callPackage ./pkgs/goprocmgr {};
  llr = pkgs.callPackage ./pkgs/llr {};
  mkvcleaner = pkgs.callPackage ./pkgs/mkvcleaner {};
}
