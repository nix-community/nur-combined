{ lib
, babeld
, buildGoModule
, ...
} @ args:

babeld.overrideAttrs (old: {
  patches = [ patches/v4-over-v6.patch ];
})
