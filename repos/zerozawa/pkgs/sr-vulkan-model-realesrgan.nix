{
  lib,
  python3Packages,
  fetchurl,
  ...
}:
python3Packages.buildPythonPackage rec {
  pname = "sr-vulkan-model-realesrgan";
  version = "1.0.1";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/17/e0/8785f5833b06feb585634df9152450fd0272df12be001e34729f54f39ab6/sr_vulkan_model_realesrgan-${version}-py3-none-any.whl";
    hash = "sha256-QbzSrUlxhC3rYzIFYSgaW0Ju0jEg+NMOVUuSMuvwRAI=";
  };

  meta = with lib; {
    description = "sr_vulkan realesrgan model";
    homepage = "https://github.com/tonquer/sr_vulkan";
    license = licenses.mit;
    platforms = platforms.all;
    sourceProvenance = with sourceTypes; [binaryBytecode];
  };
}
