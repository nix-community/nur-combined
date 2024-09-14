_final: prev: {
  grub2 = prev.grub2.overrideAttrs (attrs: {
    patches = [
      # argon2 patches from AUR: https://aur.archlinux.org/packages/grub-improved-luks2-git
      (prev.fetchpatch {
        name = "argon_1.patch";
        url = "https://aur.archlinux.org/cgit/aur.git/plain/argon_1.patch?h=grub-improved-luks2-git";
        hash = "sha256-WCt+sVr8Ss/bAI41yMJmcZoIPVO1HFEjw1OVRUPYb+w=";
      })
      (prev.fetchpatch {
        name = "argon_2.patch";
        url = "https://aur.archlinux.org/cgit/aur.git/plain/argon_2.patch?h=grub-improved-luks2-git";
        hash = "sha256-OMQYjTFq0PpO38wAAXRsYUfY8nWoAMcPhKUlbqizIS8=";
      })
      (prev.fetchpatch {
        name = "argon_3.patch";
        url = "https://aur.archlinux.org/cgit/aur.git/plain/argon_3.patch?h=grub-improved-luks2-git";
        hash = "sha256-rxtvrBG4HhGYIvpIGZ7luNH5GPbl7TlqbNHcnR7IZc8=";
      })
      (prev.fetchpatch {
        name = "argon_4.patch";
        url = "https://aur.archlinux.org/cgit/aur.git/plain/argon_4.patch?h=grub-improved-luks2-git";
        hash = "sha256-Hz88P8T5O2ANetnAgfmiJLsucSsdeqZ1FYQQLX0WP3I=";
      })
      (prev.fetchpatch {
        name = "argon_5.patch";
        url = "https://aur.archlinux.org/cgit/aur.git/plain/argon_5.patch?h=grub-improved-luks2-git";
        hash = "sha256-cs5dKI2Am+Kp0/ZqSWqd2h/7Oj+WEBeKgWPVsCeMgwk=";
      })
      (prev.fetchpatch {
        name = "grub-install_luks2.patch";
        url = "https://aur.archlinux.org/cgit/aur.git/plain/grub-install_luks2.patch?h=grub-improved-luks2-git";
        hash = "sha256-I+1Yl0DVBDWFY3+EUPbE6FTdWsKH81DLP/2lGPVJtLI=";
      })
    ] ++ attrs.patches;
  });
}
