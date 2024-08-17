{ lib
, stdenv
, stdenvNoCC
, fetchurl
, autoPatchelfHook
, rpmextract
, ocl-icd
  # , onnxruntime
, zlib
}:
let
  major = "2024.2";
  minor = "1";
  rel = "1079";
in
stdenvNoCC.mkDerivation ({
  pname = "intel-oneapi-dpcpp-cpp";
  version = "${major}.${minor}.${rel}";
  preferLocalBuild = true;

  src = fetchurl
    {
      url = "https://yum.repos.intel.com/oneapi/intel-oneapi-dpcpp-cpp-${major}-${major}.${minor}-${rel}.x86_64.rpm";
      hash = "sha256-iWG1HiCFbJ86FBrTUkXVEUJFI4qnXMM3EYrwETRhYiM=";
    };

  nativeBuildInputs = [ autoPatchelfHook rpmextract ];

  buildInputs = [
    stdenv.cc.cc.lib
    ocl-icd
    # onnxruntime
    zlib
  ];

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir $out
    cd $out
    rpmextract $src

    ls $out

    mkdir $out/bin
    mv $out/opt/intel/oneapi/compiler/${major}/bin/* $out/bin/

    mkdir $out/lib
    mv $out/opt/intel/oneapi/compiler/${major}/lib/* $out/lib/

    # remove failed bin
    # error: auto-patchelf could not satisfy dependency libonnxruntime.1.12.22.721.so
    rm $out/bin/opencl-aot
    rm $out/bin/compiler/clang
    rm $out/bin/compiler/llvm-dwp

    rm -r $out/opt

    runHook postInstall
  '';

  meta = {
    broken = true;
    description = "Intel oneAPI DPC++/C++ Compiler";
    longDescription = "Standards driven high performance cross architecture DPC++/C++ compiler";
    homepage = "https://software.intel.com/content/www/us/en/develop/tools/oneapi.html";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.issl;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ kwaa ];
  };
})
