# GNOME calls
# - <https://gitlab.gnome.org/GNOME/calls>
# - both a dialer and a call handler.
# - uses callaudiod dbus package.
#
# initial JMP.chat configuration:
# - message @cheogram.com "reset sip account"  (this is not destructive, despite the name)
# - the bot will reply with auto-generated username/password plus a SIP server endpoint.
#   just copy those into gnome-calls' GUI configurator
# - now gnome-calls can do outbound calls. inbound calls requires more chatting with the help bot
#
# my setup here is still very WIP.
# open questions:
# - can i receive calls even with GUI closed?
#   - e.g. activated by callaudiod?
#   - looks like `gnome-calls --daemon` does that?
{ config, lib, ... }:
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
          default = false;
        };
      };
    };

    persist.byStore.private = [
      # ".cache/folks"      # contact avatars?
      # ".config/calls"
      ".local/share/calls"  # call "records"
      # .local/share/folks  # contacts?
    ];
    secrets.".config/calls/sip-account.cfg" = ../../../secrets/common/gnome_calls_sip-account.cfg.bin;
    suggestedPrograms = [
      "feedbackd"  # needs `phone-incoming-call`, in particular
    ];

    services.gnome-calls = {
      # TODO: prevent gnome-calls from daemonizing when started manually
      description = "gnome-calls daemon to monitor incoming SIP calls";
      partOf = lib.mkIf cfg.config.autostart [ "graphical-session" ];
      # add --verbose for more debugging
      command = "env G_MESSAGES_DEBUG=all gnome-calls --daemon";
    };
  };
  programs.calls = lib.mkIf cfg.enabled {
    enable = true;
  };
}
