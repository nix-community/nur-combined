{
  pkgs,
  flakeRoot,
  nixosModules,
  ...
}:

let
  secrets = flakeRoot + /secrets;
in

{
  imports = [
    secrets
  ]
  ++ (with nixosModules; [
    hardened
    programs.lanzaboote
    services.automount
  ]);

  # Temporarily expose and persist early-boot failures instead of rebooting.
  boot.kernelParams = [ "dis_ucode_ldr" ];

  nix-mineral = {
    settings = {
      debug = {
        efipstore = true;
        panic-reboot = false;
        quiet-boot = false;
        restrict-printk = false;
      };
      kernel.oops-panic = false;
    };
    extras.kernel.warn-panic = false;
  };

  programs.zoom-us.enable = true;

  environment.systemPackages = with pkgs; [
    # dsnote
    mongodb-compass
    postman
    # remmina
  ];

}
