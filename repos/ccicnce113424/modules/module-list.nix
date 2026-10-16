{
  nixosModules =
    let
      modules = {
        # keep-sorted start block=yes newline_separated=yes
        daed = ./daed.nix;

        daed-next = ./daed-next.nix;

        honk-core = ./honk-core.nix;

        pipewire-bluez5-lhdc = ./pipewire-bluez5-lhdc.nix;
        # keep-sorted end
      };
    in
    modules
    // {
      default.imports = builtins.attrValues modules;
    };
}
