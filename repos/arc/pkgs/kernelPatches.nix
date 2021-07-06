{
  unprivileged_overlay_mounts = { fetchpatch }: rec {
    name = "unprivileged_overlay_mounts";
    patch = fetchpatch {
      name = name + ".patch";
      url = "https://patchwork.kernel.org/series/397711/mbox/";
      sha256 = "0k4zsrrwpmjvvwbdbgn5qrj2sgk3b064rpfhxyk22zqs40wkxh47";
    };
  };

  more_uarches = { kernelPatches, hostPlatform, kernelArch ? null, gccArch ? null }@args: kernelPatches.more_uarches_5_8.override (
    builtins.removeAttrs args [ "kernelPatches" ]
  );
  more_uarches_5_8 = { fetchpatch, hostPlatform, kernelArch ? null, gccArch ? hostPlatform.linux-kernel.arch or hostPlatform.gcc.arch or "x86-64-v3" }: rec {
    name = "more-uarches";
    patch = fetchpatch {
      name = name + ".patch";
      url = "https://github.com/graysky2/kernel_gcc_patch/raw/199cd0cfc568f17dabcc0b29e8bda4974ab3653e/more-uarches-for-kernel-5.8%2B.patch";
      sha256 = "192ax0jxhsvfccn795nfsdqdbyyggjyq83p6byhkiias491b1psc";
    };
    extraConfig = let
      archconfig = if kernelArch != null then kernelArch else {
        barcelona = "MBARCELONA";
        btver1 = "MBOBCAT";
        btver2 = "MJAGUAR";
        bdver1 = "MBULLDOZER";
        bdver2 = "MPILEDRIVER";
        bdver3 = "MSTEAMROLLER";
        bdver4 = "MEXCAVATOR";
        znver1 = "MZEN";
        znver2 = "MZEN2";
        znver3 = "MZEN3";
        core2 = "MCORE2";
        nehalem = "MNEHALEM";
        westmere = "MWESTMERE";
        silvermont = "MSILVERMONT";
        goldmont-plus = "MGOLDMONTPLUS";
        sandybridge = "MSANDYBRIDGE";
        ivybridge = "MIVYBRIDGE";
        haswell = "MHASWELL";
        broadwell = "MBROADWELL";
        skylake = "MSKYLAKE";
        skylake-avx512 = "MSKYLAKEX";
        cannonlake = "MCANNONLAKE";
        cascadelake = "MCASCADELAKE";
        cooperlake = "MCOOPERLAKE";
        tigerlake = "MTIGERLAKE";
        sapphirerapids = "MSAPPHIRERAPIDS";
        rocketlake = "MROCKETLAKE";
        x86-64-v2 = "GENERIC_CPU2";
        x86-64-v3 = "GENERIC_CPU3";
        x86-64-v4 = "GENERIC_CPU4";
        native-intel = "MNATIVE_INTEL";
        native-amd = "MNATIVE_AMD";
      }.${gccArch} or "unknown option for ${gccArch}";
    in ''
      ${archconfig} y
    '';
  };

  efifb-nobar = { }: {
    name = "efifb-nobar";
    patch = ./public/linux/efifb-nobar.patch;
  };

  i915-vga-arbiter = { fetchpatch }: rec {
    name = "i915-vga-arbiter";
    patch = fetchpatch {
      name = name + ".patch";
      url = "https://aur.archlinux.org/cgit/aur.git/plain/i915-vga-arbiter.patch?h=linux-vfio&id=502122d0ae08290620e012155a9071a6a0cf2b79";
      sha256 = "13k1ia2zmak21d1j6ihml39039di2llhfwn66qlq27hx5jbya5z8";
    };
  };

  acs-override = { kernelPatches }: kernelPatches.acs-override_5_10_4;
  acs-override_5_10_4 = { fetchpatch }: rec {
    name = "acs-override";
    patch = fetchpatch {
      name = name + ".patch";
      url = "https://gitlab.com/Queuecumber/linux-acs-override/-/raw/master/workspaces/5.10.4/acso.patch?inline=false";
      sha256 = "0qjb66ydbqqypyvhhlq8zwry8zcd8609y8d4a0nidhq1g6cp9vcw";
    };
  };
}
