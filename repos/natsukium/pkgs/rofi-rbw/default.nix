{ fetchpatch, rofi-rbw }:
rofi-rbw.overrideAttrs (
  oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [
      (fetchpatch {
        name = "fuzzel-support.patch";
        url = "https://github.com/natsukium/rofi-rbw/commit/20e56d74701a3d640975de7c215d788fbca0e34e.patch";
        includes = [ "src/rofi_rbw/selector.py" ];
        hash = "sha256-7HhDPFj7qvblYRzAv3Jt05t+na+7QyDwHwFLbhxZPqc=";
      })
    ];

    meta = oldAttrs.meta // {
      description = "Patched version of rofi-rbw with fuzzel support";
      homepage = "https://github.com/natsukium/rofi-rbw";
    };
  }
)
