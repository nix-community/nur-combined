{
  # nix-darwin modules, importable individually from system configurations,
  # e.g. `inputs.nixcfg.modules.darwin.bash`. Modules declare their own
  # dependent-module `imports`; configurations import only what they use.
  #
  # my-module = ./my-module;
  android = ./android.nix;
  bash = ./bash.nix;
  homebrew = ./homebrew.nix;
  keyboard = ./keyboard.nix;
  odysseus = ./odysseus.nix;
  ollama = ./ollama.nix;
  podman = ./podman.nix;
  system = ./system.nix;
  terminfo = ./terminfo.nix;
  touchid = ./touchid.nix;
}
