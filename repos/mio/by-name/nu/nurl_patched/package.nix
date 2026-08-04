{ nurl }:

nurl.overrideAttrs (prevAttrs: {
  patches = (prevAttrs.patches or [ ]) ++ [
    ./0001-prefer-fetchurl-fallback-without-rev.patch
  ];
})
