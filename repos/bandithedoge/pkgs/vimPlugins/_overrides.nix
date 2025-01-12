{pkgs, ...}: final: prev: {
  sqlite-lua = prev.sqlite-lua.overrideAttrs (_: {
    postPatch = let
      libsqlite = "${pkgs.sqlite.out}/lib/libsqlite3${pkgs.stdenv.hostPlatform.extensions.sharedLibrary}";
    in ''
      substituteInPlace lua/sqlite/defs.lua \
        --replace "path = vim.g.sqlite_clib_path" "path = vim.g.sqlite_clib_path or ${pkgs.lib.escapeShellArg libsqlite}"
    '';
  });

  telescope-frecency-nvim = prev.telescope-frecency-nvim.overrideAttrs (_: {
    buildInputs = [final.sqlite-lua];
  });

  nvim-treesitter = prev.nvim-treesitter.overrideAttrs (old: {
    passthru.withPlugins = grammarFn:
      final.nvim-treesitter.overrideAttrs (_: {
        postPatch = let
          grammars = pkgs.tree-sitter.withPlugins grammarFn;
        in ''
          rm -r parser
          ln -s ${grammars} parser
        '';
      });
  });

  lua-dev-nvim = pkgs.lib.warn "lua-dev.nvim has been renamed to neodev.nvim" final.neodev-nvim;

  null-ls-nvim = pkgs.lib.warn "null-ls.nvim has been discontinued, consider switching to none-ls.nvim" prev.null-ls-nvim;

  playground = prev.playground.overrideAttrs (_: {
    nativeCheckInputs = [final.nvim-treesitter];
  });

  faust-nvim = prev.faust-nvim.overrideAttrs (_: {
    nativeCheckInputs = [final.fzf-lua];
  });

  fzf-lua = prev.fzf-lua.overrideAttrs (_: {
    doCheck = false;
  });

  hover-nvim = prev.hover-nvim.overrideAttrs (_: {
    doCheck = false;
  });

  telescope-zf-native-nvim = prev.telescope-zf-native-nvim.overrideAttrs (_: {
    dependencies = [final.telescope-nvim];
  });

  telescope-nvim = prev.telescope-nvim.overrideAttrs (_: {
    dependencies = [final.plenary-nvim];
  });

  plenary-nvim = prev.plenary-nvim.overrideAttrs (_: {
    nativeCheckInputs = [pkgs.vimPlugins.rocks-nvim];
  });
}
