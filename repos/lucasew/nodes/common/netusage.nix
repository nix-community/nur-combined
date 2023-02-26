{ pkgs, ... }: {
  systemd.services.netusage = {
    description = "Writes network usage to /dev/shm/netusage";
    wantedBy = [ "multi-user.target" ];
    script = ''
      ${pkgs.python3.interpreter} ${../../bin/netusage}
    '';
  };
}
