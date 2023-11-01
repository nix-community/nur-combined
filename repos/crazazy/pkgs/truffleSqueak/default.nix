{ nvsrcs, graalvmCEPackages, runCommand, unzip, zip, fetchzip, SDL2, autoPatchelfHook }:
let
  inherit (graalvmCEPackages) buildGraalvmProduct graalvm17-ce-full;
  inherit (nvsrcs.trufflesqueak) version;
  image = nvsrcs.trufflesqueak-image.src;
  jar = nvsrcs.trufflesqueak.src;
  combined = runCommand "truffle.jar" {} ''
${unzip}/bin/unzip -d . ${jar}
echo "languages/smalltalk/resources/TruffleSqueak-${version}.changes = rw-rw-r--" >> META-INF/permissions
echo "languages/smalltalk/resources/TruffleSqueak-${version}.image = rw-r--r--" >> META-INF/permissions
echo "languages/smalltalk/resources/SqeaukV50.sources = rw-r--r--" >> META-INF/permissions
mkdir -p languages/smalltalk/resources
${unzip}/bin/unzip -d languages/smalltalk/resources ${image}
${zip}/bin/zip $out . -r

'';
  truffleSqueak = buildGraalvmProduct rec {
    name = product;
    product = "truffleSqueak";
    inherit (nvsrcs.trufflesqueak) version src;
    extraBuildInputs = [ SDL2 autoPatchelfHook ];
    autoPatchelfIgnoreMissingDeps = true;
  };
in truffleSqueak
/*
graalvm17-ce-full.override {
  products = [truffleSqueak] ++ graalvm17-ce-full.products;
}
*/
