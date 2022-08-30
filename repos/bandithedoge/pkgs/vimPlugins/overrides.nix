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
}
