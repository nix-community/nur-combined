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
}
