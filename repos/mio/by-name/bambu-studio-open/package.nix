{
  bambu-studio,
  open-bamboo-networking,
  lib,
}:

let
  bambuStudioVersion = bambu-studio.version;
  obnVersion =
    let
      parts = lib.splitString "." bambuStudioVersion;
      prefix = lib.concatStringsSep "." (lib.take 3 parts);
    in
    "${prefix}.99";

  obn = open-bamboo-networking.override {
    pluginVersion = obnVersion;
    client = "bambu_studio";
  };
in
bambu-studio.overrideAttrs (oldAttrs: {
  pname = "bambu-studio-open";

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs =
    (oldAttrs.nativeBuildInputs or [ ])
    ++ (lib.filter (p: (p.pname or p.name or "") == "wxwidgets") oldAttrs.buildInputs);

  # Note: When creating or modifying patches, make sure line numbers remain unchanged
  # so it's easier to compare with upstream. Pad with blank lines or comments if needed.
  patches = (oldAttrs.patches or [ ]) ++ [
    ./obn.patch
    ./skip-privacy.patch
  ];

  postPatch = (oldAttrs.postPatch or "") + ''
    substituteInPlace src/slic3r/Utils/NetworkAgent.cpp \
      --replace-fail "@obn_plugin_path@" "${obn}/lib/libbambu_networking.so" \
      --replace-fail "@obn_bambu_source_path@" "${obn}/lib/libBambuSource.so"
  '';

  meta = oldAttrs.meta // {
    description = "Bambu Studio with open-bamboo-networking (FOSS networking plugin)";
    license = lib.licenses.agpl3Plus;
    maintainers = [ ];
  };
})
