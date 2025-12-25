#!/usr/bin/env bash
if [ -e .attrs.sh ]; then source .attrs.sh; fi
source $stdenv/setup

unpackFile() {
  skip=$(sed 's/^skip=//; t; d' $src)
  tail -n +$skip $src | bsdtar xvf -
  sourceRoot=.
}

buildPhase() {
  runHook preBuild

  if [ -n "$bin" ]; then
    # Create the module.
    echo "Building linux driver against kernel: $kernel"
    cd kernel
    unset src # used by the nv makefile

    # Disable config checks
    if [ -f "conftest.sh" ]; then
      sed -i "s/test_configuration_option /true /g" conftest.sh
    fi

    if [ -f "nvidia-vgpu-vfio/vgpu-vfio-mdev.c" ]; then
      sed -i "s#int nv_vfio_mdev_register_driver()#int nv_vfio_mdev_register_driver(void)#g" nvidia-vgpu-vfio/vgpu-vfio-mdev.c
      sed -i "s#void nv_vfio_mdev_unregister_driver()#void nv_vfio_mdev_unregister_driver(void)#g" nvidia-vgpu-vfio/vgpu-vfio-mdev.c
    fi

    make $makeFlags -j $NIX_BUILD_CORES module

    cd ..
  fi

  runHook postBuild
}

installPhase() {
  runHook preInstall

  # Install libGL and friends.

  # since version 391, 32bit libraries are bundled in the 32/ sub-directory
  if [ "$i686bundled" = "1" ]; then
    mkdir -p "$lib32/lib"
    # vGPU drivers do not have 32 bit libraries
  fi

  mkdir -p "$out/lib"
  cp -prd *.so.* "$out/lib/"
  if [ -d tls ]; then
    cp -prd tls "$out/lib/"
  fi

  # Install systemd power management executables
  if [ -e systemd/nvidia-sleep.sh ]; then
    mv systemd/nvidia-sleep.sh ./
  fi
  if [ -e nvidia-sleep.sh ]; then
    sed -E 's#(PATH=).*#\1"$PATH"#' nvidia-sleep.sh >nvidia-sleep.sh.fixed
    install -Dm755 nvidia-sleep.sh.fixed $out/bin/nvidia-sleep.sh
  fi

  if [ -e systemd/system-sleep/nvidia ]; then
    mv systemd/system-sleep/nvidia ./
  fi
  if [ -e nvidia ]; then
    sed -E "s#/usr(/bin/nvidia-sleep.sh)#$out\\1#" nvidia >nvidia.fixed
    install -Dm755 nvidia.fixed $out/lib/systemd/system-sleep/nvidia
  fi

  if [ -n "$bin" ]; then
    # Install the kernel module.
    mkdir -p $bin/lib/modules/$kernelVersion/misc
    for i in $(find ./kernel -name '*.ko'); do
      nuke-refs $i
      cp $i $bin/lib/modules/$kernelVersion/misc/
    done
  fi

  # All libs except GUI-only are installed now, so fixup them.
  for libname in $(find "$out/lib/" "$bin/lib/" -name '*.so.*'); do
    # I'm lazy to differentiate needed libs per-library, as the closure is the same.
    # Unfortunately --shrink-rpath would strip too much.
    patchelf --set-rpath "$out/lib:$libPath" "$libname"

    libname_short=$(echo -n "$libname" | sed 's/so\..*/so/')

    if [[ $libname != "$libname_short" ]]; then
      ln -srnf "$libname" "$libname_short"
    fi

    if [[ $libname_short =~ libEGL.so || $libname_short =~ libEGL_nvidia.so || $libname_short =~ libGLX.so || $libname_short =~ libGLX_nvidia.so ]]; then
      major=0
    else
      major=1
    fi

    if [[ $libname != "$libname_short.$major" ]]; then
      ln -srnf "$libname" "$libname_short.$major"
    fi
  done

  if [ -n "$bin" ]; then
    # Install /share files.
    mkdir -p $bin/share/man/man1
    cp -p *.1.gz $bin/share/man/man1
    rm -f $bin/share/man/man1/{nvidia-xconfig,nvidia-settings,nvidia-persistenced}.1.gz

    # Install the programs.
    for i in nvidia-smi nvidia-debugdump nvidia-vgpud nvidia-vgpu-mgr; do
      if [ -e "$i" ]; then
        install -Dm755 $i $bin/bin/$i
        # unmodified binary backup for mounting in containers
        install -Dm755 $i $bin/origBin/$i
        patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          --set-rpath $out/lib:$libPath $bin/bin/$i
      fi
    done
    # FIXME: needs PATH and other fixes
    # install -Dm755 nvidia-bug-report.sh $bin/bin/nvidia-bug-report.sh
    install -Dm755 sriov-manage $bin/bin/sriov-manage

    # Install vGPU config
    install -Dm644 vgpuConfig.xml $bin/share/nvidia/vgpu/vgpuConfig.xml
  fi

  if [ -n "$vgpuConfig" ]; then
    install -Dm644 vgpuConfig.xml $vgpuConfig/vgpuConfig.xml
  fi

  runHook postInstall
}

fixupPhase() {
  runHook preFixup

  # Apply fixup to each output.
  local output
  for output in $(getAllOutputNames); do
    prefix="${!output}" runHook fixupOutput
  done

  runHook postFixup
}

genericBuild
