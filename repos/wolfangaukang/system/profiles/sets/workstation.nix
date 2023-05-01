{ inputs
, hostname
, lib
, ...
}:

let
  inherit (inputs) self;
  inherit (lib) mkForce;

in {
  imports = [
    "${self}/system/profiles/console.nix"
    "${self}/system/profiles/de/pantheon.nix"
    "${self}/system/profiles/environment.nix"
    "${self}/system/profiles/flatpak.nix"
    "${self}/system/profiles/graphics.nix"
    "${self}/system/profiles/layouts.nix"
    "${self}/system/profiles/networking.nix"
    "${self}/system/profiles/rfkill.nix"
    "${self}/system/profiles/security.nix"
    "${self}/system/profiles/time.nix"
    "${self}/system/profiles/users.nix"
    "${self}/system/profiles/services/zerotier.nix"
    (import "${self}/system/profiles/services/openssh.nix" { inherit inputs hostname; })
  ];

  programs.firejail.enable = true;
  specialisation.simplerisk = {
    inheritParentConfig = true;
    configuration = {
      profile = {
        virtualization.podman.enable = mkForce false;
        virtualization.qemu.enable = mkForce false;
        work.simplerisk.enable = true;
      };
      home-manager.users.bjorn.defaultajAgordoj.work.simplerisk.enable = true;
    };
  };
}
