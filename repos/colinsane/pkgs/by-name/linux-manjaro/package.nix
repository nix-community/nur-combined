{ linux_6_4
, fetchpatch
, pkgs
# something inside nixpkgs calls `override` on the kernel and passes in extra arguments; we'll forward them
, ...
}@args:
let
  # use the latest commit: for linux 6.4.7
  # manjaro's changes between kernel patch versions tend to be minimal if any.
  manjaroBase = "https://gitlab.manjaro.org/manjaro-arm/packages/core/linux/-/raw/6c64aa18076a7dc75bfd854b27906467f5d95336";
  manjaroPatch = args: {
    inherit (args) name;
    patch = fetchpatch ({
      url = "${manjaroBase}/${args.name}?inline=false";
    } // args);
  };

  # the idea for patching off Manjaro's kernel comes from jakewaksbaum:
  # - https://git.sr.ht/~jakewaksbaum/pi/tree/af20aae5653545d6e67a459b59ee3e1ca8a680b0/item/kernel/default.nix
  # - he later abandoned this, i think because he's using the Pinephone Pro which received mainline support.
  manjaroPatches = [
    (manjaroPatch {
      # this patch is critical to enable wifi (RTL8723CS)
      # - the alternative is a wholly forked kernel by megi/megous:
      #   - https://xnux.eu/howtos/build-pinephone-kernel.html#toc-how-to-build-megi-s-pinehpone-kernel
      # - i don't know if this patch is based on megi's or original.
      # - it might be possible to build this rtl8723cs out of tree?
      name = "2001-staging-add-rtl8723cs-driver.patch";
      hash = "sha256-M4MR9Oi90BmaB68kWjezHon/NzXDxu13Hc+TWm3tcjg=";
    })
  ];
in linux_6_4.override (args // {
  kernelPatches = (args.kernelPatches or []) ++ [
    pkgs.kernelPatches.bridge_stp_helper
    pkgs.kernelPatches.request_key_helper
  ] ++ manjaroPatches;
})
