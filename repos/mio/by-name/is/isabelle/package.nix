{
  lib,
  stdenv,
  callPackage,
  fetchurl,
  fetchFromGitHub,
  coreutils,
  net-tools,
  openjdk25,
  scala_3,
  polyml,
  verit,
  vampire,
  eprover-ho,
  cvc5,
  csdp,
  rlwrap,
  perl,
  procps,
  makeDesktopItem,
  copyDesktopItems,
  desktopToDarwinBundle,
  electron,
  writableTmpDirAsHomeHook,
  patchelf,
}:

let
  java = openjdk25;

  patchelf' = patchelf.overrideAttrs (finalAttrs: {
    version = "0.15.2";
    src = fetchurl {
      url = "https://github.com/NixOS/patchelf/releases/download/${finalAttrs.version}/patchelf-${finalAttrs.version}.tar.bz2";
      hash = "sha256-F3RfVkFZyOIo/EEtplogSLhGxLa0Igt3y/IkFuAvLXw=";
    };
  });

  platforms = {
    x86_64-linux = "x86_64-linux";
    aarch64-linux = "arm64-linux";
    aarch64-darwin = "arm64-darwin";
  };

  platform = platforms.${stdenv.hostPlatform.system};
  buildIsDarwin = stdenv.hostPlatform.isDarwin;

  polyml' = polyml.overrideAttrs (
    old:
    {
      pname = "polyml-for-isabelle";
      version = "2026";
      src = fetchFromGitHub {
        owner = "polyml";
        repo = "polyml";
        rev = "ccd3e3717f7238b9b5d295fea4b5426182dfc0b6";
        hash = "sha256-wYW8aSvXzhW3hCDeorkD59j+1S6smzsFXHuPYeqo7z8=";
      };
      configureFlags = [
        "--enable-intinf-as-int"
        "--with-gmp"
        "--disable-shared"
      ];
      buildFlags = [ "compiler" ];
      postInstall = ''
        echo "ba433f9b-1286-450a-afb6-53f49be54d33" > $out/bin/poly.uuid
      '';
    }
    // lib.optionalAttrs buildIsDarwin {
      # Poly/ML's upstream tests open loopback and Unix-domain sockets.
      __noChroot = true;
    }
  );

  verit' = verit.overrideAttrs (finalAttrs: {
    version = "2026.05";
    src = fetchurl {
      url = "https://www.verit-solver.org/download/2026.05/verit-2026.05.tar.gz";
      hash = "sha256-wNN1S1mdAsBENZBkDs770t31YDt63Nj737MbhOWcwvE=";
    };
  });

  vampire' = vampire.override { enableZ3 = false; };

  cvc5' = cvc5.overrideAttrs (_: {
    version = "1.3.4";
    src = fetchFromGitHub {
      owner = "cvc5";
      repo = "cvc5";
      tag = "cvc5-1.3.4";
      hash = "sha256-PZcOArSTyJzyd2DKT8K0aFC4RlVXgTCnkoU0f08KPfY=";
    };
  });

  copiedPermissionsPatch = fetchurl {
    url = "https://raw.githubusercontent.com/sempiternal-aurora/nixpkgs/30b07b7e68d352cc26eb51d6b2cf402845b16e77/pkgs/by-name/is/isabelleComponents/fix-copied-permissions.patch";
    hash = "sha256-+9tD23E8MUziWJ6omTSugB/1DWLHnDB6zjDTc+1GUkY=";
  };
