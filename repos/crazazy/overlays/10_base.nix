self: super: let
   pkgs = super.callNixPackage ({ pkgs }: pkgs) {};
   pythonSet = pkgs.python3.withPackages (p: with p; [
      numpy
      flask
      tkinter
      ipython
      virtualenvwrapper
   ]);
in
   {
      lib = pkgs.lib // {
         inherit (import ../lib/utils.nix) zipWith quickElem any all sum product;
      } // super.lib;
      python = self.writeShellScriptBin "python" ''
         ${pythonSet.interpreter} $@
      '';
      inherit (pkgs)
         atom
         bashInteractive
         buildEnv
         deno
         dillo
         emacs
         fetchurl
         fetchzip
         git
         go
         graalvm11-ce
         hello
         neovim
         nix
         openbox
         runCommand
         stdenv
         writeShellScript
         writeShellScriptBin
         xorg
         ;
   }
