final: prev: {
  grub2 = prev.grub2.overrideAttrs (attrs: {
    version = "2.06.r499.ge67a551a4";

    src = prev.fetchgit {
      url = "https://git.savannah.gnu.org/git/grub.git";
      rev = "e67a551a48192a04ab705fca832d82f850162b64";
      hash = "sha256-HycIXy8qf56JVQP5KUavfNShyU0hE+/HrdbT/ZBnzzI=";
    };

    patches = [
      ./fix-bash-completion.patch
      (prev.fetchpatch {
        name = "Add-hidden-menu-entries.patch";
        # https://lists.gnu.org/archive/html/grub-devel/2016-04/msg00089.html
        url = "https://marc.info/?l=grub-devel&m=146193404929072&q=mbox";
        hash = "sha256-cQnuby1jJ/RfIy/YB3j4eidp/Ubpng6i0VrFpgoOigM=";
      })

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
    ];
    nativeBuildInputs =
      (builtins.filter (x: x.name != "autoreconf-hook") attrs.nativeBuildInputs)
      ++ (with final; [
        autoconf
        automake
      ]);

    preConfigure =
      let
        gnulib = final.fetchgit {
          url = "https://git.savannah.gnu.org/r/gnulib.git";
          rev = "06b2e943be39284783ff81ac6c9503200f41dba3";
          hash = "sha256-xhxN8Tw15ENAMSE/cTkigl5yHR3T2d7B1RMFqiMvmxU=";
        };
      in
      builtins.replaceStrings
        [ "patchShebangs ." ]
        [
          ''
            patchShebangs .

            ./bootstrap --no-git --gnulib-srcdir=${gnulib}
          ''
        ]
        attrs.preConfigure;

    configureFlags = attrs.configureFlags ++ [
      "--disable-nls"
      "--disable-silent-rules"
      "--disable-werror"
    ];
  });
}
