import re

with open("by-name/je/jetbrains_idea-oss/package.nix", "r") as f:
    content = f.read()

target = """    nativeBuildInputs = pkgs.lib.forEach old.nativeBuildInputs (input:
      if input != null && (input.pname or "") == "jps-bootstrap" then
        input.overrideAttrs (oldJps: {
          patches = (oldJps.patches or []) ++ [ ./jps-bootstrap.patch ];
          postPatch = (oldJps.postPatch or "") + ''

            find . -type f -name "*.xml" -exec sed -i 's/kotlin-dist-for-ide:2.3.20/kotlin-dist-for-ide:2.4.0/g' {} +"""

replacement = """    nativeBuildInputs = pkgs.lib.forEach old.nativeBuildInputs (input:
      if input != null && (input.pname or "") == "jps-bootstrap" then
        let
          kotlin-dist = pkgs.stdenvNoCC.mkDerivation {
            name = "kotlin-dist-for-ide-2.4.0";
            src = pkgs.fetchurl {
              url = "https://cache-redirector.jetbrains.com/intellij-dependencies/org/jetbrains/kotlin/kotlin-dist-for-ide/2.4.0/kotlin-dist-for-ide-2.4.0.jar";
              hash = "sha256-0SuZblD+eyRaClBFusjAvVy8Inp5LkS0GwroDgQshJA=";
            };
            nativeBuildInputs = [ pkgs.unzip ];
            dontUnpack = true;
            installPhase = ''
              mkdir -p $out
              unzip -q $src -d $out
            '';
          };
        in
        input.overrideAttrs (oldJps: {
          patches = (oldJps.patches or []) ++ [ ./jps-bootstrap.patch ];
          postPatch = ''
            sed -i 's|KOTLIN_PATH_HERE|${kotlin-dist}|' src/main/java/org/jetbrains/jpsBootstrap/KotlinCompiler.kt
            
            find . -type f -name "*.xml" -exec sed -i 's/kotlin-dist-for-ide:2.3.20/kotlin-dist-for-ide:2.4.0/g' {} +"""

if target in content:
    content = content.replace(target, replacement)
    with open("by-name/je/jetbrains_idea-oss/package.nix", "w") as f:
        f.write(content)
    print("Success")
else:
    print("Target not found")
