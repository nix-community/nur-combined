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

  programs.zoom-us.enable = true;

  environment.systemPackages = with pkgs; [
    # dsnote
    mongodb-compass
    postman
    # remmina
  ];

}
