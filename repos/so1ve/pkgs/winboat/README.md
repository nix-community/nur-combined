# WinBoat

This package builds WinBoat from latest source code with modifications to prefer using `sdl-freerdp`(Wayland).

## NixOS

Install WinBoat and enable either Docker or Podman. For example, with Docker:

```nix
{
  environment.systemPackages = [
    pkgs.nur.repos.so1ve.winboat
  ];

  virtualisation.docker.enable = true;
  users.users.yourUser.extraGroups = [ "docker" ];
}
```

KVM hardware virtualization must also be available to the selected container runtime.
