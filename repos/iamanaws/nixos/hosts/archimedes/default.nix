{
  inputs,
  pkgs,
  flakeRoot,
  nixosModules,
  ...
}:

let
  secrets = flakeRoot + /secrets;
  kernelPackages = inputs.nixpkgs-kernel.legacyPackages.x86_64-linux;
  kernel = kernelPackages.linuxPackages.kernel.overrideAttrs (old: {
    passthru = (old.passthru or { }) // {
      buildDTBs = false;
      target = "bzImage";
    };
  });
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

  # Linux 6.18.44 hard-resets this machine during early boot.
  boot.kernelPackages = kernelPackages.linuxPackagesFor kernel;

  programs.zoom-us.enable = true;

  environment.systemPackages = with pkgs; [
    # dsnote
    mongodb-compass
    postman
    # remmina
  ];

}
