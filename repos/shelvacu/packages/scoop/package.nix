{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  certificate-ripper,
  yt-dlp,
  playwright-test,
  playwright-driver,
}:
buildNpmPackage (finalAttrs: {
  pname = "scoop";
  version = "0.6.59";

  src = fetchFromGitHub {
    owner = "harvard-lil";
    repo = "scoop";
    tag = finalAttrs.version;
    hash = "sha256-KcoTl2ehla6ALLrpAyfOqDioP5s3CGVfVhsj3Fbq6/Y=";
  };

  patches = [ ./no-truncate.patch ];

  npmDepsHash = "sha256-lx+MxV8JDArDMQ0OV4eDXOTzd7xRfvvpAGJp+jPQPgs=";

  env.PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";

  dontNpmBuild = true;

  postInstall = ''
    scoop_npm_dir="$out/lib/node_modules/@harvard-lil/scoop"
    ln -s /tmp "$scoop_npm_dir"/tmp

    (
      cd $out/lib/node_modules/@harvard-lil/scoop/node_modules
      rm -rf playwright playwright-core
      ln -s ${playwright-test}/lib/node_modules/playwright
      ln -s ${playwright-test}/lib/node_modules/playwright-core
    )

    # reimplementing what scoop does in $src/postinstall.sh
    exe_dir="$scoop_npm_dir/executables"
    mkdir -p "$exe_dir"
    ln -s ${lib.escapeShellArg (lib.getExe yt-dlp)} "$exe_dir"/yt-dlp
    ln -s ${lib.escapeShellArg (lib.getExe certificate-ripper)} "$exe_dir"/crip
  '';

  makeWrapperArgs = [
    "--set"
    "PLAYWRIGHT_BROWSERS_PATH"
    playwright-driver.browsers
  ];

  meta = {
    description = "high fidelity, browser-based, web archiving capture engine for witnessing the web";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      # dunno whats in those npm deps without digging
      binaryBytecode
      binaryNativeCode
    ];
    mainProgram = "scoop";
  };
})
