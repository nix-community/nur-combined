# soulseek filesharing GUI app
{ pkgs, ... }:
{
  sane.programs.nicotine-plus = {
    packageUnwrapped = pkgs.nicotine-plus.overrideAttrs (upstream: {
      postInstall = (upstream.postInstall or "") + ''
        # XXX: nixpkgs creates this symlink, seemingly just for convenience;
        # third-party tools like `firejail` lack a profile for "nicotine-plus", and just for "nicotine" instead.
        rm $out/bin/nicotine-plus
      '';
    });

    sandbox.method = "firejail";
    sandbox.whitelistWayland = true;
    sandbox.net = "vpn";

    # ".config/nicotine": contains the config file, with plaintext creds.
    # TODO: define this as a secret instead of persisting it.
    persist.byStore.private = [ ".config/nicotine" ];
  };
}
