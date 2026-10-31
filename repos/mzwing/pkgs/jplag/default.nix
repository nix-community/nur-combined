# The release jar bundles every language frontend and the report viewer; it needs the full JDK, as javac parses Java submissions and java.awt.Desktop opens the viewer in a browser.
{
  lib,
  stdenvNoCC,
  makeWrapper,
  jdk25,
  source,
}:
stdenvNoCC.mkDerivation {
  pname = "jplag";
  inherit (source) version src;

  nativeBuildInputs = [makeWrapper];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 $src $out/lib/jplag/jplag.jar
    makeWrapper ${lib.getExe jdk25} $out/bin/jplag \
      --add-flags "-jar $out/lib/jplag/jplag.jar"

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    # Comparing Java submissions proves the runtime has javac, which `--help` would not.
    mkdir -p submissions/a submissions/b
    echo 'class Main { int square(int x) { return x * x; } }' >submissions/a/Main.java
    cp submissions/a/Main.java submissions/b/
    $out/bin/jplag --skip-version-check --mode run --min-tokens 1 submissions
    test -f results.jplag

    runHook postInstallCheck
  '';

  meta = {
    description = "Detect source code plagiarism and collusion in a set of programs";
    homepage = "https://github.com/jplag/JPlag";
    changelog = "https://github.com/jplag/JPlag/releases/tag/v${source.version}";
    license = lib.licenses.gpl3Only;
    mainProgram = "jplag";
    sourceProvenance = [lib.sourceTypes.binaryBytecode];
    maintainers = [
      {
        name = "mzwing";
      }
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
