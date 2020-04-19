{ stdenv, fish }:
{ name, src, ... }@attrs:

stdenv.mkDerivation ({
  inherit src;
  name = "fish-plugin-${name}";

  buildInputs = [ fish ];

  passAsFile = [ "installPluginScript" ];

  installPluginScript = ''
    # This is pretty much stolen from github.com/fisherman/fin
    for i in "$plugin/"{,functions,conf.d,completions}/*.fish
      set -l target (string split / "$i")[-1]
      switch "$i"
        case $plugin/conf.d\*
          set target "$fish_path/vendor_conf.d/$target"
        case $plugin/completions\*
          set target "$fish_path/vendor_completions.d/$target"
        case $plugin/{,functions}\*
          set target "$fish_path/vendor_functions.d/$target"
      end
      command mkdir -p (dirname "$target")
      command cp "$i" "$target"
    end
  '';

  buildCommand = ''
    export HOME=$TMPDIR
    export fish_path=$out/share/fish
    export plugin=$src

    # This avoids a warning from fish
    mkdir -p ~/.local/bin
    fish $installPluginScriptPath
  '';
} // attrs)
