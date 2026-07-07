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

  patches = (oldAttrs.patches or [ ]) ++ [ ./obn.patch ];

  postPatch = (oldAttrs.postPatch or "") + ''
    substituteInPlace src/slic3r/Utils/NetworkAgent.cpp \
      --replace-fail "@obn_plugin_path@" "${obn}/lib/libbambu_networking.so" \
      --replace-fail "@obn_bambu_source_path@" "${obn}/lib/libBambuSource.so"

    # Skip the plugin installation prompt in the setup wizard
    substituteInPlace src/slic3r/GUI/WebGuideDialog.cpp \
      --replace-fail 'wxGetApp().app_config->get("app","installed_networking")' '"1"'
  '';

  meta = oldAttrs.meta // {
    description = "Bambu Studio with open-bamboo-networking (FOSS networking plugin)";
    license = lib.licenses.agpl3Plus;
    maintainers = [ ];
  };
})
