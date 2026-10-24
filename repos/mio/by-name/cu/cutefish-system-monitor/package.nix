{
  mkCutefishDerivation,
  cutefish-toolkit,
  icu,
}:

mkCutefishDerivation {
  pname = "cutefish-system-monitor";

  postPatch = ''
    substituteInPlace src/gpureader.cpp \
      --replace-fail '{"/usr/share/misc/pci.ids", "/usr/share/hwdata/pci.ids"}' \
        '{"/run/current-system/sw/share/hwdata/pci.ids", "/usr/share/misc/pci.ids", "/usr/share/hwdata/pci.ids"}'
  '';

  extraBuildInputs = [
    cutefish-toolkit
    icu
  ];

  meta = {
    description = "System monitor for the Cutefish desktop";
    mainProgram = "cutefish-system-monitor";
  };
}
