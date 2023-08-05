{ lib
, stdenv

  # nixpkgs functions
, buildGoModule
, buildVimPluginFrom2Nix
, fetchFromGitHub
, fetchFromSourcehut
, fetchpatch
, fetchurl
, substituteAll

  # must be lua51Packages
, luaPackages

  #misc dependencies
, Cocoa
, llvmPackages
, nodePackages
, pandoc

# LanguageClient-neovim dependencies
, CoreFoundation
, CoreServices
}:

self: super: {
  knap = super.knap.overrideAttrs {
    postPatch = ''
      substituteInPlace lua/knap.lua \
        --replace luaposix ${luaPackages.luaposix}/lib/${luaPackages.luaposix.version}/posix
      substituteInPlace pandoc
        --replace pandoc ${pandoc}/bin/pandoc
    '';
  };

  texmagic-nvim = super.texmagic-nvim.overrideAttrs {
    dependencies = with self; [ nvim-lspconfig ];
  };
}
