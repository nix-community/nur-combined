{ pkgs, ... }:
{
  sane.programs.pwsp = {
    packageUnwrapped = pkgs.pwsp.overrideAttrs (upstream: {
      patches = (upstream.patches or []) ++ [
        # TODO(2025-12-06): both of these are upstreamable
        (pkgs.fetchpatch {
          name = "attach-to-system-default-mic";
          url = "https://git.uninsane.org/colin/pipewire-soundpad/commit/66c38a812ec38998d87bed2cc15e3dedb9de1e18.patch";
          hash = "sha256-DoudXcwAqrj8LDX1s3KNn0KtbLuAmv6pXFm/f0Ux2kg=";
        })
        (pkgs.fetchpatch {
          name = "fix-mono-capture-devices";
          url = "https://git.uninsane.org/colin/pipewire-soundpad/commit/fc4726b529462a9a7559c7562f5005f5b4600de2.patch";
          hash = "sha256-0oqxHkpZ+4lz6o25PPjhS7OpMbaF4vJHKOpifhpKAB8=";
        })
      ];
    });

    sandbox.method = null;  #< TODO: sandbox

    # fs.".config/pwsp/daemon.json".symlink.text = ''
    #   {
    #     "default_input_name": null,
    #     "default_volume": null
    #   }
    # '';

    fs.".config/pwsp/gui.json".symlink.text = ''
      {
        "scale_factor": 1.0,
        "save_volume": false,
        "save_input": true,
        "save_scale_factor": false,
        "dirs": [
          "/home/colin/Music"
        ]
      }
    '';

    # XXX(2025-12-06): default input can't be statically computed;
    # there's often only one non-pwsp input device on the system,
    # so we could get decent behavior with `pwsp-cli get inputs` -> `pwsp-cli set input ...` applied automatically on every launch.
    # or we can say "configure it one time in the GUI and then persist it".
    # persist.byStore.plaintext = [
    #   "config/pwsp/daemon.json"
    # ];

    services.pwsp-daemon = {
      description = "pwsp-daemon (provides a virtual Pipewire mic, which mixes a real mic with a soundboard, controlled by pwsp-gui)";
      command = "pwsp-daemon";
      depends = [ "wireplumber" ];  # or maybe just "pipewire"
      partOf = [ "sound" ];
    };
  };
}
