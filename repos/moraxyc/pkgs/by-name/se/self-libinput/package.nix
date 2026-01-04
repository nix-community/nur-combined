{ upstream, fetchpatch2 }:
upstream.libinput.overrideAttrs (
  _finalAttrs: _prevAttrs: {
    patches = _prevAttrs.patches or [ ] ++ [
      (fetchpatch2 {
        name = "enable-3fg-drag-by-default.patch";
        url = "https://aur.archlinux.org/cgit/aur.git/plain/0001-enable-3fg-drag-by-default.patch?h=libinput-three-finger-drag&id=3a1ee72f46d3b35bb834cf5bc907862a31639ff2";
        hash = "sha256-9jrHTZz7Rk4Mj0HWBNpjW4U82pNn5D5a+CS9yz4vpJY=";
      })
    ];

    passthru = (_prevAttrs.passthru or { }) // {
      _ignoreOverride = true;
    };
  }
)
