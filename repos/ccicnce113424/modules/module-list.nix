{
  nixosModules = {
    # keep-sorted start block=yes newline_separated=yes
    daed = {
      disabledModules = [ "services/networking/daed.nix" ];
      imports = [ ./daed.nix ];
    };

    daed-next = ./daed-next.nix;

    honk-core = ./honk-core.nix;
    # keep-sorted end
  };
}
