# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ flake, config, ... }:
{
  programs.gpg.enable = true;

  home.sessionVariables.SSH_AUTH_SOCK = "/run/user/1000/gnupg/S.gpg-agent.ssh";

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = true;
    pinentryFlavor = if config.xsession.enable then "gnome3" else "tty";
    sshKeys = [
      "${flake.config.people.users.${flake.config.people.myself}.keys.sshcontrol}"
    ];
  };
}
