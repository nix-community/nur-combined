{ lib }:
{ pname, dirSubmodules, fileSubmodules }:

let
  moduleNames = dirSubmodules ++ fileSubmodules;

  submoduleFilesList = map (x: "${x}.py") fileSubmodules;
  submoduleDirsList = map (x: "${x}/") dirSubmodules;

  submoduleFiles = lib.concatStringsSep " " (map (x: ''"${x}"'') submoduleFilesList);
  submoduleDirs = lib.concatStringsSep " " (map (x: ''"${x}"'') submoduleDirsList);
  submoduleRegex = lib.concatStringsSep ''\|'' (map (x: ''\b${x}\b'') moduleNames);
in
{
  /* Unusuable as is, but keeping for future thougth:
   *
   * -e 's/^\(\s*\)import\s*\(${submoduleRegex}\(\.[[:alnum:]_]\+\)*\)\.\([[:alnum:]_]\+\)\s*$/\1from ${pname}.\2 import \4/'
   * would convert "import networks.a.b.c.pe_relu" into "from networks.a.b.c import pe_relu"
   *
   * -e 's/^\(\s*\)import\s*\(${submoduleRegex}\)\s*$/\1from ${pname} import \2/' \
   */
  sed = ''
    find -iname '*.py' -exec \
      sed -i \
        -e 's/^\(\s*\)import\s\+\(${submoduleRegex}\)$/from ${pname} import \2/' \
        -e 's/^\(\(\s*\)import\s*\(${submoduleRegex}\)\(\.[[:alnum:]_]\+\)\(\(\.[[:alnum:]_]\+\)*\)\s*\)$/\2from ${pname} import \3\n\2import ${pname}.\3\4\n/' \
        -e 's/^\(\s*\)from\s\+\(${submoduleRegex}\)/\1from ${pname}.\2/' \
        -e 's/^\(\s*import.*[,[:space:]]\)\(${submoduleRegex}\)\([,[:space:]].*\)$/\1${pname}.\2\3/' \
        '{}' '+'
  '';
  mv = ''
    mkdir src/${pname} -p
    mv ${submoduleFiles} ${submoduleDirs} \
      src/${pname}/
  '';
}
