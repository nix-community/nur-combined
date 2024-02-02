{ lib, ... }:

{
  # TODO: this should be populated per-host
  sane.hosts.by-name."desko" = {
    ssh.user_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPU5GlsSfbaarMvDA20bxpSZGWviEzXGD8gtrIowc1pX";
    ssh.host_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFw9NoRaYrM6LbDd3aFBc4yyBlxGQn8HjeHd/dZ3CfHk";
    wg-home.pubkey = "17PMZssYi0D4t2d0vbmhjBKe1sGsE8kT8/dod0Q2CXc=";
    wg-home.ip = "10.0.10.22";
    lan-ip = "10.78.79.52";
  };

  sane.hosts.by-name."lappy" = {
    ssh.user_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDpmFdNSVPRol5hkbbCivRhyeENzb9HVyf9KutGLP2Zu";
    ssh.host_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILSJnqmVl9/SYQ0btvGb0REwwWY8wkdkGXQZfn/1geEc";
    wg-home.pubkey = "FTUWGw2p4/cEcrrIE86PWVnqctbv8OYpw8Gt3+dC/lk=";
    wg-home.ip = "10.0.10.20";
    lan-ip = "10.78.79.53";
  };

  sane.hosts.by-name."moby" = {
    # ssh.authorized = lib.mkDefault false;  # moby's too easy to hijack: don't let it ssh places
    ssh.user_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICrR+gePnl0nV/vy7I5BzrGeyVL+9eOuXHU1yNE3uCwU";
    ssh.host_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO1N/IT3nQYUD+dBlU1sTEEVMxfOyMkrrDeyHcYgnJvw";
    wg-home.pubkey = "I7XIR1hm8bIzAtcAvbhWOwIAabGkuEvbWH/3kyIB1yA=";
    wg-home.ip = "10.0.10.48";
    lan-ip = "10.78.79.54";
  };

  sane.hosts.by-name."servo" = {
    ssh.authorized = lib.mkDefault false;  # servo presents too many services to the internet: easy atack vector
    ssh.user_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPS1qFzKurAdB9blkWomq8gI1g0T3sTs9LsmFOj5VtqX";
    ssh.host_pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOfdSmFkrVT6DhpgvFeQKm3Fh9VKZ9DbLYOPOJWYQ0E8";
    wg-home.pubkey = "roAw+IUFVtdpCcqa4khB385Qcv9l5JAB//730tyK4Wk=";
    wg-home.ip = "10.0.10.5";
    wg-home.endpoint = "uninsane.org:51820";
    lan-ip = "10.78.79.51";
  };
}
