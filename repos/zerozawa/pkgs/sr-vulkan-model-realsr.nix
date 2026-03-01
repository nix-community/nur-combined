{
  lib,
  python3Packages,
  fetchurl,
  ...
}:
python3Packages.buildPythonPackage rec {
  pname = "sr-vulkan-model-realsr";
  version = "1.0.1";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/da/e3/1506620e4102ac5b864db4dec3a3233e011349707c6fc57d9c7978eddbd7/sr_vulkan_model_realsr-${version}-py3-none-any.whl";
    hash = "sha256-lY/MmPnHqJFSGWe7dnT70JgsPHlV3PMMtW5B4cGXHNg=";
  };

  meta = with lib; {
    description = "sr_vulkan realsr model";
    homepage = "https://github.com/tonquer/sr_vulkan";
    license = licenses.mit;
    platforms = platforms.all;
    sourceProvenance = with sourceTypes; [binaryBytecode];
  };
}
