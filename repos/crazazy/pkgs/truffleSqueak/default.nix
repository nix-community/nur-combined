{ graalvmCEPackages, runCommand, unzip, zip, fetchzip, fetchurl, SDL2, autoPatchelfHook }:
let
  inherit (graalvmCEPackages) buildGraalvmProduct graalvm17-ce-full;
  version = "22.3.0";
  image = fetchzip {
    url = "https://github.com/hpi-swa/trufflesqueak/releases/download/22.3.0/TruffleSqueakImage-22.3.0.zip";
    sha256 = "1vj86qihl3y9kq9lnqlxia849rxr7jb13rbkjzpbx2axwv5jsn0i";
    stripRoot = false;
  };
  jar = fetchurl {
    url = "https://github.com/hpi-swa/trufflesqueak/releases/download/22.3.0/trufflesqueak-installable-java17-linux-amd64-22.3.0.jar";
    sha256 = "13dd3k496andj0kmxh6sy7xlnv6bj5v020zrndvwydj535vjf50d";
  };
  combined = runCommand "truffle.jar" {} ''
${unzip}/bin/unzip -d . ${jar}
echo "languages/smalltalk/resources/TruffleSqueak-${version}.changes = rw-rw-r--" >> META-INF/permissions
echo "languages/smalltalk/resources/TruffleSqueak-${version}.image = rw-r--r--" >> META-INF/permissions
echo "languages/smalltalk/resources/SqeaukV50.sources = rw-r--r--" >> META-INF/permissions
mkdir -p languages/smalltalk/resources
cp ${image}/* languages/smalltalk/resources
${zip}/bin/zip $out . -r

'';
  truffleSqueak = buildGraalvmProduct rec {
    name = product;
    product = "truffleSqueak";
    javaVersion = "17";
    src = jar; # this will be defunctional but it's the only way to make stuff compile
    extraBuildInputs = [ SDL2 autoPatchelfHook ];
    autoPatchelfIgnoreMissingDeps = true;
  };
in
graalvm17-ce-full.override {
  products = [truffleSqueak] ++ graalvm17-ce-full.products;
}
