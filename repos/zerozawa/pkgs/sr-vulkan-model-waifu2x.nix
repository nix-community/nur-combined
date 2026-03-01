{
  lib,
  python3Packages,
  fetchurl,
  ...
}:
python3Packages.buildPythonPackage rec {
  pname = "sr-vulkan-model-waifu2x";
  version = "1.0.1";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/75/cb/aefb05235c68b8a72444779d56505a5047692f2c13c497e8131c8f710f29/sr_vulkan_model_waifu2x-${version}-py3-none-any.whl";
    hash = "sha256-ZLU1/Jb/OSglU1kV7z8D5IILjBiqzoYaoNm0mwYoY0s=";
  };

  meta = with lib; {
    description = "sr_vulkan waifu2x model";
    homepage = "https://github.com/tonquer/sr_vulkan";
    license = licenses.mit;
    platforms = platforms.all;
    sourceProvenance = with sourceTypes; [binaryBytecode];
  };
}
