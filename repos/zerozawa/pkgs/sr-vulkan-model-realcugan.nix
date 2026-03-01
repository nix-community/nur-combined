{
  lib,
  python3Packages,
  fetchurl,
  ...
}:
python3Packages.buildPythonPackage rec {
  pname = "sr-vulkan-model-realcugan";
  version = "1.0.1";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/d5/80/6b93121f57518acbb0302159611fe98601920b8afff95b4ea277c7b21e21/sr_vulkan_model_realcugan-${version}-py3-none-any.whl";
    hash = "sha256-r7QCYn2DIx5kK4gD3AhFZeHYxU5/oIr5JIZUMDLOddk=";
  };

  meta = with lib; {
    description = "sr_vulkan realcugan model";
    homepage = "https://github.com/tonquer/sr_vulkan";
    license = licenses.mit;
    platforms = platforms.all;
    sourceProvenance = with sourceTypes; [binaryBytecode];
  };
}
