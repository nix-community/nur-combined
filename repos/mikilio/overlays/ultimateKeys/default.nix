(
  final: prev: let

    ultimateKeys = builtins.fetchTarball {
      url = "https://github.com/pieter-degroote/UltimateKEYS/archive/refs/tags/r2024-01-22.tar.gz";
      sha256 = "0v4lyi4zsrn07q1wld96zzs8csc8xl19pszvnvgv33k9ylycbhrf";
    };

  in {
    xkeyboard_config  = prev.xkeyboard_config.overrideAttrs (o: {
      postInstall = (o.postInstall or "") + ''
        ln -sf ${ultimateKeys}/linux-xkb/custom $out/share/X11/xkb/symbols/custom
      '';
    });
  }
)
