{ pkgs, ... }:

{
  users = {
    users = {
      # vai incrementando
      /*
      w_you = {
        isNormalUser = true;
        extraGroups = [
          "work"
          "ssh"
        ];
        uid = 2003;
      };
      */
    };
    groups.work = {
      gid = 1999;
    };
  };
  environment.systemPackages = with pkgs; [
    brave
  ];
  virtualisation.podman.enable = true;
}
