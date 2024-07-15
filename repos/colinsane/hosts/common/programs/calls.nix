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

    packageUnwrapped = pkgs.rmDbusServicesInPlace (pkgs.calls.overrideAttrs (upstream: {
      patches = (upstream.patches or []) ++ [
        (pkgs.fetchpatch {
          # usability improvement... if the UI is visible, then i can receive calls. otherwise, i can't!
          url = "https://git.uninsane.org/colin/gnome-calls/commit/a19166d85927e59662fae189a780eed18bf876ce.patch";
          name = "exit on close (i.e. never daemonize)";
          hash = "sha256-NoVQV2TlkCcsBt0uwSyK82hBKySUW4pADrJVfLFvWgU=";
        })
      ];
    }));

    sandbox.method = "bwrap";
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
      "callaudiod"  # runtime dependency (optional, but probably needed for mic muting?)
      "feedbackd"  # needs `phone-incoming-call`, in particular
      "gnome-keyring"  # to remember the password
    ];

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
