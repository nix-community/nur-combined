{ nurl }:

nurl.overrideAttrs (prevAttrs: {
  patches = (prevAttrs.patches or [ ]) ++ [
    ./0001-prefer-fetchurl-fallback-without-rev.patch
    ./0002-add-name-attribute-to-github-patches.patch
    ./0003-store-safe-name-for-fetchurl.patch
    ./0004-file-name-from-content-disposition-or-redirect.patch
    ./0005-probe-as-a-browser.patch
  ];
})
