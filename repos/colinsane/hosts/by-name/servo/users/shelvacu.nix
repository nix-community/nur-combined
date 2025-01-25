{ lib, pkgs, ... }:
{
  users.users.shelvacu = {
    isNormalUser = true;
    home = "/home/shelvacu";
    subUidRanges = [
      { startUid=300000; count=1; }
    ];
    group = "users";
    initialPassword = lib.mkDefault "";
    shell = pkgs.bash;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKoy1TrmfhBGWtVedgOM1FB1oD2UdodN3LkBnnLx6Tug compute-deck"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAxAFFxQMXAgi+0cmGaNE/eAkVfEl91wafUqFIuAkI5I compute-deck-root"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQ2c0GzlVMjV06CS7bWbCaAbzG2+7g5FCg/vClJPe0C fw"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGHLPOxRd68+DJ/bYmqn0wsgwwIcMSMyuU1Ya16hCb/m fw-root"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOre0FnYDm3arsFj9c/l5H2Q8mdmv7kmvq683pL4heru legtop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINznGot+L8kYoVQqdLV/R17XCd1ILMoDCILOg+I3s5wC pixel9pro-nod"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDcRDekd8ZOYfQS5X95/yNof3wFYIbHqWeq4jY0+ywQX pro1x-nod"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJNFbzt0NHVTaptBI38YtwLG+AsmeNYy0Nr5yX2zZEPE root@vacuInstaller toptop-root"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICVeSzDkGTueZijB0xUa08e06ovAEwwZK/D+Cc7bo91g triple-dezert"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOtwtao/TXbiuQOYJbousRPVesVcb/2nP0PCFUec0Nv8 triple-dezert-root"
    ];
  };

  security.sudo.extraRules = [
    {
      users = [ "shelvacu" ];
      runAs = "postgres";
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  security.polkit.extraConfig = ''
    // allow:
    // - systemctl restart|start|stop SERVICE
    polkit.addRule(function(action, subject) {
      if (subject.user == "shelvacu" && action.id == "org.freedesktop.systemd1.manage-units") {
        switch (action.lookup("verb")) {
          // case "cancel":
          // case "reenable":
          case "restart":
          // case "reload":
          // case "reload-or-restart":
          case "start":
          case "stop":
          // case "try-reload-or-restart":
          // case "try-restart":
            return polkit.Result.YES;
          default:
        }
      }
    })
  '';

  sane.persist.sys.byStore.private = [
    { path = "/home/shelvacu/persist"; user = "shelvacu"; group = "users"; mode = "0700"; }
  ];
}
