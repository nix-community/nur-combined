# GNOME calls
# - <https://gitlab.gnome.org/GNOME/calls>
# - both a dialer and a call handler.
# - uses callaudiod dbus service.
#
# initial JMP.chat configuration:
# - message @cheogram.com "reset sip account"  (this is not destructive, despite the name)
# - the bot will reply with auto-generated username/password plus a SIP server endpoint.
#   just copy those into gnome-calls' GUI configurator
# - now gnome-calls can do outbound calls. inbound calls can be routed by messaging the bot: "configure calls"
#
# user guide:
# - "Use for Calls" means, "when i click a tel: URI, use this account": <https://gitlab.gnome.org/GNOME/calls/-/issues/513>
# - `calls -vvv` for verbosity
# - `SOFIA_DEBUG=9 NEA_DEBUG=9 NUA_DEBUG=9 NTA_DEBUG=9 SU_DEBUG=8 gnome-calls` to debug SIP related stuff
#
# LIMITATIONS, COMPATIBILITY (as of 2024-08-20):
# - when switching from wifi -> wwan (4g), may experience about a minute of audio loss.
#   the call stays alive, but no sound in either direction.
#   this appears to be ~40s of general net loss to servo-hn (NetworkManager being slow to switch the default device? wireguard being slow to refresh?),
#   unknown how much time is lost in the upper layers (e.g. dns being refreshed)
# - wwan -> wifi switching is (near) flawless. prefer to keep modem powered until end of call, because of audio routing, but OK to power it off.
# - audio is not always routed to a good device when the modem is powered.
#   solve by opening `pavucontrol`, go to "configuration" tab, change "Built-in audio" to anything and then back to "Make a phone call (Earpiece, Mic)".
#   i expect my eg25-control-powered script messes with the audio routing.
# - `gnome-calls` takes about 2 minutes after launch until it shows the UI.
#   seems to be sandbox related.
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.calls;
in
{
  sane.programs.calls = {
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options.autostart = mkOption {
          type = types.bool;
          default = true;
        };
      };
    };

    packageUnwrapped = pkgs.rmDbusServicesInPlace ((pkgs.calls.override {
      # 46.3 -> 47.xx upgraded gtk3 -> gtk4; nixpkgs package is outdated, so substitute gtk3 deps with gtk4 deps
      evolution-data-server = pkgs.evolution-data-server-gtk4.override {
        # drop webkitgtk_6_0 dependency.
        # it's normally cached, but if modifying low-level deps (e.g. pipewire) it's nice to not have to rebuild it,
        # especially since `calls` is part of `moby-min`.
        withGtk4 = false;
      };
      gtk3 = pkgs.gtk4;
      libpeas = pkgs.libpeas2;
      wrapGAppsHook3 = pkgs.wrapGAppsHook4;
      sofia_sip = pkgs.sofia_sip.overrideAttrs (upstream: {
        # use linphone's sofia_sip.
        # Freeswitch sofia_sip has a bug where a failed DNS query will never return to the caller.
        # see `outgoing_answer_a`: in linphone's this already calls the user's callback; in Freeswitch there's a branch which leaves the caller hanging.
        version = "1.13.45bc-unstable-2024-08-05";
        src = pkgs.fetchFromGitLab {
          domain = "gitlab.linphone.org";
          owner = "BC/public/external";
          repo = "sofia-sip";
          rev = "b924a57e8eeb24e8b9afc5fd0fb9b51d5993fe5d";
          hash = "sha256-1VbKV+eAJ80IMlubNl7774B7QvLv4hE8SXANDSD9sRU=";
        };
      });
    }).overrideAttrs (upstream: {
      # XXX(2024-08-08): v46.3 has a bug where if it has no network connection on launch, it forever stays disconnected & never retries
      version = "47_beta.0-unstable-2024-08-08";
      src = lib.warnIf (lib.versionOlder "47.0" upstream.version) "gnome-calls outdated; remove src override? (keep UI patches though!)" pkgs.fetchFromGitLab {
        domain = "gitlab.gnome.org";
        owner = "GNOME";
        repo = "calls";
        fetchSubmodules = true;
        # rev = "main";
        rev = "ff213579a52222e7c95e585843d97b5b817b2a8b";
        hash = "sha256-0QYC8FJpfg/X2lIjBDooba2idUfpJNQhcpv8Z5I/B4k=";
      };

      patches = (upstream.patches or []) ++ [
        (pkgs.fetchpatch {
          # usability improvement... ties the UI visibility to the connection state, so if the UI is gone, then i can't receive calls (and will hopefully notice that more easily!)
          url = "https://git.uninsane.org/colin/gnome-calls/commit/a19166d85927e59662fae189a780eed18bf876ce.patch";
          name = "exit on close (i.e. never daemonize)";
          hash = "sha256-NoVQV2TlkCcsBt0uwSyK82hBKySUW4pADrJVfLFvWgU=";
        })
        (pkgs.fetchpatch {
          # solves the issue where flakey DNS (especially at boot) could take down call connectivity indefinitely.
          # see: <https://gitlab.gnome.org/GNOME/calls/-/issues/659>
          url = "https://git.uninsane.org/colin/gnome-calls/commit/db9192a69cff2b20b5e8870e34a9b1e694a81c7f.patch";
          name = "sip: attempt reconnection anytime network is routable, not just when routability changes";
          hash = "sha256-agPM3XKXiP5Rxrl26DNA+pnhEPTBEBQBxZe3CoptgII=";
        })
      ];

      nativeBuildInputs = upstream.nativeBuildInputs ++ [
        pkgs.dbus  #< for dbus-run-session (should be test only, but it's not)
      ];

      buildInputs = upstream.buildInputs ++ [
        pkgs.libadwaita
      ];
    }));

    sandbox.net = "vpn.wg-home";  #< XXX(2024/07/05): my cell carrier seems to block RTP, so tunnel it.
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus = [ "user" ];  # necessary for secrets, at the minimum
    sandbox.whitelistWayland = true;

    persist.byStore.private = [
      # ".cache/folks"      # contact avatars?
      # ".config/calls"
      ".local/share/calls"  # call "records"
      # .local/share/folks  # contacts?
    ];
    # this is only the username/endpoint: the actual password appears to be stored in gnome-keyring
    secrets.".config/calls/sip-account.cfg" = ../../../secrets/common/gnome_calls_sip-account.cfg.bin;
    suggestedPrograms = [
      "callaudiod"  # runtime dependency (optional; without this the mute and speaker buttons do not work (ordinarily they function by changing the GLOBAL audio config))
      "feedbackd"  # needs `phone-incoming-call`, in particular
      "gnome-keyring"  # to remember the password
    ];

    mime.associations."x-scheme-handler/tel" = "org.gnome.Calls.desktop";
    mime.associations."x-scheme-handler/sip" = "org.gnome.Calls.desktop";
    mime.associations."x-scheme-handler/sips" = "org.gnome.Calls.desktop";

    services.gnome-calls = {
      description = "gnome-calls daemon to monitor incoming SIP calls";
      partOf = lib.mkIf cfg.config.autostart [ "graphical-session" ];
      # add --verbose for more debugging
      # add --daemon to avoid showing UI on launch.
      #   note that no matter the flags, it returns to being a daemon whenever the UI is manually closed,
      #   revealed when launched.
      # default latency is 10ms, which is too low and i get underruns on moby.
      # 50ms is copied from dino, not at all tuned.
      command = "env G_MESSAGES_DEBUG=all PULSE_LATENCY_MSEC=50 gnome-calls";
    };
  };
}
