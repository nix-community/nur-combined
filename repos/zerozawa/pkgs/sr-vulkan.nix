{
  lib,
  python3Packages,
  fetchPypi,
  vulkan-loader,
  autoPatchelfHook,
  sr-vulkan-models ? [],
  ...
}:

python3Packages.buildPythonPackage rec {
  pname = "sr-vulkan";
  version = "2.0.1.1";
  format = "wheel";

  src = fetchPypi {
    pname = "sr_vulkan";
    inherit version;
    hash = "sha256-oA+miP10IRoYewD6g/Baxq1l7J6IQmNhjwbq+TWX04M=";
    format = "wheel";
    dist = "cp37";
    python = "cp37";
    abi = "abi3";
    platform = "manylinux_2_17_x86_64";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  propagatedBuildInputs = [ vulkan-loader ];

  postInstall = lib.optionalString (sr-vulkan-models != []) ''
    # Create symlinks to model packages in sr_vulkan's site-packages
    # so the binary can find them at ../sr_vulkan_model_*/models/
    for site_packages in $out/lib/python*/site-packages; do
      if [ -d "$site_packages/sr_vulkan" ]; then
        for model in ${toString sr-vulkan-models}; do
          for model_path in $model/lib/python*/site-packages/sr_vulkan_model_*; do
            if [ -d "$model_path" ]; then
              ln -s "$model_path" "$site_packages/"
            fi
          done
        done
      fi
    done
  '';

  meta = with lib; {
    description = "A super resolution python tool using Vulkan";
    homepage = "https://github.com/tonquer/waifu2x-vulkan";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
  };
}
