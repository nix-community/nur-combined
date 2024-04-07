{
  stdenv,
  lib,
  cmake,
  colmap,
  ffmpeg,
  cudatoolkit,
  zlib,
  gnumake,
  fetchFromGitHub,
  runCommand,
  cacert,
  fetchgit,
  addOpenGLRunpath,
  python3Packages,
  makeWrapper,
  git,
  xorg,
  pkg-config,
  libGL,
  vulkan-headers,
  vulkan-loader,
  glew,
  glslang,
  autoPatchelfHook,
  ninja,
}:

stdenv.mkDerivation {
  pname = "instantngp";
  version = "2023.04.14-unstable";

  src =
    runCommand "source-instantngp"
      {
        nativeBuildInputs = [
          git
          cacert
        ];
        outputHashMode = "recursive";
        outputHashAlgo = "sha256";
        outputHash = "sha256-QfRjkuf6rrjihmulLX8BbJrerbsySHGk2jVbgHRGXIA=";
        rev = "8ff8075153102567de1c2e659dafa914348e320a";
        repo = "https://github.com/nvlabs/instant-ngp";
      }
      ''
        git clone --recursive $repo $out
        cd $out
        git checkout $rev
        rm .git -rf
        echo $out
      '';

  enableParallelBuilding = true;

  # TCNN_CUDA_ARCHITECTURES = 37; # K80
  TCNN_CUDA_ARCHITECTURES = 86; # RTX 3060

  patchPhase = ''
    runHook prePatch

    substituteInPlace src/common.cu \
      --replace 'fs::path get_executable_dir() {' "fs::path get_executable_dir() { return \"$out/share/instant-ngp\";"

    runHook postPatch
  '';

  cmakeFlags = [
    # "-DNGP_BUILD_WITH_GUI=OFF"
  ];

  nativeBuildInputs = [
    cmake
    cudatoolkit
    addOpenGLRunpath
    makeWrapper
    pkg-config
    ninja
    autoPatchelfHook # some stuff refer to .so in /build
  ];

  buildInputs = [
    zlib
    python3Packages.python
    xorg.libX11
    xorg.libXrandr
    xorg.libXinerama
    xorg.libXi
    xorg.libXcursor
    libGL
    vulkan-headers
    vulkan-loader
    glew
    glslang
  ];

  preInstall = ''
    # runHook preInstall

    mkdir -p $out/{bin,lib,include,${python3Packages.python.sitePackages},share/instant-ngp}
    install -m 755 instant-ngp $out/bin
    install -m 755 *.a *.so $out/lib
    install -m 755 *.h $out/include
    mv $out/lib/*cpython* $out/${python3Packages.python.sitePackages}

    pwd && ls -1

    echo out lib
    ls $out/lib

    for item in configs scripts; do
      cp $src/$item $out/share/instant-ngp -r
    done

    # runHook postInstall
  '';

  pythonWrapped =
    (python3Packages.python.withPackages (
      p: with p; [
        colmap
        ffmpeg
        # python stuff
        commentjson
        imageio
        numpy
        opencv3
        pillow
        pyquaternion
        scipy
        tqdm
      ]
    )).interpreter;

  # libcuda needs to be resolved during runtime
  autoPatchelfIgnoreMissingDeps = [ "libcuda.so.1" ];

  preFixup = lib.optionalString stdenv.isLinux ''
    autoPatchelf $out/${python3Packages.python.sitePackages} $out/bin

    for f in $out/bin/instant-ngp $out/${python3Packages.python.sitePackages}/*.so; do
      # code stolen from flutter derivation
      if patchelf --print-rpath "$f" | grep /build; then # this ignores static libs (e,g. libapp.so) also
        echo "strip RPath of $f"
        newrp="$(patchelf --print-rpath $f | sed 's;:;\n;g' | grep -v /build | tr '\n' ':'  | sed 's;:$;;')"
        echo patchelf $f
        echo $newp
        patchelf --set-rpath "$newrp" "$f"
      fi
      # patchelf $item --shrink-rpath --allowed-rpath-prefixes /nix # remove stuff referencing /build to rpath
      addOpenGLRunpath $f
    done

    # makeWrapper $pythonWrapped $out/bin/instantngp_run \
    #   --prefix PYTHONPATH : $out/${python3Packages.python.sitePackages} \
    #   --prefix PYTHONPATH : $out/share/instant-ngp/scripts \
    #   --add-flags $out/share/instant-ngp/scripts/run.py

    for binary in run colmap2nerf convert_image mask_images nsvf2nerf record3d2nerf run; do
      makeWrapper $pythonWrapped $out/bin/instantngp_$binary \
        --prefix PYTHONPATH : $out/${python3Packages.python.sitePackages} \
        --prefix PYTHONPATH : $out/share/instant-ngp/scripts \
        --add-flags $out/share/instant-ngp/scripts/$binary.py
    done

    substituteInPlace $out/lib/pkgconfig/openxr.pc \
      --replace 'libdir=${"$"}{exec_prefix}/' 'libdir='
  '';
}
