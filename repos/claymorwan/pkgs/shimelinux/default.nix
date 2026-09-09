{
  stdenv,
  lib,
  fetchFromGitHub,
  gradle,
  makeWrapper,
  libappindicator,
  glib,
  jdk21,
  callPackage,
  bash,
  writeShellScript,
  nix-update-script,  
}:

let
  wayland-lib = callPackage ./wayland-lib.nix { };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "shimelinux";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "BujjuIsABee";
    repo = "shimelinux";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ciw//4t65WFetMENisq1ye/mGWNBwXMO36St8Dovhmg=";
  };

  nativeBuildInputs = [
    gradle
    makeWrapper
    bash
  ];

  mitmCache = gradle.fetchDeps {
    # inherit (finalAttrs) pname;
    pkg = finalAttrs.finalPackage;
    data = ./deps.json;
  };

  # __darwinAllowLocalNetworking = true;
  doCheck = true;
  gradleFlags = [ "-Dfile.encoding=utf-8" ];

  dontPatchShebangs = true;

  prePatch = ''
    # substituteInPlace ./shimelinux.sh \
    #   --replace-fail '/usr' $out 

    substituteInPlace ./build.gradle.kts \
      --replace-fail 'dependsOn("buildWaylandLib")' "" \
      --replace-fail '$projectDir/shimelinux_wayland/target/release/libshimelinux_wayland.so' '${wayland-lib}/lib/libshimelinux_wayland.so'

    substituteInPlace ./shimelinux.desktop \
      --replace-fail "/usr/bin/" ""
  '';

  installPhase = ''
    install -Dm644 build/libs/shimelinux-${finalAttrs.version}.jar $out/share/java/shimelinux.jar
    # install -Dm755 ./shimelinux.sh $out/bin/shimelinux

    install -Dm644 ./icon.svg $out/share/icons/hicolor/scalable/apps/shimelinux.svg
    install -Dm644 ./shimelinux.desktop -t $out/share/applications

    echo '#!${lib.getExe bash}' > ./shimelinux
    echo "exec ${lib.getExe jdk21} -jar $out/share/java/shimelinux.jar" >> ./shimelinux
    install -Dm755 ./shimelinux $out/bin/shimelinux
    
    wrapProgram $out/bin/shimelinux \
      --prefix PATH : ${lib.makeBinPath [ jdk21 ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libappindicator glib ]}
  '';

  # passthru.updateScript = nix-update-script {
  #   extraArgs = [ "--version-regex=v(\\d\\.\\d\\.\\d))" ];
  # };

  meta = {
    description = "An unofficial Linux port of Shimeji-ee Desktop Pet";
    homepage = "https://github.com/BujjuIsABee/shimelinux";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ claymorwan ];
    mainProgram = "shimelinux";
    platforms = lib.platforms.linux;
    sourceProvenance =  with lib.sourceTypes; [
      fromSource
      binaryBytecode # mitm cache
    ];
  };
})
