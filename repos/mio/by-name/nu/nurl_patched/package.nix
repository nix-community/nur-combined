{ nurl }:

nurl.overrideAttrs (prevAttrs: {
  patches = (prevAttrs.patches or [ ]) ++ [
    ./0001-prefer-fetchurl-fallback-without-rev.patch
    ./0002-add-name-attribute-to-github-pr-patches.patch
  ];
})
