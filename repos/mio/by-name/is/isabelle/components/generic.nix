{
  lib,
  stdenvNoCC,
  fetchurl,
  coreutils,
  net-tools,
  rlwrap,
  procps,
  makeDesktopItem,
  copyDesktopItems,
  desktopToDarwinBundle,
  jdk,
  polyml,
  gnu-utils,
  symlinkJoin,
  fetchFromGitHub,
  writableTmpDirAsHomeHook,
  isabelleComponents,
  z3,
  buildIsabelle,
  bash,
}:

{
  makeHeap ? true,
  doCheck ? lib.meta.availableOn stdenvNoCC.hostPlatform z3,
  release ? "2026",
}@args:

componentsFn:

let
  platforms = {
    x86_64-linux = "x86_64-linux";
    aarch64-linux = "arm64-linux";
    aarch64-darwin = "arm64-darwin";
  };

  platform = platforms."${stdenvNoCC.hostPlatform.system}";

  components = componentsFn isabelleComponents;
in
stdenvNoCC.mkDerivation (
  finalAttrs:
  {
    pname = "isabelle";
    version = "2026-unstable-2026-11-26";

    src = fetchFromGitHub {
      owner = "isabelle-prover";
      repo = "mirror-isabelle";
      rev = "edc37046043fe8ded7afea74f691d8350a25aea2";
      hash = "sha256-6xWII/plOBoOEKRC/51UuSqaoLtioP18QIeffRKOTrU=";
    };

    __structuredAttrs = true;
    strictDeps = true;

    nativeBuildInputs = [
      jdk
      polyml
      copyDesktopItems
      writableTmpDirAsHomeHook
    ]
    ++ lib.optionals stdenvNoCC.hostPlatform.isDarwin [
      procps
      desktopToDarwinBundle
    ];

    buildInputs = [
      net-tools
      bash
    ]
    ++ components;

    # Source-build approach from https://github.com/NixOS/nixpkgs/pull/567461;
    # Isabelle 2026 baseline from https://github.com/NixOS/nixpkgs/pull/579996.
    patches = [
      # Make "isabelle build" work when generating documents
      # See: https://github.com/NixOS/nixpkgs/issues/289529
      (fetchurl {
        url = "https://raw.githubusercontent.com/sempiternal-aurora/nixpkgs/30b07b7e68d352cc26eb51d6b2cf402845b16e77/pkgs/by-name/is/isabelleComponents/fix-copied-permissions.patch";
        hash = "sha256-+9tD23E8MUziWJ6omTSugB/1DWLHnDB6zjDTc+1GUkY=";
      })
    ];

    propagatedBuildInputs = lib.optionals stdenvNoCC.hostPlatform.isDarwin [ procps ];

    postPatch = ''
      patchShebangs lib/Tools/ bin/

      substituteInPlace src/Pure/ML/ml_settings.scala \
        --replace-fail 'polyml_home + Path.basic(ml_platform)' 'Path.explode("${polyml}/bin")'

      cat >>etc/components <<EOF
      #bundled components
      ${gnu-utils}
      ${lib.strings.concatLines (map (c: c.settings) components)}
      EOF

      echo ISABELLE_LINE_EDITOR=${rlwrap}/bin/rlwrap >>etc/settings

      echo "Isabelle${release}" > etc/ISABELLE_IDENTIFIER
      echo "Isabelle${release}" > etc/ISABELLE_TAGS

      substituteInPlace lib/Tools/env \
        --replace-fail /usr/bin/env ${coreutils}/bin/env

      substituteInPlace src/Pure/General/bibtex.scala \
        --replace-fail '$BIB2XHTML_HOME/main/bib2xhtml.pl' '$ISABELLE_BIB2XHTML'
    '';

    buildPhase = ''
      runHook preBuild

      # Stop Isabelle trying to use `/tmp`.
      user_home="$(bin/isabelle getenv -b ISABELLE_HOME_USER)"
      mkdir -p "$user_home/etc"
      echo 'ISABELLE_TMP_PREFIX="$TMPDIR/isabelle"' > "$user_home/etc/settings"

      bin/isabelle scala_build
    ''
    + lib.optionalString makeHeap ''
      echo "Building HOL Heap"
      bin/isabelle build -j $NIX_BUILD_CORES -v -o system_heaps -b HOL
    ''
    + ''
      runHook postBuild
    '';

    inherit doCheck;
    checkPhase = "bin/isabelle build -v HOL-SMT_Examples";

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/share/isabelle
      cp -r ./* $out/share/isabelle
      cd $out/share/isabelle
      bin/isabelle install $out/bin

      # icon
      mkdir -p "$out/share/icons/hicolor/isabelle/apps"
      cp "$out/share/isabelle/lib/icons/isabelle.xpm" "$out/share/icons/hicolor/isabelle/apps/"

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
      (makeDesktopItem {
        name = "isabelle_vscodium";
        exec = "isabelle vscode";
        icon = "isabelle";
        desktopName = "Isabelle (VSCodium)";
        comment = finalAttrs.meta.description;
        categories = [
          "Education"
          "Science"
          "Math"
        ];
      })
    ];

    passthru = {
      inherit componentsFn platform;

      withComponents = f: buildIsabelle args (cp: componentsFn cp ++ f cp);
    };

    meta = {
      description = "Generic proof assistant";
      longDescription = ''
        Isabelle is a generic proof assistant.  It allows mathematical formulas
        to be expressed in a formal language and provides tools for proving those
        formulas in a logical calculus.
      '';
      homepage = "https://isabelle.in.tum.de/";
      license = lib.licenses.bsd3;
      sourceProvenance = with lib.sourceTypes; [
        fromSource
        binaryNativeCode
        binaryBytecode
      ];
      maintainers = [
        lib.maintainers.jvanbruegge
        lib.maintainers.sempiternal-aurora
      ];
      # need to compile the heaps for host on build
      # which requires us to use the host polyml toolchain
      broken = !(stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform);
      platforms = lib.attrNames platforms;
    };
  }
  // lib.optionalAttrs stdenvNoCC.hostPlatform.isDarwin {
    __noChroot = true;
  }
)
