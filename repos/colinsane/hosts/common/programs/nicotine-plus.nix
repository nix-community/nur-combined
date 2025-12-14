# soulseek music sharing GUI app
{ pkgs, ... }:
{
  sane.programs.nicotine-plus = {
    packageUnwrapped = pkgs.nicotine-plus.overrideAttrs (upstream: {
      # nicotine gets confused by permissions. it needs a *writeable* config or config.old to use either.
      # but the secrets are not writable.
      # so, copy config (the secret) to config.old on launch & make it writeable.
      postInstall = ''
        wrapProgramShell $out/bin/nicotine \
          --run "cp --update=none ~/.config/nicotine/config ~/.config/nicotine/config.old" \
          --run "chmod u+w ~/.config/nicotine/config.old"
        ${upstream.postInstall}
      '';
    });
    sandbox.whitelistWayland = true;
    sandbox.net = "vpn";
    sandbox.extraHomePaths = [
      "Music"
      # on run, nicotine will try to move the initial config to `config.old`
      # and then update the config on disk. it errors if it can't `mv` it like that.
      ".config/nicotine"
    ];
    # sandbox.mesaCacheDir = ".cache/nicotine/mesa";  # don't persist (privacy); (might want to apply that to downloads too)

    # the config has loooads of options, but the only critical one is auth/creds.
    # run with ~/.config/nicotine in the sandbox and nicotine will derive the whole config
    # and write back *all* options for you to then edit further.
    secrets.".config/nicotine/config" = ../../../secrets/common/nicotine-config.bin;
    persist.byStore.plaintext = [
      ".local/share/nicotine/downloads"  #< this dir is configured by `transfers.downloaddir` config
    ];
  };
}
