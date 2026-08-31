{ buildJosmPlugin
, lib
, runCommand
}:

let
  inherit (builtins) toFile;
  inherit (lib) escapeShellArg licenses replaceString;
in
buildJosmPlugin (josm-select-sequential:
let
  namespace = "im.kvalhe.andrew.josm.select_sequential";
  class = "SelectSequentialPlugin";
  buildfile = toFile "${josm-select-sequential.pname}-buildfile" ''
    <?xml version="1.0" encoding="utf-8"?>
    <project name="select_sequential" default="dist" basedir=".">
      <property name="plugin.version" value="${josm-select-sequential.version}"/>
      <property name="plugin.description" value="Select nodes sequentially"/>
      <property name="plugin.main.version" value="19613"/>
      <property name="plugin.class" value="${namespace}.${class}"/>
      <property name="plugin.requires" value="apache-commons"/>

      <import file="../build-common.xml"/>

      <fileset id="plugin.requires.jars" dir="''${plugin.dist.dir}">
        <include name="apache-commons.jar"/>
      </fileset>
    </project>
  '';
in
{
  pname = "josm-select-sequential";
  version = "0.0.0";
  meta.license = licenses.gpl3;

  src = runCommand "${josm-select-sequential.pname}-source" { } ''
    plugin_dir="$out/src/"${escapeShellArg ( replaceString "." "/" namespace)}
    mkdir --parents "$plugin_dir"

    cp ${buildfile} "$out/build.xml"
    cp ${./assets/josm-select-sequential.java} "$plugin_dir/"${escapeShellArg class}'.java'
  '';

  pluginName = "select_sequential";
})