in
stdenv.mkDerivation (
  finalAttrs:
  ({
    pname = "isabelle";
    version = "2026";
    dirname = "Isabelle${finalAttrs.version}";

    src =
      if stdenv.hostPlatform.isDarwin then
        fetchurl {
          url = "https://isabelle.in.tum.de/website-${finalAttrs.dirname}/dist/${finalAttrs.dirname}_macos_arm.tar.gz";
          hash = "sha256-ckTlltRO6fu4uYjvKZBHSzOF+kp+wTQ4Z7IkoTtt3Cg=";
        }
      else if stdenv.hostPlatform.isx86 then
        fetchurl {
          url = "https://isabelle.in.tum.de/website-${finalAttrs.dirname}/dist/${finalAttrs.dirname}_linux.tar.gz";
          hash = "sha256-hYyZWzIhazh2vzlcO+hDFH0fHu5AS8bJWNdTTuM15I0=";
        }
      else
        fetchurl {
          url = "https://isabelle.in.tum.de/website-${finalAttrs.dirname}/dist/${finalAttrs.dirname}_linux_arm.tar.gz";
          hash = "sha256-7fsWcNi9+kJIiCnKA3nCGbh0oedUg0DJlR/9IlDaWn8=";
        };

    nativeBuildInputs = [
      patchelf'
      java
      copyDesktopItems
      writableTmpDirAsHomeHook
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ desktopToDarwinBundle ];

    buildInputs = [
      polyml'
      verit'
      vampire'
      eprover-ho
      net-tools
      cvc5'
      csdp
    ];

    patches = [ copiedPermissionsPatch ];
    propagatedBuildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ procps ];
    sourceRoot = "${finalAttrs.dirname}${lib.optionalString stdenv.hostPlatform.isDarwin ".app"}";
    doCheck = stdenv.hostPlatform.isx86_64;
    checkPhase = "bin/isabelle build -v HOL-SMT_Examples";

    postUnpack = lib.optionalString stdenv.hostPlatform.isDarwin ''
      mv $sourceRoot ${finalAttrs.dirname}
      sourceRoot=${finalAttrs.dirname}
    '';

    postPatch = ''
      patchShebangs lib/Tools/ bin/

      substituteInPlace src/Pure/ML/ml_settings.scala \
        --replace-fail 'polyml_home + Path.basic(ml_platform)' 'Path.explode("${polyml'}/bin")'

      cat >contrib/verit-*/etc/settings <<EOF
      ISABELLE_VERIT=${verit'}/bin/veriT
      EOF

      cat >contrib/e-*/etc/settings <<EOF
        E_HOME=${eprover-ho}/bin
        E_VERSION=${eprover-ho.version}
      EOF

      cat >contrib/vampire-*/etc/settings <<EOF
        VAMPIRE_HOME=${vampire'}/bin
        VAMPIRE_VERSION=${vampire'.version}
        VAMPIRE_EXTRA_OPTIONS="--mode casc"
      EOF

      cat >contrib/cvc5-*/etc/settings <<EOF
        CVC5_HOME=${cvc5'}
        CVC5_VERSION=${cvc5'.version}
        CVC5_SOLVER=${cvc5'}/bin/cvc5
        CVC5_INSTALLED=yes
      EOF

      cat >contrib/csdp-*/etc/settings <<EOF
        ISABELLE_CSDP=${csdp}/bin/csdp
      EOF

      cat >contrib/polyml-*/etc/settings <<EOF
        ML_SYSTEM_64=true
        ML_SYSTEM=${polyml'.name}
        ML_PLATFORM=${stdenv.system}
        ML_OPTIONS="--minheap 1000"
        POLYML_HOME="\$COMPONENT"
        ML_SOURCES="\$POLYML_HOME/src"
      EOF

      cat >contrib/jdk*/etc/settings <<EOF
        ISABELLE_JAVA_PLATFORM=${stdenv.system}
        ISABELLE_JDK_HOME=${java}
      EOF

      echo ISABELLE_LINE_EDITOR=${rlwrap}/bin/rlwrap >>etc/settings

      for comp in contrib/jdk* contrib/polyml-* contrib/verit-* contrib/vampire-* \
                  contrib/e-* contrib/cvc5-* contrib/csdp-*; do
        rm -rf $comp/${if stdenv.hostPlatform.isx86 then "x86" else "arm"}*
      done
      rm -rf contrib/*/src

      substituteInPlace lib/Tools/env \
        --replace-fail /usr/bin/env ${coreutils}/bin/env

      substituteInPlace src/Tools/Setup/src/Environment.java \
        --replace-fail 'cmd.add("/usr/bin/env");' "" \
        --replace-fail 'cmd.add("bash");' "cmd.add(\"$SHELL\");"

      rm -r heaps
    ''
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      for f in contrib/*/${platform}/{z3,nunchaku,SPASS,zipperposition}; do
        patchelf --set-interpreter $(cat ${stdenv.cc}/nix-support/dynamic-linker) "$f"${lib.optionalString stdenv.hostPlatform.isAarch64 " || true"}
      done
      patchelf --set-interpreter $(cat ${stdenv.cc}/nix-support/dynamic-linker) contrib/bash_process-*/${platform}/bash_process

      ln -sf ${electron}/bin/electron contrib/vscodium-*/*/electron
      rm contrib/vscodium-*/*/*.so{,.*}
      rm contrib/vscodium-*/*/chrome*

      for d in contrib/kodkodi-*/jni/${platform}; do
        patchelf --set-rpath "${
          lib.concatStringsSep ":" [
            "${java}/lib/openjdk/lib/server"
            "${lib.getLib stdenv.cc.cc}/lib"
          ]
        }" $d/*.so
      done
    ''
    + lib.optionalString (stdenv.hostPlatform.system == "x86_64-linux") ''
      patchelf --set-rpath "${lib.getLib stdenv.cc.cc}/lib" contrib/z3-*/${platform}/z3
    '';

    buildPhase = ''
      runHook preBuild

      setup_name=$(basename contrib/isabelle_setup*)
      user_home="$(bin/isabelle getenv -b ISABELLE_HOME_USER)"
      mkdir -p "$user_home/etc"
      echo 'ISABELLE_TMP_PREFIX="$TMPDIR/isabelle"' > "$user_home/etc/settings"

      TARGET_DIR="contrib/$setup_name/lib"
      rm -rf "$TARGET_DIR"
      mkdir -p "$TARGET_DIR/isabelle/setup"
      declare -a ARGS=("-Xlint:unchecked")
      SOURCES="$(${perl}/bin/perl -e 'while (<>) { if (m{([[:alnum:]_./-]+\.java)}) { print "$1 "; } }' "src/Tools/Setup/etc/build.props")"
      for SRC in $SOURCES; do
        ARGS["''${#ARGS[@]}"]="src/Tools/Setup/$SRC"
      done

      javac -d "$TARGET_DIR" -classpath \
        "${scala_3.bare}/maven2/org/scala-lang/scala3-interfaces/${scala_3.version}/scala3-interfaces-${scala_3.version}.jar:${scala_3.bare}/maven2/org/scala-lang/scala3-compiler_3/${scala_3.version}/scala3-compiler_3-${scala_3.version}.jar:./contrib/flatlaf-3.7.2/lib/flatlaf-3.7.2-no-natives.jar" \
        "''${ARGS[@]}"
      jar -c -f "$TARGET_DIR/isabelle_setup.jar" -e "isabelle.setup.Setup" -C "$TARGET_DIR" isabelle
      rm -rf "$TARGET_DIR/isabelle"

      bin/isabelle scala_build
      ln -s ${polyml'}/bin ./contrib/polyml-*/
      bin/isabelle build -v -o system_heaps -b HOL
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin $out/share
      mv $TMP/$dirname $out/share
      cd $out/share/$dirname
      bin/isabelle install $out/bin
      mkdir -p "$out/share/icons/hicolor/isabelle/apps"
      cp "$out/share/Isabelle${finalAttrs.version}/lib/icons/isabelle.xpm" "$out/share/icons/hicolor/isabelle/apps/"
      runHook postInstall
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "isabelle";
        exec = "isabelle jedit";
        icon = "isabelle";
        desktopName = "Isabelle";
        comment = finalAttrs.meta.description;
        categories = [
          "Education"
          "Science"
          "Math"
        ];
      })
    ];

    passthru = { inherit platform; };

    meta = {
      description = "Generic proof assistant";
      longDescription = ''
        Isabelle is a generic proof assistant. It allows mathematical formulas
        to be expressed in a formal language and provides tools for proving those
        formulas in a logical calculus.
      '';
      homepage = "https://isabelle.in.tum.de/";
      sourceProvenance = with lib.sourceTypes; [
        fromSource
        binaryNativeCode
        binaryBytecode
      ];
      license = lib.licenses.bsd3;
      platforms = lib.attrNames platforms;
      broken = !(stdenv.buildPlatform.canExecute stdenv.hostPlatform);
    };
  })
  // lib.optionalAttrs buildIsDarwin {
    __noChroot = true;
  }
)
