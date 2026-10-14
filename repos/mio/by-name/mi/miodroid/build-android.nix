{
  pkgs ? import <nixpkgs> { },
}:
let
  # Latest commit from https://github.com/nix-community/robotnix/pull/390
  robotnixSrc = builtins.fetchTarball {
    url = "https://github.com/nix-community/robotnix/archive/0e5d81d47974b70a8716c0ae3f8dca20ebada38f.tar.gz";
    sha256 = "sha256-SvXKvEIAhs2fSenivvMGySWMBe0JAaV+Arb31iecMqI=";
  };
  robotnixPkgs = import "${robotnixSrc}/pkgs" { system = pkgs.stdenv.hostPlatform.system; };
  robotnix = import robotnixSrc {
    pkgs = robotnixPkgs;
    configuration =
      { lib, pkgs, ... }:
      let
        # Waydroid's own Android 13 source set, from the manifest they generate
        # for their image builds (Waydroid-ATV/android_vendor_waydroid,
        # manifest_scripts/manifests-33/02-waydroid.xml).  LineageOS has no x86_64
        # device and AOSP has neither their ALSA stack nor their mesa/minigbm
        # forks, so these are what make an x86_64 container image buildable.
        wd =
          owner: repo: rev: hash:
          pkgs.fetchgit {
            url = "https://github.com/${owner}/${repo}";
            inherit rev hash;
          };
        # Their vendor tree also carries the patch set that adapts AOSP/LineageOS
        # to run in a container, applied per target repo by their own
        # apply-patches.sh (which selects base-patches-<sdk>; 33 = Android 13).
        extra =
          wd "WayDroid-ATV" "android_vendor_waydroid" "b1f8b1daafb7c6e6f78004f800e17194f8e717e8"
            "sha256-c50sc8lFqZmHOQR5sYhqSlV9aT3GjBuzqZXvT5QaV0Q=";
        patchMetadata = builtins.fromJSON (builtins.readFile ./waydroid-patch-metadata-33.json);
        # prebuilts/mesa-tools from their manifest.  Mesa is configured with
        # -Dmesa-clc=system and then looks for the prebuilt mesa_clc and
        # vtn_bindgen2 on PATH.  Their wrappers reassemble split libraries next
        # to themselves, which a read-only store path forbids, so reassemble once
        # here and put the tools on PATH.
        mesaTools = pkgs.runCommand "waydroid-mesa-tools" { } ''
          cp -r ${
            wd "WayDroid" "android_prebuilts_mesa-tools" "b5de4e0af2f1e76b53b000fb70c18f1757c7e28f"
              "sha256-0MVyMHI52BLqjpStsQJoIskG4q6ikNQOszTFHQasOoM="
          }/. $out/
          chmod -R u+w $out
          # Their wrappers put only their own bundled libraries on the loader
          # path; on their builders the rest come from the distro.  Bundle the
          # ones the tools need so they also work in a Nix sandbox.
          # mesa_clc is linked against libxml2.so.2; nixpkgs' libxml2 2.15 bumped
          # the soname to .so.16, so take the 2.13 package that still has it.
          for lib in ${pkgs.libxml2_13.out}/lib/libxml2.so* ${pkgs.xz.out}/lib/liblzma.so*; do
            test -e "$lib" || { echo "mesa-tools: MISSING $lib" >&2; exit 1; }
            cp -a "$lib" $out/root/lib64/
          done
          mkdir -p $out/bin
          for t in mesa_clc vtn_bindgen2 asahi_clc panfrost_compile; do
            test -e "$out/$t" || continue
            # Any invocation reassembles the .part.* chunks before exec.  Their
            # shebang is /bin/bash, which the Nix sandbox does not provide, hence
            # the explicit interpreter.
            bash "$out/$t" --version >/dev/null 2>&1 || true
            ln -sf "$out/$t" "$out/bin/$t"
          done
        '';
        # Mesa's configure runs `nm` (meson.build: find_program('nm')).  Expose
        # only that tool: adding all of binutils would also put GNU ld/as on
        # PATH, where they can shadow the Android toolchain's linker/assembler.
        nmTool = pkgs.runCommand "binutils-nm" { } ''
          mkdir -p $out/bin
          ln -s ${pkgs.binutils-unwrapped}/bin/nm $out/bin/nm
        '';
        wdPatches = lib.mapAttrs (_: p: {
          gitPatches = builtins.map (f: "${extra}/${p.dir}/${f}") p.files;
          # Robotnix only runs its patch wrapper when `patches` or `postPatch` is
          # non-empty -- setting `gitPatches` alone is silently ignored (its own
          # waydroid flavor falls into this trap).  This no-op trips the wrapper so
          # the git patches above are actually applied.
          postPatch = "true";
        }) patchMetadata;
      in
      {
        flavor = "lineageos";
        flavorVersion = "20.0"; # LineageOS 20 = Android 13
        # Robotnix names products <prefix><device>, so this is
        # lineage_waydroid_x86_64 -- exactly the product the device tree defines.
        device = "waydroid_x86_64";
        arch = "x86_64"; # not inferred from a device name that is not an arch
        stateVersion = "3";

        source.dirs = lib.mkMerge [
          ({
            # The product itself, plus their vendor tree (props, sepolicy, preinit
            # and the patches referenced above).
            "vendor/extra".src = extra;
            # Robotnix patches build/make with a guard that makes
            # sign_target_files_apks refuse test APK certificates.  It is written
            # against a newer build/make than LineageOS 20 ships, so its single hunk
            # no longer applies ("Hunk #1 FAILED at 294"), and it only affects
            # release signing, which this image does not use.  Keep the read-only
            # source patch that Android 13 does need in order to build out of the
            # store.
            "build/make".patches = lib.mkForce [
              (robotnixSrc + "/modules/13/build_make/0001-Readonly-source-fix.patch")
            ];
            # The product itself.
            "device/waydroid/waydroid".src =
              wd "WayDroid" "android_device_waydroid_waydroid" "2234f4b75220be7065546a2a23f9a4091b8c77d4"
                "sha256-Ail30S4aP2SjPXK0dRE53+MCfRu8x2iRP1gWkM3cCac=";
            # Waydroid's own x86_64 board config sets these; without them mesa's
            # meson setup gets an empty enum and aborts:
            #   Value "" for option "gallium-va" is not one of the choices.
            # (Their production device tree, Waydroid-ATV/android_device_waydroid_waydroid,
            # has BOARD_MESA3D_GALLIUM_VA := enabled and VIDEO_CODECS := all for x86_64.)
            #
            # We take the ARM targets' `disabled` instead: with VA enabled, mesa
            # hard-requires libva via pkg-config and their Android-14-era VA stack
            # does not line up with Android 13 --
            #   ERROR: Dependency lookup for libva with method 'pkgconfig' failed:
            #   Invalid version, need 'libva'
            # It costs hardware video decode only; software decode is unaffected.
            # Flip to `enabled` once the VA stack is sorted out.
            "device/waydroid/waydroid".postPatch = ''
              # The device tree adds "i915 iris crocus" to the driver list.  With
              # mesa built without LLVM, the *gallium* i915 driver is out --
              # meson: "i915 Gallium driver requires LLVM for vertex shaders" --
              # while iris and crocus are NIR-based and need none.  (Vulkan's
              # intel/intel_hasvk are unaffected.)
              substituteInPlace waydroid_x86_64/BoardConfig.mk \
                --replace-fail "+= i915 iris crocus" "+= iris crocus"
              cat >> BoardConfig.mk <<'EOF'

              # Waydroid x86_64: video codecs all; VA-API off (see note in build-android.nix).
              BOARD_MESA3D_GALLIUM_VA := disabled
              BOARD_MESA3D_VIDEO_CODECS := all
              # No rusticl either: it needs host rustc/bindgen and a Rust
              # cross-config the generated meson cross file does not provide.
              BOARD_MESA3D_MESON_ARGS += -Dgallium-rusticl=false
              # Drop the AMD drivers the root board config enables.  Mesa 26.2.4
              # demands libdrm 2.4.133 as soon as amdgpu is in the list, while
              # Waydroid's own libdrm pins 2.4.131 -- their tree cannot satisfy
              # its own combination.  A container image needs software, virtio
              # and (via the device tree) Intel; this keeps those.
              #
              # `softpipe` rather than `llvmpipe`, and no `swrast` (lavapipe):
              # all three need LLVM, and mesa 26.2.4 requires LLVM >= 18 while
              # this tree only has AOSP's external/llvm -- see the note on the
              # mesa postPatch.  softpipe is a plain software rasterizer that
              # needs no LLVM, so the image still has a CPU fallback path.
              BOARD_MESA3D_GALLIUM_DRIVERS := softpipe virgl zink
              BOARD_MESA3D_VULKAN_DRIVERS := virtio
              # Mesa compares the version in the generated libdrm.pc against that
              # requirement, and nothing in Waydroid's tree ever sets this, so
              # their .pc ends up with an empty version ("Invalid version").
              LIBDRM_VERSION := 2.4.131
              EOF
            '';
            "hardware/waydroid".src =
              wd "WayDroid" "android_hardware_waydroid" "6e898e9d18f442873305f4992df6e6148aa1e693"
                "sha256-2MyNK+tlqW7BlrNWa+XAMlw/g2De9ylEU/5CGK71PqY=";

            # Audio: the HAL links libasound, which AOSP 13 does not ship at all.
            "external/alsa-lib".src =
              wd "WayDroid" "android_external_alsa-lib" "8a1eff33a2430b29ea2fc11f32a0a349e90c1c93"
                "sha256-vgp9iGu6Hbqni5nOuGA+hogPQblt8AYTkMrkPEt0+xE=";
            "external/alsa-plugins".src =
              wd "WayDroid" "android_external_alsa-plugins" "fcc0a2c3002ab0e68694896ded9c76dcd4cc1352"
                "sha256-nG2l+kH0AM4FhIGVpClY5DRTgf05uOdYKZsDbpMLmsg=";
            "external/pulseaudio".src =
              wd "WayDroid" "android_external_pulseaudio" "c680b1eec38d618062c0e903cbeacda37297a0b2"
                "sha256-2aYqCJtVbDKgeVBPBJv1Cg/H04OXc3sTtnmHY8k0jSE=";
            "external/libsndfile".src =
              wd "WayDroid" "android_external_libsndfile" "a98ebd6db43760db0130997e3b0141e00222d582"
                "sha256-16xswFKw9CJj/6gYwAKkNGTEE3hswf/qOPIdOrsu3I0=";

            # Display: libgbm_mesa / minigbm gralloc come from their forks, which
            # also *replace* the AOSP mesa3d, libdrm and minigbm trees.
            "external/libdrm".src = lib.mkForce (
              wd "WayDroid" "android_external_libdrm" "6bfcfc725fbe0ece0918535556d61ee567b1ffff"
                "sha256-K+iO57YZ9v8hnHV8gaDw6XxuzYNqsdFx4sFo/uAzcFA="
            );
            "external/minigbm".src = lib.mkForce (
              wd "Waydroid-ATV" "android_external_minigbm" "bd286f0dd6dd8c6829f4abe616ff49e2ddd47077"
                "sha256-heFNYZdgKDkThBgpA7IhbQPzgECSfFFeLQC53TbwdS4="
            );
            "external/mesa".src =
              wd "Waydroid-ATV" "android_external_mesa3d" "a3b2e041325e2de82fab045dbd9f7b149a40532b"
                "sha256-OH+zrSmfGQb4soxZ1H/hyXHmAf/jixhB1YIoJQZMH1U=";
            # Their generated meson cross file hands pkg-config an absolute
            # /usr/bin/pkg-config, which no Nix sandbox has ("Found pkg-config: NO"),
            # even though they *generate* the .pc files it is meant to read.  Resolve
            # it through PATH instead, where envPackages puts pkg-config.
            #
            # Also drop their fake LLVM subproject.  Mesa 26.2.4 requires LLVM
            # >= 18 (meson.build: _llvm_version = '>= 18.0.0'), while this tree
            # ships AOSP's external/llvm; their MESON_LLVM_VERSION stub only
            # *pretends* the version is fine, so mesa's gallivm sources then
            # compile against whatever LLVM lands on the include path:
            #   lp_bld_debug.cpp:386: error: no matching function for call to
            #   'LLVMDIBuilderCreateCompileUnit(...)'
            # (swiftshader's bundled llvm-10, in our case).  Building with
            # -Dllvm=disabled skips those sources; see the board config note for
            # what that costs.
            "external/mesa".postPatch = ''
              substituteInPlace android/mesa3d_cross.mk \
                --replace-fail "'/usr/bin/pkg-config'" "'pkg-config'"
              substituteInPlace android/Android.mk \
                --replace-fail "MESON_GEN_LLVM_STUB := true" "MESON_GEN_LLVM_STUB :="
            '';
            "external/mesa3d".enable = false; # replaced by external/mesa

            # AOSP only added mako in Android 14, so the Android 13 tree has no
            # `mako` module at all -- but Waydroid's mesa fork generates its Vulkan
            # ICD sources with it ("depends on undefined module \"mako\"").
            "external/python/mako".src = pkgs.fetchgit {
              url = "https://android.googlesource.com/platform/external/python/mako";
              rev = "aad9cedd6546140a96fe80ad9dd933598f721c3a";
              hash = "sha256-OdBzWv5LddYKb77oV/dluN8Wsb2tjyayZntDVZFbNJs=";
            };

            # Waydroid's patch set also patches the Intel VA-API stack, which their
            # manifest brings in (hardware/intel/common/{gmmlib,media-driver}).
            "hardware/intel/common/gmmlib".src =
              wd "projectceladon" "gmmlib" "acee26b150043058f722920c8090187426e4abba"
                "sha256-5hYFX1HJcFudWR3IWhQ5JOEh7IMAl7MQF9qTDqrAojQ=";
            "hardware/intel/common/media-driver".src =
              wd "projectceladon" "media-driver" "cd899545e16e475da6f558616d01d71a36d85eba"
                "sha256-qBhAdHz9q1gI8AJ94ruTUJmkwtDmD6OGTAgURb5Ocm4=";
            # ...and the libva stack media-driver links against.
            "external/libva-utils".src =
              wd "android-generic" "external_libva-utils" "2366c39775bb91c082f79aa28e50cc4ee09fc3b2"
                "sha256-gBNCJ0jJcdChuW9VmjQh9jMJEalVOD9SZEAzxp7BNOw=";
            "hardware/intel/common/libva".src =
              wd "android-generic" "hardware_intel_common_libva" "39739b085451142f9e7ed2052cbb36c4d57ce3c8"
                "sha256-wij0ihS4/I9uD7Ms+I8ep1RMsXWswLSQ2jHzpX4cQt4=";
            # libva pins -Werror on itself, and this Android-14-era fork has
            # unused-parameter warnings that AOSP 13's clang rejects:
            #   hardware/intel/common/libva/va/va.c:143:37: error: unused parameter
            #   'user_context' [-Werror,-Wunused-parameter]
            # Downgrade that one warning instead of dropping -Werror wholesale.
            "hardware/intel/common/libva".postPatch = ''
              substituteInPlace Android.bp \
                --replace-fail '"-Werror",' '"-Werror", "-Wno-error=unused-parameter",'
            '';
            "hardware/intel/common/vaapi".src =
              wd "android-generic" "platform_hardware_intel_common_vaapi"
                "2c78afdf91a74f825c229545c83de30c624c87b8"
                "sha256-JrMS5LvW/U3Kr/VMkuc+1S2a/7H3pV5Q3Y5eXqMYm0M=";

            # The device adds this app to PRODUCT_PACKAGES, so the product cannot be
            # configured without it.
            "packages/apps/WaydroidUpdater".src =
              wd "WayDroid" "android_packages_apps_WaydroidUpdater" "6f4b54b90d8747aede5882718216a5a5b31be947"
                "sha256-//V1CDMZaS1pjIjYZQZokHEbRMny0zFvdy+nBXJOxj0=";
          })
          # ...and their patches, one set per target repo.
          wdPatches
        ];

        # Override 'system/core' to patch ueventd for unprivileged user namespaces
        # source.dirs."system/core".patches = [
        #   ./patches/ueventd-rootless.patch
        # ];

        # Flatten APEX to avoid loop mount requirement in rootless containers
        envVars = {
          OVERRIDE_TARGET_FLATTEN_APEX = pkgs.lib.mkForce "true";
          # Waydroid's patches deliberately change the ABI of VNDK libraries
          # (libbinder, libhidlbase, libstagefright, ...), so the ABI dump check
          # against the prebuilt reference dumps in prebuilts/abi-dumps/vndk can
          # never match.  Soong documents SKIP_ABI_CHECKS as "escape hatch to not
          # check any ABI dump"; the check only guards compatibility with prebuilt
          # vendor binaries, which a self-built image does not carry.
          SKIP_ABI_CHECKS = "true";
        };

        # Recompiling the whole of Android for every iteration is the expensive
        # part; ccache keeps the object cache in /var/cache/ccache (already an
        # extra-sandbox-path here) so later runs reuse it.
        ccache.enable = true;

        # Waydroid's mesa is built with meson, which AOSP's build tools do not
        # include ("meson: command not found"), and its python generators import
        # mako/pyyaml -- the same host dependencies Waydroid's own build docs list
        # (python3-mako, python3-yaml).  mkBefore so this python3 wins in PATH.
        #
        # lld is there for mesa's linker wrapper, which their mesa3d_cross.mk
        # generates as `exec ld.lld "$@"` and therefore expects on PATH (on their
        # own builders that is the distro's lld); a Nix build sandbox has none, so
        # clang fails with "unable to execute command: No such file or directory".
        # Their c_link_args deliberately strip flags that newer lld complains
        # about (--no-undefined-version, --fatal-warnings), so a current lld fits.
        envPackages = lib.mkBefore [
          pkgs.meson
          pkgs.lld
          pkgs.glslang # meson wants glslangValidator on PATH
          pkgs.pkg-config # their cross file runs pkg-config for generated .pc files
          mesaTools # mesa_clc / vtn_bindgen2 for -Dmesa-clc=system
          nmTool # mesa's configure runs `nm`
          pkgs.ninja # meson: "Could not detect Ninja v1.8.2 or newer"
          pkgs.flex # meson: needs_flex_bison is true for any gallium build
          pkgs.bison
          (pkgs.python3.withPackages (p: [
            p.mako
            p.pyyaml
            p.packaging # mesa: "packaging or distutils module is required"
          ]))
        ];

        # Example: Completely replace the 'system/sepolicy' directory with a custom fork
        # source.dirs."system/sepolicy".src = pkgs.fetchFromGitHub {
        #   owner = "my-fork";
        #   repo = "android_system_sepolicy";
        #   rev = "my-branch";
        #   hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        # };
      };
  };
in
# This exposes the raw Android images (system.img, vendor.img, etc.)
robotnix.img
