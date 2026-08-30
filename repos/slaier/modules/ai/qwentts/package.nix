{
  lib,
  stdenv,
  git,
  cmake,
  fetchFromGitHub,
  patchelf,

  lame,
  shaderc,
  vulkan-headers,
  vulkan-loader,
  vulkanSupport ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qwentts-cpp";
  version = "0";

  src = fetchFromGitHub {
    owner = "ServeurpersoCom";
    repo = "qwentts.cpp";
    rev = "a8a7716b530e49fed537c57711247c12fbbb903c";
    hash = "sha256-glWhPG1bKBaMOL8nDtrnBBuuQoiVSQ0r13jbZszQA60=";
    fetchSubmodules = true;
  };

  patches = [
    ./0001-feat-tts-server-add-mp3-response-format-using-lame.patch
    ./0002-feat-tts-server-add-idle-sleep-and-lazy-model-loadin.patch
  ];

  nativeBuildInputs = [
    cmake
    git
    patchelf
  ];

  buildInputs = lib.optionals vulkanSupport [
    shaderc
    vulkan-headers
    vulkan-loader
  ];

  cmakeFlags = [
    (lib.cmakeBool "GGML_VULKAN" vulkanSupport)
    "-DCMAKE_INCLUDE_PATH=${lame}/include"
    "-DCMAKE_LIBRARY_PATH=${lame.lib}/lib"
  ];
  enableParallelBuilding = true;

  postInstall = ''
    mkdir -p $out/bin
    for bin in qwen-tts qwen-codec tts-server quantize; do
      if [ -f "$bin" ]; then
        cp -v "$bin" $out/bin/
        rpath=$(patchelf --print-rpath $out/bin/$bin 2>/dev/null || true)
        if [[ "$rpath" == *"/build"* ]]; then
          new_rpath=''${rpath//\/build/$out\/lib}
          patchelf --set-rpath "$new_rpath" $out/bin/$bin
        fi
      fi
    done
  '';

  meta = {
    description = "Local AI text-to-speech with named speakers, voice cloning and voice design, powered by GGML";
    homepage = "https://github.com/ServeurpersoCom/qwentts.cpp";
    mainProgram = "qwen-tts";
    license = lib.licenses.mit;
  };
})
