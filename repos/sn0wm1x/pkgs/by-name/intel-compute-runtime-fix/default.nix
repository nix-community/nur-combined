{ intel-compute-runtime }:
intel-compute-runtime.overrideAttrs (old: {
  pname = "intel-compute-runtime-fix";
  preferLocalBuild = true;

  postInstall = ''
    # Avoid clash with intel-ocl
    mv $out/etc/OpenCL/vendors/intel.icd $out/etc/OpenCL/vendors/intel-neo.icd

    mkdir -p $drivers/lib
    # fix mv command
    # mv -t $drivers/lib $out/lib/libze_intel*
    mv $drivers/lib $out/lib/
  '';
})
