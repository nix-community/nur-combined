{ librime, fetchpatch }:
librime.overrideAttrs {
  patches = [
    (fetchpatch {
      url = "https://github.com/wrvsrx/librime/compare/tag_support-saving-options-2%5E...tag_support-saving-options-2.patch";
      hash = "sha256-3LuTGkXGEpOKax4yN8yunoU8dysQIDFeGnK+2Tcokh8=";
    })
  ];
}
