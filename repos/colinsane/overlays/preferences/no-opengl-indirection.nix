#       vulkan-loader
#     />            \>
# mesa -> libglvnd -> addDriverRunpath -> /run/opengl-driver
#     \>            />
#       libgbm......
#
# in the end, need to replace /run/opengl-driver with ${mesa}.
# 1. override `addDriverRunpath` with some fake store path (e.g. `placeholder "mesa"`, and give it an additional "mesa" output; empty directory)
# 2. create a meta "mesa" package, with outputs = mesa.outputs ++ [ "addDriverRunpath" "libglvnd" etc ].
#   it just copies `addDriverRunpath` to `$addDriverRunpath`, etc.
#   but where `addDriverRunpath` is `addDriverRunpath.replaceReferencesTo { ${addDriverRunpath.mesa} = ${mesa.addDriverRunpath} }`
#   - except, that just made it circular again...
#
# or:
# 1. override `addDriverRunpath` with `writeSymlink "/run/opengl-driver"`
# 2. replace-dependencies...
# 3. make `writeSymlink "/run/opengl-driver"` be a forbidden reference for everything after
#
# to find runtime users of /run/opengl-driver:
# > nix path-info -r /nix/store/44jszbs5xwx0hb5sji3ylxrvi9hqxhlb-mesa-25.3.4 | xargs rg -uuu --follow '/run/opengl-driver'
#
# we see;
# - libgbm
#   -> /run/opengl-driver/lib/gbm (satisfied by mesa)
# - libglvnd
#   -> /run/opengl-driver/lib (satisfied by mesa)
#   -> /run/opengl-driver/share/glvnd/egl_vendor.d (satisfied by mesa)
# - mesa -> vulkan-loader -> /run/opengl-driver/share (satisfied by mesa + ocl-icd)
#
# N.B.: the following packages are linked into /run/opengl-driver on a "normal" system:
# - mesa/{bin,lib,share/drirc.d,share/glvnd,share/vulkan}
#  - [x] desko
#  - [x] flowy
#  - [x] moby
#  - [ ] servo
# - ocl-icd/{.info,bin,etc,include,lib,llvm,share/doc,share/hip}
#  - [x] desko
#  - [ ] flowy
#  - [ ] moby
#  - [ ] servo
#
# to find how /run/opengl-driver is propagated at build time...
# - `rg /run/opengl-driver $nixpkgs`
# - `rg driverLink $nixpkgs`
#
### non-exhaustive list of users:
# addDriverRunpath: { driverLink = "/run/opengl-driver"; }
# brave -> ${addDriverRunpath.driverLink}/share
# dri-pkgconfig-stub -> ${addDriverRunpath.driverLink}/lib/dri
# google-chrome -> ${addDriverRunpath.driverLink}/share
# gst_all_1.gst-plugins-bad -> ${addDriverRunpath.driverLink}/lib
# - but appears to only use it for cuda, nvcudic, nvenc (i.e. nvidia things)
# libgbm -> ${libglvnd.driverLink}/lib/gbm
# libglvnd -> ${addDriverRunpath.driverLink}/share/glvnd/egl_vendor.d
#   and forwards `addDriverRunpath.driverLink` as its own `passthru.driverLink`
# libva -> ${mesa.driverLink}/lib/dri
# libvdpau -> ${mesa.driverLink}/lib/vdpau
# libvpl -> ${addDriverRunpath.driverLink}/lib
# mesa: forwards `addDriverRunpath.driverLink` as its own `passthru.driverLink`
# ollama -> ${addDriverRunpath.driverLink}/lib
# virtualgl -> addDriverRunpath.driverLink
# virtualgllib -> addDriverRunpath.driverLink
# vulkan-loader -> ${addDriverRunpath.driverLink}/share
# webkitgtk
# -> ${addDriverRunpath.driverLink}/lib
# -> ${addDriverRunpath.driverLink}/share
#
# so, i can totally replace /run/opengl-driver by this pseudo-overlay:
# - addDriverRunpath.overrideAttrs { driverLink = mesa; }
# but since that creates a circular reference (mesa -> vulkan-loader -> (mesa)), consider instead:
# - vulkan-loader has two outputs: `out`, `dev`.
#   - `out` is just a lib/ dir with 3 .so files
#   - `dev` is a lib/ dir with vulkan.pc (adds -L${out} and -I ${vulkan-headers}) and .cmake files
# - mesa adds `${vulkan-loader}/lib to rpath of $out/lib/libgallium*.so and probably (?) consumes its .pc file
# SO:
# - build a vulkan-loader from `FAKE_MESA` package set.
# - build a mesa from `FAKE_MESA` package set.
# - copy/symlink these into a single derivation (`mesa`-with-inline-vulkan-loader)
#   - this gets us a cycle-free `mesa` (and a cycle-free vulkan-loader, if we care)
# - rewrite the FAKE_MESA references to point to this `mesa`-with-inline-vulkan-loader package.
#
# mesa functionality can be tested by running:
# - clinfo
# - eglinfo (pkgs.mesa-demos)
# - eglgears_wayland (pkgs.mesa-demos)
# - mpv-unwrapped
# - vulkaninfo (pkgs.vulkan-tools)
# - vkcube (pkgs.vulkan-tools)
self: super:
let
  inherit (self)
    lib
    runCommand
    writeSymlink
  ;

  removeFromList = item: list:
  let
    parts = lib.partition (p: p != item) list;
  in
    assert
      lib.assertMsg (parts.wrong != []) "failed to remove ${item} from ${list}";
      parts.right;

  replaceInList = from: to: list:
  let
    replaced = lib.foldl'
      (acc: next:
        if next == from then {
          newList = acc.newList ++ [ to ];
          numReplaced = acc.numReplaced + 1;
        } else {
          inherit (acc) numReplaced;
          newList = acc.newList ++ [ next ];
        }
      )
      { newList = []; numReplaced = 0; }
      list
    ;
  in
    assert
      lib.assertMsg (replaced.numReplaced != 0) "failed to replace ${from} -> ${to} in ${list}";
      replaced.newList;

  replaceInString = from: to: str:
  let
    replaced = lib.replaceStrings [ from ] [ to ] str;
  in
    assert
      lib.assertMsg (replaced != str) "failed to replace ${from} -> ${to} in ${str}";
      replaced;

