self: super:

let
  makeWrapped = { name, cmd ? name, pkg ? super.lib.getAttr name super, arg, extraWrapArgs ? ""}:
    super.stdenv.mkDerivation {
      name = name + "-wrapped-" + (pkg.version or "");
      buildInputs = [ super.makeWrapper ];
      buildCommand = ''
        mkdir -p $out/bin
        for BINARY in $(ls ${pkg}/bin); do
          ln -s ${pkg}/bin/$BINARY $out/bin/$BINARY
        done
        wrapProgram $out/bin/${cmd} --add-flags "${arg}" ${extraWrapArgs}
      '';
    };
in

{
  dotfiles-bin = super.callPackage ../custom/dotfiles-bin.nix { };

  emacs-wrapped = makeWrapped {
    name = "emacs";
    arg = "-Q -l \\$(dotfiles)/init.el";
  };
  rofi-wrapped = makeWrapped {
    name = "rofi";
    pkg = super.rofi;
    arg = "-config \\$(dotfiles)/rofi-config";
  };
  cli-visualizer-wrapped = makeWrapped {
    name = "cli-visualizer";
    cmd = "vis";
    arg = "-c \\$(dotfiles)/vis-config";
  };
  dunst-wrapped = makeWrapped {
    name = "dunst";
    arg = "-config \\$(dotfiles)/dunst-config";
  };
  alacritty-wrapped = makeWrapped {
    pkg = super.pkgsUnstable.alacritty;
    name = "alacritty";
    arg = "--config-file=\\$(dotfiles)/alacritty-config.yml";
  };
  kitty-wrapped = makeWrapped {
    name = "kitty";
    arg = "--config=\\$(dotfiles)/kitty-config";
  };
  cava-wrapped = makeWrapped {
    name = "cava";
    arg = "-p ~/Projects/nix/dotfiles/cava-config"; # FIX THIS
  };
  i3blocks-wrapped = makeWrapped {
    name = "i3blocks";
    arg = "-c \\$(dotfiles)/i3blocks-config";
    extraWrapArgs = "--set SCRIPT_DIR ${super.i3blocks}/libexec/i3blocks";
  };
}
