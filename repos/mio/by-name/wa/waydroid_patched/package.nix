{
  waydroid,
}:

waydroid.overrideAttrs (oldAttrs: {
  pname = "waydroid_patched";

  patches = (oldAttrs.patches or [ ]) ++ [
    ./address-security-concerns.patch
  ];
})