in
  super.lib.composeManyExtensions [
    (_: super: {
      # programs wanting opengl drivers usually get /run/opengl-driver added to their rpath.
      # by the end of this overlay, nothing should have /run/opengl-driver linked.
      # in the meantime, link /run/opengl-driver via store indirection:
      # this allows nix to track which derivations link against opengl-driver
      # (and i can leverage `disallowedReferences`, etc).
      addDriverRunpath = super.addDriverRunpath.overrideAttrs {
        driverLink = writeSymlink "/run/opengl-driver";
      };
    })

    (_: super: let
      # break the circular dependency between mesa and vulkan-loader by building
      # a copy of vulkan-loader directly into the mesa derivation.
      #
      # before:
      #   vulkan-loader <-> mesa
      # after:
      #   vulkan-loader -> mesa (mesa functionality) <-> mesa (vulkan functionality)
      #
      # in effect this reduces the cycle from length 2 (a -> b -> a) to length 1 (a -> a) -- which nix can handle.
      #
      # we could alias the toplevel `vulkan-loader = mesa`, since the latter now provides all the functionality of the former,
      # but it's probably not worth the cost savings
      #
      vulkan-loader-for-inline = (super.vulkan-loader.override {
        # a vulkan-loader with SYSCONFDIR = $out (i.e. `mesa`) instead of /run/opengl-driver
        addDriverRunpath.driverLink = placeholder "out";
      }).overrideAttrs {
        # mesa builder would fail to source vulkan-loader builder if the two disagreed about structuredAttrs
        __structuredAttrs = true;
      };

      # create a shell script that, when sourced, populates a sh env suitable for building vulkan-loaders
      vulkan-loader-attrs-sh = runCommand "vulkan-loader-attrs-sh" {
        nativeBuildInputs = [
          self.pkgsBuildBuild.gnused
        ];
        rawAttrs = vulkan-loader-for-inline.inputDerivation;
        # TODO: remove the set -x & dead code here once i can tolerate a mass-rebuild
      } ''
        set -x
        cp "$rawAttrs" exports

        # inherit $out from the caller
        sed -i s:"$rawAttrs":'$out':g exports
        # inherit ALL outputs of the caller.
        # otherwise, vulkan-loader gets built with `out` but no `dev` and fails install (inputDerivation forces to just one output)
        sed -i 's:declare -A outputs=.*:declare -A outputs=([out]="$out" [dev]="$dev"):g' exports

        # don't try to set "readonly" variables like BASHOPTS, else it just fails the builder
        sed -i 's/declare -r /# declare -r /g' exports
        sed -i 's/declare -ar /# declare -ar /g' exports
        sed -i 's/declare -ir /# declare -ir /g' exports

        # echo 'set -x' >> exports

        cp exports $out
      '';

      mesa = (super.mesa.override {
        # mesa appends `${vulkan-loader}` to gallium's rpath.
        # difficult to disable, so instead let it just add the combined mesa+vl path (likely redundant).
        vulkan-loader = placeholder "out";
      }).overrideAttrs (upstream: {
        buildInputs = removeFromList (placeholder "out") upstream.buildInputs;

        # vulkan-loader expects to install its .pc files into a `dev` output, which mesa lacks
        outputs = lib.unique (upstream.outputs ++ super.vulkan-loader.outputs);

        # build and install our modified `vulkan-loader` inline, before running the normal mesa builder
        # TODO: we'll probably want to add `$dev` to PKG_CONFIG_PATH?
        postPatch = (upstream.postPatch or "") + ''
          NIX_ATTRS_SH_FILE=${vulkan-loader-attrs-sh} \
            ${vulkan-loader-for-inline.builder} ${lib.concatStringsSep " " vulkan-loader-for-inline.args}
        '';

        disallowedReferences = (upstream.disallowedReferences or []) ++ [
          # make sure we actually inlined the vulkan-loader
          vulkan-loader-for-inline
        ];

        passthru = (upstream.passthru or {}) // {
          inherit vulkan-loader-for-inline vulkan-loader-attrs-sh;
        };
      });
    in {
      inherit mesa;
    })

    (_: super: {
      # break the circular dependency between mesa and libgbm by...
      # building a copy of libgbm into the mesa derivation.
      mesa = (super.mesa.override {
        libgbm = null;
      }).overrideAttrs (upstream: {
        mesonFlags = replaceInList
          (lib.mesonBool "libgbm-external" true)
          (lib.mesonBool "libgbm-external" false)
          upstream.mesonFlags
        ;

        disallowedReferences = (upstream.disallowedReferences or []) ++ [
          # super.libgbm
          # self.libgbm
        ];
      });
    })

    (_: super: {
      # break the circular dependency between mesa and libglvnd by...
      # noting that mesa doesn't actually have a runtime dependency on libglvnd;
      # it only consumes libglvnd .pc and .h files, so as to create `libEGL_mesa.so`, etc.
      mesa = super.mesa.override {
        # freeze this specific version of libglvnd:
        # later versions of libglvnd will gain a dependency on mesa in their lib/ directory,
        # but mesa doesn't consume that -- only the .dev files.
        libglvnd = self.libglvnd.override {
          inherit (super) addDriverRunpath;
        };
        libdisplay-info = self.libdisplay-info.override {
          v4l-utils = self.v4l-utils.override {
            withGUI = false;
          };
        };
      };
    })

    (_: super: {
      # close the loop: replace /run/opengl-driver with ${mesa}
      addDriverRunpath = super.addDriverRunpath.overrideAttrs {
        driverLink = self.mesa;
      };

      mesa = super.mesa.overrideAttrs (upstream: {
        disallowedReferences = (upstream.disallowedReferences or []) ++ [
          super.addDriverRunpath.driverLink
        ];
      });
    })

    (_: super: {
      # libadwaita = super.libadwaita.overrideAttrs (upstream: {
      #   # fix checkPhase errors:
      #   # > libEGL warning: DRI3 error: Could not get DRI3 device
      #   # > libEGL warning: Ensure your X server supports DRI3 to get accelerated rendering
      #   # >
      #   # > (/build/source/build/tests/test-back-button:9842): Gdk-WARNING **: 20:50:00.683: Vulkan: ../src/imagination/vulkan/pvr_device.c:1263: Failed to enumerate drm devices (errno 2: No such file or directory) (VK_ERROR_INITIALIZATION_FAILED)
      #   # >
      #   # >
      #   # > 35/66 libadwaita / test-button-content                   FAIL             0.63s   killed by signal 5 SIGTRAP
      #   env.LIBGL_ALWAYS_SOFTWARE = "true";
      #   env.GDK_DISABLE = "vulkan";
      # });

      xvfb-run = super.xvfb-run.overrideAttrs (upstream: {
        # nix consumers of xvfb-run, such as `libadwaita`'s checkPhase, would error if they find hardware drivers but can't open /dev/dri:
        # > libEGL warning: DRI3 error: Could not get DRI3 device
        # > libEGL warning: Ensure your X server supports DRI3 to get accelerated rendering
        # >
        # > (/build/source/build/tests/test-back-button:9842): Gdk-WARNING **: 20:50:00.683: Vulkan: ../src/imagination/vulkan/pvr_device.c:1263: Failed to enumerate drm devices (errno 2: No such file or directory) (VK_ERROR_INITIALIZATION_FAILED)
        # >
        # >
        # > 35/66 libadwaita / test-button-content                   FAIL             0.63s   killed by signal 5 SIGTRAP
        #
        # xvfb-run is the tool most of these use to run their tests; we can assume the virtualized x11 server doesn't support accelerated graphics,
        # so patch it to always disable acceleration.
        # this is arguably not the right place for it, especially the GDK options. but it works for at least `calls` and `libadwaita`.
        installPhase = replaceInString
          "wrapProgram $out/bin/xvfb-run "
          "wrapProgram $out/bin/xvfb-run --set-default LIBGL_ALWAYS_SOFTWARE true --set-default GDK_DISABLE vulkan "
          upstream.installPhase
          ;
      });
    })
  ]
  self super
