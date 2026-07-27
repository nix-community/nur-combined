{
  more_uarches = { lib, fetchpatch, hostPlatform, linux, kernelArch ? null, gccArch ? hostPlatform.linux-kernel.arch or hostPlatform.gcc.arch or "x86-64-v3" }: let
    name = "more-uarches";
    srcs = lib.mapAttrs doSrc {
      "4.19" = {
        versionRange = "4.19-5.4";
        sha256 = "14xczd9bq6w9rc0lf8scq8nsgphxlnp7jqm91d0zvxj0v0mqylch";
      };
      "5.8" = {
        versionRange = "5.8-5.14";
        sha256 = "079f1gvgj7k1irj25k6bc1dgnihhmxvcwqwbgmvrdn14f7kh8qb3";
      };
      "5.15" = {
        versionRange = "5.15-5.16";
        sha256 = "sha256-WSN+1t8Leodt7YRosuDF7eiSL5/8PYseXzxquf0LtP8=";
      };
      "5.17" = {
        versionRange = "5.17-6.1.78";
        sha256 = "sha256-HPaB0/vh5uIkBLGZqTVcFMbm87rc9GVb5q+L1cHAE/o=";
      };
      "6.1.79" = {
        versionRange = "6.1.79+"; # 6.1.79%2B
        sha256 = "sha256-ZEeeQViUZWunzZzeJ6z9/RwoNaQzzJK7q1yBUh4weXE=";
      };
      "6.8-rc4" = {
        versionRange = "6.8-rc4+";
        sha256 = "sha256-VjdF4DC/midcNGcYGrquLwCpkZKeghVbWI3S9++RTV8=";
        lite = "only";
      };
      "6.15-rc1" = {
        versionRange = "6.15-rc1-6.15.x";
        sha256 = "sha256-dzZUDYv583vPtTMouwzUTVkrKIgHH6XcLCmkwmCvOPQ=";
        lite = true;
      };
      "6.16" = {
        versionRange = "6.16+";
        sha256 = "sha256-I7WZJ7hwOcV9wNw5Ub9u2sIY+pvWzQItsKnMx9vPJ7s=";
        lite = true;
      };
    };
    doSrc = v: { versionRange, sha256, ... }@src: fetchpatch {
      name = name + "-${versionRange}.patch";
      url = patchUrl v src;
      inherit sha256;
    };
    rev = src: if src ? lite
      then "a814e64f4f871a9e4ed74026cfae9bc24fb166ce"
      else "c409515574bd4d69af45ad74d4e7ba7151010516";
    filename = { versionRange, sha256, lite ? false }@src: let
      range = lib.replaceStrings [ "+" ] [ "%2B" ] versionRange;
    in if ! src ? lite
      then "more-uarches-for-kernel-${range}.patch"
      else if lite == "only" then "lite-more-x86-64-ISA-levels-for-kernel-${range}.patch"
      else "more-ISA-levels-and-uarches-for-kernel-${range}.patch";
    patchUrl = v: src: "https://github.com/graysky2/kernel_compiler_patch/raw/${rev src}/${filename src}";
  in {
    inherit name srcs;
    patch =
      if lib.versionOlder linux.version "5.8" then srcs."4.19"
      else if lib.versionOlder linux.version "5.15" then srcs."5.8"
      else if lib.versionOlder linux.version "5.17" then srcs."5.15"
      else if lib.versionOlder linux.version "6.1.79" then srcs."5.17"
      else if lib.versionOlder linux.version "6.8"
        || (lib.hasPrefix "6.8-rc" linux.version && lib.versionOlder linux.version "6.8-rc4")
      then srcs."6.1.79"
      else if lib.versionOlder linux.version "6.15"
      then srcs."6.8-rc4"
      else if lib.versionOlder linux.version "6.16"
      then srcs."6.15-rc1"
      else srcs."6.16";
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
        znver4 = "MZEN4";
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
        alderlake = "MALDERLAKE";
        raptorlake = "MRAPTORLAKE";
        meteorlake = "MMETEORLAKE";
        emeraldrapids = "MEMERALDRAPIDS";
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

  # used by appending to `pkgs.linuxPackagesOverlays`
  overlays = { }: {
    zfsVersionOverride = kself: ksuper: {
      zfs = ksuper.zfs.overrideAttrs (old: {
        meta = old.meta // {
          broken = false;
        };
      });
      zfsUnstable = ksuper.zfsUnstable.overrideAttrs (old: {
        meta = old.meta // {
          broken = false;
        };
      });
    };
  };
}
