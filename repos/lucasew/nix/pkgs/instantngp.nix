{ stdenv
, lib
, cmake
, colmap
, ffmpeg
, cudatoolkit
, zlib
, gnumake
, fetchFromGitHub
, addOpenGLRunpath
, python3Packages
, makeWrapper
}:

stdenv.mkDerivation {
  pname = "instantngp";
  version = "2023.04.14-unstable";

  src = fetchFromGitHub {
    owner = "NVlabs";
    repo = "instant-ngp";
    rev = "e45134b9bcf50d0c04f27bc3ab3cde57c27f5bc8";
    fetchSubmodules = true;
    deepClone = true;
  };

  # TCNN_CUDA_ARCHITECTURES = 37; # K80
  TCNN_CUDA_ARCHITECTURES = 86; # K80

  patchPhase = ''
    substituteInPlace src/common.cu \
      --replace 'fs::path get_executable_dir() {' "fs::path get_executable_dir() { return \"$out/share/instant-ngp\";"
  '';

  cmakeFlags = [
    # "-DNGP_BUILD_WITH_GUI=OFF"
  ];

  nativeBuildInputs = [ cmake cudatoolkit addOpenGLRunpath makeWrapper ];

  enableParallelBuilding = true;

  buildInputs = [ zlib python3Packages.python ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib,include,${python3Packages.python.sitePackages},share/instant-ngp}
    install -m 755 instant-ngp $out/bin
    install -m 755 *.a *.so $out/lib
    install -m 755 *.h $out/include
    mv $out/lib/*cpython* $out/${python3Packages.python.sitePackages}

    for item in configs scripts; do
      cp $src/$item $out/share/instant-ngp -r
    done

    runHook postInstall
  '';

  pythonWrapped = (python3Packages.python.withPackages (p: with p; [
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
  ])).interpreter;

  postFixup = lib.optionalString stdenv.isLinux ''
    addOpenGLRunpath $out/bin/instant-ngp $out/${python3Packages.python.sitePackages}/*.so

    makeWrapper $pythonWrapped $out/bin/instantngp_run \
      --prefix PYTHONPATH : $out/${python3Packages.python.sitePackages} \
      --prefix PYTHONPATH : $out/share/instant-ngp/scripts \
      --add-flags $out/share/instant-ngp/scripts/run.py

    for binary in colmap2nerf convert_image mask_images nsvf2nerf record3d2nerf run; do
      makeWrapper $pythonWrapped $out/bin/instantngp_$binary \
        --prefix PYTHONPATH : $out/${python3Packages.python.sitePackages} \
        --prefix PYTHONPATH : $out/share/instant-ngp/scripts \
        --add-flags $out/share/instant-ngp/scripts/$binary.py
    done
  '';
}
