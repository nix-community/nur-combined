{ callPackage
, fetchpatch
}:
let
  patches = {
    merged = [
      (fetchpatch {
        # merged post 1.14.2
        # [1/2] sxmo_init: behave well when user's primary group differs from their name
        # [2/2] sxmo_init: ensure XDG_STATE_HOME exists
        url = "https://lists.sr.ht/~mil/sxmo-devel/patches/42309/mbox";
        hash = "sha256-GVWJWTccZeaKsVtsUyZFYl9/qEwJ5U7Bu+DiTDXLjys=";
      })
      (fetchpatch {
        # merged post 1.14.2
        # sxmo_hook_block_suspend: don't assume there's only one MPRIS player
        url = "https://lists.sr.ht/~mil/sxmo-devel/patches/42441/mbox";
        hash = "sha256-YmkJ4JLIG/mHosRlVQqvWzujFMBsuDf5nVT3iOi40zU=";
      })
      (fetchpatch {
        # merged post 1.14.2
        # i only care about patch no. 2
        # [1/2] suspend toggle: silence rm failure noise
        # [2/2] config: fix keyboard files location
        name = "multipatch: 42880";
        url = "https://lists.sr.ht/~mil/sxmo-devel/patches/42880/mbox";
        hash = "sha256-tAMPBb6vwzj1dFMTEaqrcCJU6FbQirwZgB0+tqW3rQA=";
      })
      (fetchpatch {
        # merged post 1.14.2
        name = "Switch from light to brightnessctl";
        url = "https://git.sr.ht/~mil/sxmo-utils/commit/d0384a7caed036d25228fa3279c36c0230795e4a.patch";
        hash = "sha256-/UlcuEI5cJnsqRuZ1zWWzR4dyJw/zYeB1rtJWFeSGEE=";
      })
      (fetchpatch {
        # merged post 1.14.2
        name = "sxmo_hook_lock: allow configuration of auto-screenoff timeout v1";
        url = "https://lists.sr.ht/~mil/sxmo-devel/patches/42443/mbox";
        hash = "sha256-c4VySbVJgsbh2h+CnCgwWWe5WkAregpYFqL8n3WRXwY=";
      })
      (fetchpatch {
        # merged post 1.14.2
        name = "sxmo_wmmenu: respect SXMO_WORKSPACE_WRAPPING";
        url = "https://lists.sr.ht/~mil/sxmo-devel/patches/42698/mbox";
        hash = "sha256-TrTlrthrpYdIMC8/RCMNaB8PcGQgtya/h2/uLNQDeWs=";
      })
      (fetchpatch {
        # merged ~2023/08/22
        name = "Make config gesture toggle persistent";
        url = "https://lists.sr.ht/~mil/sxmo-devel/patches/42876/mbox";
        hash = "sha256-Oa0MI0Kt9Xgl5L1KarHI6Yn4+vpRxUSujB1iY4hlK9c=";
      })
      (fetchpatch {
        # merged ~2023/08/29
        # [1/2] Makefile: obey PREFIX when installing udev rules
        # [2/2] Makefile: use SYSCONFDIR instead of hardcoding /etc
        name = "44110-multipatch-makefile-nixos";
        url = "https://lists.sr.ht/~mil/sxmo-devel/patches/44110/mbox";
        hash = "sha256-jXtwgOVGSjwWj7a36F6P+e63lKvk4OmFIzxTkf9yZMs=";
      })
      (fetchpatch {
        # merged ~2023/10/04
        name = ''sxmo_wmmenu.sh: add "Kill window" option'';
        url = "https://lists.sr.ht/~mil/sxmo-devel/patches/45263/mbox";
        hash = "sha256-qDvlLecAjxcKXP7tvhMnySkWPkj6oV0Z0Qm3kudazdk=";
      })
      (fetchpatch {
        # merged ~2023/10/08
        name = "suspend: block if Dino is in a call";
        url = "https://lists.sr.ht/~mil/sxmo-devel/patches/45470/mbox";
        hash = "sha256-ev+NLR4g68MWB4RENh7mCth02lTaXxCIAL/af5l8Mrw=";
      })
    ];
    unmerged = [
      # (fetchpatch {
      #   XXX: doesn't apply cleanly to 1.14.2 release
      #   # Don't wait for led or status bar in state change hooks
      #   # - significantly decreases the time between power-button state transitions
      #   url = "https://lists.sr.ht/~mil/sxmo-devel/patches/43109/mbox";
      #   hash = "sha256-4uR2u6pa62y6SaRHYRn15YGDPILAs7py0mPbAjsgwM4=";
      # })

      (fetchpatch {
        name = "sxmo_migrate: add option to disable configversion checks";
        url = "https://lists.sr.ht/~mil/sxmo-devel/patches/44155/mbox";
        hash = "sha256-ZcUD2UWPM8PxGM9TBnGe8JCJgMC72OZYzctDf2o7Ub0=";
      })

      ## these might or might not be upstream-worthy
      ./0104-full-auto-rotate.patch
      # ./0106-no-restart-lisgd.patch

      ## not upstreamable
      # let NixOS manage the audio daemons (pulseaudio/pipewire)
      ./0005-system-audio.patch
    ];
    # these don't apply cleanly to the stable release; only to latest
    unmerged-tip-only = [
      # TODO: send these upstream
      (fetchpatch {
        name = "manpage: fix typo to sxmo_hook_network_pre_{up,down}.sh";
        url = "https://git.uninsane.org/colin/sxmo-utils/commit/9954df10f4885c6dad7396829d97a39e20d285dd.patch";
        hash = "sha256-+76kia1kEb7Rj8KgP1ty9VlboB4OlWpZS/U0ANLYE5E=";
      })
      (fetchpatch {
        name = "add defaults for hooks referenced in sxmo_power.sh";
        url = "https://git.uninsane.org/colin/sxmo-utils/commit/3f432023b766db4146aaaa830c68f31494ebe90b.patch";
        hash = "sha256-jkdh6gJg0kQVPf5UnTqSv+4aImN0syuQx96NLctKUPE=";
      })
      (fetchpatch {
        name = "sxmo_hook_apps: add a few";
        url = "https://git.uninsane.org/colin/sxmo-utils/commit/dd17fd707871961906ed4577b8c89f6128c5f121.patch";
        hash = "sha256-Giek1MbyOtlPccmT8XQkLZWhX+EeJdzWVZtNgcLuTsI=";
      })
      (fetchpatch {
        # experimental patch to launch apps via `swaymsg exec -- `
        # this allows them to detach from sxmo_appmenu.sh (so, `pstree` looks cleaner)
        # and more importantly they don't inherit the environment of sxmo internals (i.e. PATH).
        # suggested by Aren in #sxmo.
        #
        # old pstree look:
        # - sxmo_hook_inputhandler.sh volup_one
        #   - sxmo_appmenu.sh
        #     - sxmo_appmenu.sh applications
        #       - <application, e.g. chatty>
        name = "sxmo_hook_apps: launch apps via the window manager";
        url = "https://git.uninsane.org/colin/sxmo-utils/commit/0087acfecedf9d1663c8b526ed32e1e2c3fc97f9.patch";
        hash = "sha256-YwlGM/vx3ZrBShXJJYuUa7FTPQ4CFP/tYffJzUxC7tI=";
      })
      # (fetchpatch {
      #   name = "sxmo_log: print to console";
      #   url = "https://git.uninsane.org/colin/sxmo-utils/commit/030280cb83298ea44656e69db4f2693d0ea35eb9.patch";
      #   hash = "sha256-dc71eztkXaZyy+hm5teCw9lI9hKS68pPoP53KiBm5Fg=";
      # })
    ];
  };
in {
  stable = callPackage ./common.nix {
    version = "1.14.2";
    hash = "sha256-1bGCUhf/bt9I8BjG/G7sjYBzLh28iZSC20ml647a3J4=";
    patches = patches.merged ++ patches.unmerged;
  };
  latest = callPackage ./common.nix {
    version = "unstable-2023-10-05";
    rev = "05fd5112d5f2b49051cbb2f0bbb25202363bf83e";
    hash = "sha256-YmVe9P0w2KSqj6G/az499r7+z3Crfm3TbBIawjVKP1M=";
    patches = patches.unmerged ++ patches.unmerged-tip-only;
  };
}
