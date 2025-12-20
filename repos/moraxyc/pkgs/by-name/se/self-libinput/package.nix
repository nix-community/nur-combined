{ pkgs, ... }:
pkgs.libinput.overrideAttrs (
  _finalAttrs: _prevAttrs: {
    patches = _prevAttrs.patches or [ ] ++ [
      ./0002-enable-3fg-drag-by-default.patch
    ];
  }
)
