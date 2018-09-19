{ pkgs, ... }:

{
  environment.variables = {
    MANPAGER = "${pkgs.writeShellScriptBin "vim-manpager" "
      sed -e 's/\x1B\[[[:digit:]]\+m//g' | col -b | \\
          vim \\
            -c 'let no_plugin_maps = 1' \\
            -c 'set nolist nomod ft=man ts=8' \\
            -c 'let g:showmarks_enable=0' \\
            -c 'runtime! macros/less.vim' -
    "}/bin/vim-manpager";
  };
}
