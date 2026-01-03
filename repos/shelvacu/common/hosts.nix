{ vacuModules, ... }:
{
  imports = [
    vacuModules.knownHosts
    vacuModules.ssh
  ];

  vacu.hosts = {
    #public hosts
    "github.com".sshKeys =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    "gitlab.com".sshKeys =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";
    "git.sr.ht".sshKeys =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZvRd4EtM7R+IHVMWmDkVU3VLQTSwQDSAvW0t2Tkj60";
    "sdf.org" = {
      sshHostname = "tty.sdf.org";
      sshKeys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJk3a190w/1TZkzVKORvz/kwyKmFY144lVeDFm80p17";
    };
    "rsn" = {
      altNames = [
        "rsyncnet"
        "rsync.net"
      ];
      sshUsername = "fm2382";
      sshHostname = "fm2382.rsync.net";
      sshKeys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINdUkGe6kKn5ssz4WRZKjcws0InbQqZayenzk9obmP1z";
    };

    #colin's stuff
    "servo" = {
      altNames = [
        "git.uninsane.org"
        "uninsane.org"
      ];
      isLan = true;
      sshKeys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOfdSmFkrVT6DhpgvFeQKm3Fh9VKZ9DbLYOPOJWYQ0E8";
    };
    "desko" = {
      isLan = true;
      sshKeys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFw9NoRaYrM6LbDd3aFBc4yyBlxGQn8HjeHd/dZ3CfHk";
    };

    #daymocker's stuff
    "pluto" = {
      sshHostname = "pluto.somevideogam.es";
      primaryIp = "74.208.184.137";
      sshKeys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICpHY4fLZ1hNuB2oRQM7R3b4eQyIHbFB45ZYp3XCELLg";
    };

    #powerhouse hosts
    "ostiary" = {
      isLan = true;
      sshKeys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBSYyd1DGPXGaV4mD34tUbXvbtIi/Uv2otoMUsCkxRse";
    };
    "habitat" = {
      # previously known as zigbee-hub
      primaryIp = "10.78.79.114";
      sshKeys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBJxwUYddOxgViJDOiokfaQ6CsCx/Sw+b3IisdJv8zFN";
    };
    "vnopn" = {
      primaryIp = "10.78.79.1";
      isLan = true;
      sshKeys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEMgJE8shlTYF3nxKR/aILd1SzwDwhtCrjz9yHL7lgSZ";
    };
    "teever" = {
      primaryIp = "10.78.79.3";
      sshKeys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFF45xYVopkdGFpP9dKKyvdrTtejld1VwkN7t7Nnx7YS root@teever";
      sshAliases = [ "tvr" ];
    };

    #personal hosts
    # keep-sorted start block=yes
    awoo = {
      primaryIp = "45.142.157.71";
      sshKeys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOQaDjjfSK8jnk9aFIiYH9LZO4nLY/oeAc7BKIPUXMh1";
    };
    compute-deck = {
      sshKeys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGt43GmXCxkl5QjgPQ/QimW11lKfXmV4GFWvlxQSf4TQ";
    };
    deckvacu = {
      sshUsername = "deck";
      sshKeys = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEa8qpFkIlLLJkH8rmEAn6/MZ9ilCGmEQWC3CeFae7r1kOqfwRk0nq0oyOGJ50uIh+PpwEh3rbgq6mLfpRfsFmM=";
    };
    finaltask = {
      altNames = [
        "rsb"
        "finaltask.xyz"
      ];
      sshAliases = [ "rsb" ];
      primaryIp = "45.87.250.193";
      sshPort = 2222;
      sshUsername = "user";
      sshKeys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPTx8WBNNKBVRV98HgDChpd59SHbreJ87SXU+zOKan6y";
    };
    fw = {
      isLan = true;
      primaryIp = "10.78.79.248";
      sshKeys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA6lX25mCy35tf1NpcHMAdeRgvT7l0Dw0FWBH3eX4TE2";
    };
    legtop = {
      altNames = [ "lt" ];
      isLan = true;
      sshKeys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKvunOGsmHg8igMGo0FpoXaegYI20wZylG8nsMFY4+JL";
    };
    liam = {
      altNames = [ "liam.dis8.net" ];
      primaryIp = "178.128.79.152";
      sshKeys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHOqJYVHOIFmEA5uRbbirIupWvyBLAFwic/8EZQRdN/c";
    };
    mmm = {
      primaryIp = "10.78.79.11";
      isLan = true;
      sshKeys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFsorkZ3rIZ2lLigwQWfA64xZRlt5lk6QPzypg55eLlD";
    };
    prophecy = {
      altNames = [
        "prop"
        "prop.shelvacu.com"
        "prophecy.shelvacu.com"
      ];
      sshAliases = [ "prop" ];
      primaryIp = "205.201.63.13";
      altIps = [ "10.78.79.22" ];
      isLan = true;
      sshKeys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFPmy1+1CL6mLbp0IfRTLwsVdjKmw5u0kbQqHin8oXMq";
      wireguardKey = "shel/wMBU/Ut2rhAZymW/AYG3ycGfaEN6R2LsEpkqDU=";
    };
    solis = {
      altNames = [ "solis.dis8.net" ];
      primaryIp = "143.20.185.171";
      # altIps = [ "2a0f:9400:7e11:cd44:0000:0000:0000:0001" ];
      sshKeys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPhFKmRMfk+4Xx96Jwt6S9/ikC0cm4ukeO8hjpZDj+9n";
      wireguardKey = "S3rZ0vzDm4J5uTkdkL4/RvWbOWKsLkIfTeTBa+TDjzk=";
    };
    # keep-sorted end
  };
}
