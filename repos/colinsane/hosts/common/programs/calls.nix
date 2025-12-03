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
# LIMITATIONS, COMPATIBILITY
# - 2024-08-20: when switching from wifi -> wwan (4g), may experience about a minute of audio loss.
#   the call stays alive, but no sound in either direction.
#   this appears to be ~40s of general net loss to servo-hn (NetworkManager being slow to switch the default device? wireguard being slow to refresh?),
#   unknown how much time is lost in the upper layers (e.g. dns being refreshed)
# - 2024-08-20: wwan -> wifi switching is (near) flawless. prefer to keep modem powered until end of call, because of audio routing, but OK to power it off.
# - 2024-08-20: audio is not always routed to a good device when the modem is powered.
#   solve by opening `pavucontrol`, go to "configuration" tab, change "Built-in audio" to anything and then back to "Make a phone call (Earpiece, Mic)".
#   i expect my eg25-control-powered script messes with the audio routing.
# - 2024-12-12: contacts are visible when evolution-data-server is enabled, however attempting to call triggers "Can't submit call with no origin"
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
      evolution-data-server-gtk4 = pkgs.evolution-data-server-gtk4.override {
        # drop webkitgtk_6_0 dependency.
        # it's normally cached, but if modifying low-level deps (e.g. pipewire) it's nice to not have to rebuild it,
        # especially since `calls` is part of `moby-min`.
        withGtk4 = false;
      };
      folks = pkgs.folks.override {
        evolution-data-server-gtk4 = pkgs.evolution-data-server-gtk4.override {
          # drop webkitgtk_6_0 dependency.
          withGtk4 = false;
        };
      };
      # XXX(2024-08-18): use Belledonne Communications' (a.k.a. linphone's) sofia_sip.
      # Freeswitch sofia_sip has a bug where a failed DNS query will never return to the caller.
      # see `outgoing_answer_a`: in linphone's this already calls the user's callback; in Freeswitch there's a code branch which leaves the caller hanging.
      sofia_sip = pkgs.sofia-sip-bc;
    }).overrideAttrs (upstream: {
      patches = (upstream.patches or []) ++ [
        (pkgs.fetchpatch {
          # usability improvement... ties the UI visibility to the connection state, so if the UI is gone, then i can't receive calls (and will hopefully notice that more easily!)
          # TODO: see about a more maintainable solution:
          # 1. create gobject-introspection bindings, then a python wrapper which binds the MainWindow and CallWindow notify::visible signals?
          # 2. move this functionality into a gnome calls `plugin`?
          # 3. upstream this; use the Nautilus approach of controlling behavior here with an env var?
          # also TODO: write a nix test for this functionality so that it doesn't break during an upgrade!
          url = "https://git.uninsane.org/colin/gnome-calls/commit/88dbe108a8cf82f9c0766c310218902a8a2a7cd5.patch";
          name = "exit on close (i.e. never daemonize)";
          hash = "sha256-QggVM28X9A2f9SbHMMM38M4zKhjYZrTvsZoitxyczdo=";
        })
        (pkgs.fetchpatch {
          # solves the issue where flakey DNS (especially at boot) could take down call connectivity indefinitely.
          # see: <https://gitlab.gnome.org/GNOME/calls/-/issues/659>
          url = "https://git.uninsane.org/colin/gnome-calls/commit/db9192a69cff2b20b5e8870e34a9b1e694a81c7f.patch";
          name = "sip: attempt reconnection anytime network is routable, not just when routability changes";
          hash = "sha256-agPM3XKXiP5Rxrl26DNA+pnhEPTBEBQBxZe3CoptgII=";
        })
      ];
    }));

    sandbox.mesaCacheDir = ".cache/calls/mesa";
    sandbox.net = "vpn.wg-home";  #< XXX(2024/07/05): my cell carrier seems to block RTP, so tunnel it.
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus.user.call."org.freedesktop.secrets" = "*";  #< TODO: restrict to a subset of secrets
    sandbox.whitelistDbus.user.call."org.mobian_project.CallAudio" = "*";
    sandbox.whitelistDbus.user.call."org.sigxcpu.Feedback" = "*";
    sandbox.whitelistDbus.user.call."org.gnome.evolution.dataserver.*" = "*";  #< TODO: reduce; only needs address book and maybe sources
    sandbox.whitelistDbus.user.own = [ "org.gnome.Calls" ];
    sandbox.whitelistSendNotifications = true;  # for missed calls
    sandbox.whitelistWayland = true;

    persist.byStore.private = [
      # ".cache/folks"      # contact avatars?
      # ".config/calls"
      ".local/share/calls"  # call "records"
      # .local/share/folks  # contacts  (e.g. `.local/share/folks/relationships.ini` with gsetting org/freedesktop/folks/primary-store='key-file'
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
