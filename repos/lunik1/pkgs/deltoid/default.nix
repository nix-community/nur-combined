{
  lib,
  buildGraalvmNativeImage,
  fetchurl,
}:

buildGraalvmNativeImage (finalAttrs: rec {
  pname = "deltoid";
  version = "0.2.1";

  src = fetchurl {
    url = "https://codeberg.org/lunik1/deltoid/releases/download/${version}/deltoid.main-${version}.jar";
    sha256 = "sha256-qgJSn0KF92ONrOTv1CLfnyl8CJBntOUMuybTJN3roNQ=";
  };

  extraNativeImageBuildArgs = [
    "-H:+ReportExceptionStackTraces"
    "--no-fallback"
    "--features=clj_easy.graal_build_time.InitClojureClasses"
    "--initialize-at-build-time=org.slf4j"
    "--report-unsupported-elements-at-runtime"
  ];

  meta = {
    description = "Kagi News RSS feed generator";
    homepage = "https://codeberg.org/lunik1/deltoid";
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    license = lib.licenses.bsd2Patent;
    maintainers = with lib.maintainers; [
      lunik1
    ];
    mainProgram = "deltoid";
  };
})
