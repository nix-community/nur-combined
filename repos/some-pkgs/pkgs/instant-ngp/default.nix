{ lib
, fetchFromGitHub
, buildPythonPackage
, cmake
, pkg-config
, addOpenGLRunpath
, openexr
, glew
, glfw3
, cudaPackages
, xorg
, numpy
, scipy
, tqdm
, pillow
, pybind11
, lark
, commentjson
, certifi
, python
, symlinkJoin
, cudaArch ? "86"
}:

let
  pname = "instant-ngp";
  version = "unstable-2022-04-07";

  cudatoolkit = symlinkJoin {
    name = "cudatoolkit-root";
    paths = with cudaPackages; [
      cuda_nvcc
      cuda_nvrtc
      cuda_cudart
      libcublas
    ];
    postBuild = ''
      ln -s $out/lib $out/lib64
    '';
  };

  inherit (cudaPackages) cudnn;
in
buildPythonPackage {
  inherit pname version;

  outputs = [ "out" "dev" "data" "configs" ];

  format = "other";

  src = fetchFromGitHub {
    owner = "NVlabs";
    repo = pname;
    rev = "16212cd9e0c80d8345896a864f5af7054723a1d0";
    hash = "sha256-l9nhSUoCLw6GbvQrZMNJggGE2Mv922QJjMAftOtuMg0=";
    fetchSubmodules = true;
  };
  patches = [ ./0001-cmake-add-install-rules.patch ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_LIBDIR=${placeholder "dev"}/${python.sitePackages}"
    "-DCMAKE_CUDA_ARCHITECTURES=${cudaArch}"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    cudatoolkit
    addOpenGLRunpath
  ];
  buildInputs = [
    openexr
    openexr.dev
    glew.dev
    glfw3
    cudnn
  ] ++ [
    xorg.libX11
    xorg.libXcursor.dev
    xorg.libXinerama.dev
    xorg.libXi.dev
    xorg.libXrandr.dev
    xorg.libXext.dev
  ];
  passthru.extras-require.all = [
    numpy
    scipy
    tqdm
    pillow
    pybind11
    lark
    commentjson
    certifi
  ];

  postInstall = ''
    cp -rf ../configs/ $configs
    cp -rf ../data/ $data
  '';

  postFixup = ''
    addOpenGLRunpath $out/bin/* $dev/lib/*.so $dev/${python.sitePackages}/*.so
  '';

  meta = {
    maintainers = [ lib.maintainers.SomeoneSerge ];
    license = lib.licenses.unfreeRedistributable;
    description = "NVIDIA's Instant neural graphics primitives: lightning fast NeRF and more";
    homepage = "https://nvlabs.github.io/instant-ngp/";
    platforms = lib.platforms.unix;
    mainProgram = "testbed";
  };
}
