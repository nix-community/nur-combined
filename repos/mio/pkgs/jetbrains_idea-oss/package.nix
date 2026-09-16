{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  callPackage,
  jetbrains,
  kotlin,
  jdk25,
  path,
}:

let
  inherit (lib)
    concatStringsSep
    escapeShellArg
    filter
    hasSuffix
    ;

  version = "2026.2.2";
  buildNumber = "262.10315.125";

  kotlinDistVersion = "2.4.20-ij262-52";
  kotlinIdeOldVersion = "2.3.20";

  composeCompilerPlugin = fetchurl {
    url = "https://repo1.maven.org/maven2/org/jetbrains/kotlin/kotlin-compose-compiler-plugin/2.4.0/kotlin-compose-compiler-plugin-2.4.0.jar";
    hash = "sha256-9bN4dvo6XS0n7/L+0xidsOzh9Ufz6cY1tJ+WnmMdFcE=";
  };

  kotlinDist = stdenvNoCC.mkDerivation {
    pname = "kotlin-dist-for-ide";
    version = kotlinDistVersion;

    src = fetchurl {
      url = "https://cache-redirector.jetbrains.com/intellij-dependencies/org/jetbrains/kotlin/kotlin-dist-for-ide/${kotlinDistVersion}/kotlin-dist-for-ide-${kotlinDistVersion}.jar";
      hash = "sha256-F2E04Gc/wCTn5wWI5boTa5UNDFpZqAV1jgC7d18SPrQ=";
    };

    nativeBuildInputs = [ unzip ];

    dontUnpack = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      unzip -q $src -d $out
      runHook postInstall
    '';
  };

  # Recreate the kotlin override used by nixpkgs' JPS builder so we can
  # substitute its store path with substituteInPlace --replace-fail.
  kotlinNixpkgs = kotlin.overrideAttrs (oldAttrs: {
    version = "2.2.20";
    src = fetchurl {
      url = oldAttrs.src.url;
      hash = "sha256-gfAmTJBztcu9s/+EGM8sXawHaHn8FW+hpkYvWlrMRCA=";
    };
  });

  # JPS builder from nixpkgs (idea-oss still uses this on unstable; Bazel is not merged yet).
  # 2026.2 needs JDK 25; the builder still looks up jetbrains.jdk-no-jcef-21.
  mkJetBrainsSource = callPackage "${path}/pkgs/applications/editors/jetbrains/source/build.nix" {
    jetbrains = jetbrains // {
      jdk-no-jcef-21 = jdk25;
    };
  };

  jpsBootstrapJavaFlags = [
    "--add-exports java.base/sun.nio.ch=ALL-UNNAMED"
    "--add-exports java.base/jdk.internal.ref=ALL-UNNAMED"
    "--add-opens java.base/jdk.internal.ref=ALL-UNNAMED"
    "--add-opens java.base/java.util=ALL-UNNAMED"
    "--add-opens java.base/java.lang=ALL-UNNAMED"
    "--add-opens java.base/sun.nio.ch=ALL-UNNAMED"
  ];

  bumpKotlinIdeArtifacts = ''
    find . -type f -name '*.xml' -exec sed -i \
      -e "s|2.4.20-ij262-52|${kotlinDistVersion}|g" \
      {} +
    for artefact in kotlin-dist-for-ide kotlin-jps-plugin-classpath kotlin-jps-plugin-tests-for-ide; do
      find . -type f -name '*.xml' -exec sed -i \
        -e "s|''${artefact}:${kotlinIdeOldVersion}|''${artefact}:${kotlinDistVersion}|g" \
        -e "s|''${artefact}/${kotlinIdeOldVersion}|''${artefact}/${kotlinDistVersion}|g" \
        -e "s|''${artefact}-${kotlinIdeOldVersion}|''${artefact}-${kotlinDistVersion}|g" \
        {} +
    done
  '';

  patchJpsBootstrap =
    drv:
    drv.overrideAttrs (oldJps: {
      patches = (oldJps.patches or [ ]) ++ [ ./jps-bootstrap.patch ];

      postPatch = ''
        substituteInPlace src/main/java/org/jetbrains/jpsBootstrap/KotlinCompiler.kt \
          --replace-fail 'KOTLIN_PATH_HERE' '${kotlinDist}'
        ${bumpKotlinIdeArtifacts}
      '';

      # Flags must be JVM options (before the main class), not wrapper args.
      postFixup = (oldJps.postFixup or "") + ''
        substituteInPlace $out/bin/jps-bootstrap \
          --replace-fail '-cp ' '${concatStringsSep " " jpsBootstrapJavaFlags} -cp '
      '';
    });

  src =
    (mkJetBrainsSource {
      inherit version buildNumber;
      buildType = "idea";
      ideaHash = "sha256-xu6T4+2D010fpb2N3Z07RW0lZeIfbD5Lh2FHv/biGQI=";
      androidHash = "sha256-29qwKTbhFrMTDzcCikzqsc6SEKmKXTwNaf8aSMt/FPg=";
      jpsHash = "sha256-nxjoLBpiHYzeYwgjbCSSjTFQTFOtBJTqz1VkmPzXijs=";
      restarterHash = "sha256-acCmC58URd6p9uKZrm0qWgdZkqu9yqCs23v8qgxV2Ag=";
      mvnDeps = ./idea_maven_artefacts.json;
      kotlin-jps-plugin = {
        version = kotlinDistVersion;
        hash = "sha256-7IkUiYHLMeSjNxIhbbCeq8SMgqzwwBkz1Sy4sj1vpvk=";
      };

      repositories = [
        "repo1.maven.org/maven2"
        "packages.jetbrains.team/maven/p/ij/intellij-dependencies"
        "dl.google.com/dl/android/maven2"
        "download.jetbrains.com/teamcity-repository"
        "packages.jetbrains.team/maven/p/grazi/grazie-platform-public"
        "packages.jetbrains.team/maven/p/kpm/public"
        "packages.jetbrains.team/maven/p/ki/maven"
        "maven.pkg.jetbrains.space/public/p/compose/dev"
        "packages.jetbrains.team/maven/p/amper/amper"
        "packages.jetbrains.team/maven/p/kt/bootstrap"
      ];
    }).overrideAttrs
      (old: {
        patches = filter (p: !hasSuffix "no-download.patch" (toString p)) old.patches ++ [
          ./no-download-2026.2.patch
        ];

        nativeBuildInputs = map (
          input:
          if input != null && (input.pname or "") == "jps-bootstrap" then patchJpsBootstrap input else input
        ) old.nativeBuildInputs;

        postPatch = (old.postPatch or "") + ''
                    substituteInPlace \
                      platform/build-scripts/src/org/jetbrains/intellij/build/kotlin/KotlinCompilerDependencyDownloader.kt \
                      --replace-fail '${kotlinNixpkgs}' '${kotlinDist}'

                    # Ensure Maven doesn't try to download missing older versions of kotlin-jps-plugin-classpath
                    find . \( -name "*.iml" -o -name "*.xml" \) -print0 | xargs -0 sed -i 's/kotlin-jps-plugin-classpath:2.2.0/kotlin-jps-plugin-classpath:2.4.20-ij262-52/g'
                    find . \( -name "*.iml" -o -name "*.xml" \) -print0 | xargs -0 sed -i 's|kotlin-jps-plugin-classpath/2.2.0/kotlin-jps-plugin-classpath-2.2.0|kotlin-jps-plugin-classpath/2.4.20-ij262-52/kotlin-jps-plugin-classpath-2.4.20-ij262-52|g'
                    find . \( -name "*.iml" -o -name "*.xml" \) -print0 | xargs -0 sed -i 's/kotlin-jps-plugin-classpath:2.3.20/kotlin-jps-plugin-classpath:2.4.20-ij262-52/g'
                    find . \( -name "*.iml" -o -name "*.xml" \) -print0 | xargs -0 sed -i 's|kotlin-jps-plugin-classpath/2.3.20/kotlin-jps-plugin-classpath-2.3.20|kotlin-jps-plugin-classpath/2.4.20-ij262-52/kotlin-jps-plugin-classpath-2.4.20-ij262-52|g'
                    find . \( -name "*.iml" -o -name "*.xml" \) -print0 | xargs -0 sed -i '/<verification>/,/<\/verification>/d'

                    # Patch compose-compiler-plugin 2.4.0 to fix ABI incompatibilities with Kotlin 2.4.20-ij262-52
                    cp ${composeCompilerPlugin} compose-compiler-plugin.jar
                    chmod +w compose-compiler-plugin.jar
                    
                    # Fix compilation of buildScripts.bazel due to API changes in Kotlin 2.4 compiler CLI arguments
                    sed -i '/argumentWithoutValue/,+2d' platform/build-scripts/bazel/src/org/jetbrains/intellij/build/bazel/BazelBuildFileGenerator.kt
                    sed -i '/booleanArgumentWithValue/,+2d' platform/build-scripts/bazel/src/org/jetbrains/intellij/build/bazel/BazelBuildFileGenerator.kt
                    mkdir compose-patch
                    cd compose-patch
                    jar xf ../compose-compiler-plugin.jar
                    
                    # Create Fix.java
                    cat << 'EOF' > androidx/compose/compiler/plugins/kotlin/Fix.java
                    package androidx.compose.compiler.plugins.kotlin;
                    import org.jetbrains.kotlin.ir.declarations.IrClass;
                    import org.jetbrains.kotlin.ir.types.IrSimpleType;
                    import org.jetbrains.kotlin.ir.util.InlineClassesKt;
                    public class Fix {
                        public static IrSimpleType getInlineClassUnderlyingType(IrClass c) {
                            return InlineClassesKt.getInlineClassUnderlyingType(c, false);
                        }
                    }
          EOF
                    # Create FixIrDecla__.java
                    cat << 'EOF' > androidx/compose/compiler/plugins/kotlin/FixIrDecla__.java
                    package androidx.compose.compiler.plugins.kotlin;
                    import org.jetbrains.kotlin.ir.declarations.IrClass;
                    import org.jetbrains.kotlin.ir.declarations.IrFile;
                    import org.jetbrains.kotlin.descriptors.InlineClassRepresentation;
                    import org.jetbrains.kotlin.ir.declarations.IrDeclarationsKt;
                    import org.jetbrains.kotlin.ir.declarations.IrFactory;
                    import org.jetbrains.kotlin.ir.declarations.IrDeclarationOrigin;
                    import org.jetbrains.kotlin.name.Name;
                    import org.jetbrains.kotlin.descriptors.DescriptorVisibility;
                    import org.jetbrains.kotlin.ir.types.IrType;
                    import org.jetbrains.kotlin.descriptors.Modality;
                    import org.jetbrains.kotlin.ir.symbols.IrSimpleFunctionSymbol;
                    import org.jetbrains.kotlin.serialization.deserialization.descriptors.DeserializedContainerSource;
                    import org.jetbrains.kotlin.ir.declarations.IrSimpleFunction;
                    import org.jetbrains.kotlin.ir.symbols.IrClassSymbol;
                    
                    public class FixIrDecla__ {
                        public static InlineClassRepresentation getInlineClassRepresentation(IrClass c) {
                            return IrDeclarationsKt.inlineClassRepresentation(c, false);
                        }
                        public static String getName(IrFile f) {
                            return IrDeclarationsKt.getName(f);
                        }
                        public static void copyAttributes_default(org.jetbrains.kotlin.ir.IrElement a, org.jetbrains.kotlin.ir.IrElement b, boolean c, int d, java.lang.Object e) {
                            if ((d & 2) != 0) { c = false; }
                            IrDeclarationsKt.copyAttributes(a, b, c);
                        }
                        public static IrSimpleFunction createSimpleFunction_default(
                            IrFactory factory, int startOffset, int endOffset, IrDeclarationOrigin origin, Name name,
                            DescriptorVisibility visibility, boolean isInline, boolean isExpect, IrType returnType,
                            Modality modality, IrSimpleFunctionSymbol symbol, boolean isTailrec, boolean isSuspend,
                            boolean isOperator, boolean isInfix, boolean isExternal, DeserializedContainerSource containerSource,
                            boolean isFakeOverride, int old_bitmask, Object marker
                        ) {
                            int new_bitmask = old_bitmask | (1 << 17);
                            return createSimpleFunction_new(
                                factory, startOffset, endOffset, origin, name, visibility, isInline, isExpect, returnType,
                                modality, symbol, isTailrec, isSuspend, isOperator, isInfix, isExternal, containerSource,
                                isFakeOverride, null, new_bitmask, marker
                            );
                        }
                        public static IrSimpleFunction createSimpleFunction_new(
                            IrFactory factory, int startOffset, int endOffset, IrDeclarationOrigin origin, Name name,
                            DescriptorVisibility visibility, boolean isInline, boolean isExpect, IrType returnType,
                            Modality modality, IrSimpleFunctionSymbol symbol, boolean isTailrec, boolean isSuspend,
                            boolean isOperator, boolean isInfix, boolean isExternal, DeserializedContainerSource containerSource,
                            boolean isFakeOverride, IrClassSymbol irClassSymbol, int new_bitmask, Object marker
                        ) {
                            return null;
                        }
                    }
          EOF
                    # Compile adapters
                    javac -cp ${kotlinDist}/lib/kotlin-compiler.jar androidx/compose/compiler/plugins/kotlin/Fix.java androidx/compose/compiler/plugins/kotlin/FixIrDecla__.java
                    rm androidx/compose/compiler/plugins/kotlin/Fix.java androidx/compose/compiler/plugins/kotlin/FixIrDecla__.java
                    
                    # Create and compile robust ASM Patcher
                    cat << 'EOF' > Patch.java
                    import org.jetbrains.org.objectweb.asm.*;
                    import org.jetbrains.org.objectweb.asm.tree.*;
                    import java.io.*;
                    public class Patch {
                        public static void main(String[] args) throws Exception {
                            for(String arg : args) {
                                File f = new File(arg);
                                if (!f.isFile() || !arg.endsWith(".class")) continue;
                                byte[] data = new byte[(int)f.length()];
                                new FileInputStream(f).read(data);
                                ClassReader cr = new ClassReader(data);
                                ClassNode cn = new ClassNode();
                                cr.accept(cn, 0);
                                boolean changed = false;
                                if (cn.name.equals("androidx/compose/compiler/plugins/kotlin/FixIrDecla__")) {
                                    for(MethodNode mn : cn.methods) {
                                        if (mn.name.equals("createSimpleFunction_default")) {
                                            mn.name = "createSimpleFunction$default";
                                            changed = true;
                                            for(AbstractInsnNode insn : mn.instructions) {
                                                if (insn instanceof MethodInsnNode) {
                                                    MethodInsnNode min = (MethodInsnNode)insn;
                                                    if (min.name.equals("createSimpleFunction_new")) {
                                                        min.name = "createSimpleFunction$default";
                                                        min.owner = "org/jetbrains/kotlin/ir/declarations/IrFactory";
                                                        min.desc = "(Lorg/jetbrains/kotlin/ir/declarations/IrFactory;IILorg/jetbrains/kotlin/ir/declarations/IrDeclarationOrigin;Lorg/jetbrains/kotlin/name/Name;Lorg/jetbrains/kotlin/descriptors/DescriptorVisibility;ZZLorg/jetbrains/kotlin/ir/types/IrType;Lorg/jetbrains/kotlin/descriptors/Modality;Lorg/jetbrains/kotlin/ir/symbols/IrSimpleFunctionSymbol;ZZZZZLorg/jetbrains/kotlin/serialization/deserialization/descriptors/DeserializedContainerSource;ZLorg/jetbrains/kotlin/ir/symbols/IrClassSymbol;ILjava/lang/Object;)Lorg/jetbrains/kotlin/ir/declarations/IrSimpleFunction;";
                                                    }
                                                }
                                            }
                                        }
                                        if (mn.name.equals("copyAttributes_default")) {
                                            mn.name = "copyAttributes$default";
                                            changed = true;
                                        }
                                    }
                                } else if (cn.name.equals("androidx/compose/compiler/plugins/kotlin/Fix")) {
                                    // Do not patch calls inside the Fix adapter itself!
                                } else {
                                    for(MethodNode mn : cn.methods) {
                                        for(AbstractInsnNode insn : mn.instructions) {
                                            if (insn instanceof MethodInsnNode) {
                                                MethodInsnNode min = (MethodInsnNode)insn;
                                                if (min.owner.equals("org/jetbrains/kotlin/ir/util/InlineClassesKt")) {
                                                    min.owner = "androidx/compose/compiler/plugins/kotlin/Fix";
                                                    changed = true;
                                                }
                                                if (min.owner.equals("org/jetbrains/kotlin/ir/declarations/IrDeclarationsKt")) {
                                                    min.owner = "androidx/compose/compiler/plugins/kotlin/FixIrDecla__";
                                                    changed = true;
                                                }
                                                if (min.owner.equals("org/jetbrains/kotlin/ir/declarations/IrFactory") && min.name.equals("createSimpleFunction$default")) {
                                                    min.owner = "androidx/compose/compiler/plugins/kotlin/FixIrDecla__";
                                                    changed = true;
                                                }
                                            }
                                        }
                                    }
                                }
                                if (changed) {
                                    ClassWriter cw = new ClassWriter(0);
                                    cn.accept(cw);
                                    FileOutputStream fos = new FileOutputStream(arg);
                                    fos.write(cw.toByteArray());
                                    fos.close();
                                }
                            }
                        }
                    }
          EOF
                    javac -cp ${kotlinDist}/lib/kotlin-compiler.jar Patch.java
                    find . -name "*.class" -exec java -cp ${kotlinDist}/lib/kotlin-compiler.jar:. Patch {} +
                    rm Patch.java Patch.class
                    
                    # Repack JAR
                    jar cMf ../compose-compiler-plugin.jar .
                    cd ..
                    
                    export COMPOSE_COMPILER_PLUGIN="$PWD/compose-compiler-plugin.jar"
                    export KOTLIN_IDE_NEW=${escapeShellArg kotlinDistVersion}
                    ${bumpKotlinIdeArtifacts}
                    # source (not bash) so stdenv's substituteInPlace is in scope
                    (
                      set -euo pipefail
                      source ${./fix-kotlin-compile.sh}
                    )
        '';

        configurePhase = ''
          runHook preConfigure

          cp -r "$repo"/.m2 ../.m2
          chmod -R +w ../.m2

          export JPS_BOOTSTRAP_COMMUNITY_HOME="$PWD"
          jps-bootstrap \
            -Dorg.jetbrains.jps.incremental.dependencies.resolution.sha256.checksum.ignored=true \
            -Dbuild.number=${buildNumber} \
            -Djps.kotlin.home=${kotlinDist} \
            -Dintellij.build.target.os=linux \
            -Dintellij.build.target.arch=x64 \
            -Dintellij.build.skip.build.steps=mac_artifacts,mac_dmg,mac_sit,windows_exe_installer,windows_sign,repair_utility_bundle_step,sources_archive \
            -Dintellij.build.unix.snaps=false \
            --java-argfile-target=java_argfile \
            "$PWD" \
            intellij.idea.community.build \
            OpenSourceCommunityInstallersBuildTarget

          runHook postConfigure
        '';

        buildPhase = ''
          runHook preBuild
          java -Dorg.jetbrains.jps.incremental.dependencies.resolution.sha256.checksum.ignored=true -Djps.kotlin.home=${kotlinDist} -Dkotlin.compiler.execution.strategy=in-process "@java_argfile"
          runHook postBuild
        '';
      });

in
jetbrains.idea-oss.overrideAttrs (
  old:
  {
    inherit src;
    inherit (src)
      version
      buildNumber
      libdbm
      ;
    # nixpkgs marks the older idea-oss as vulnerable; this is a newer source build.
    meta = (old.meta or { }) // {
      knownVulnerabilities = [ ];
    };
  }
  // lib.optionalAttrs (src ? fsnotifier) {
    inherit (src) fsnotifier;
  }
)
