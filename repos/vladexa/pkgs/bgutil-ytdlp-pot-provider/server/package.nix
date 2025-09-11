{
  buildNpmPackage,
  cairo,
  giflib,
  lib,
  libjpeg,
  librsvg,
  nodejs,
  pango,
  pixman,
  pkg-config,
  typescript,
  version,
  src,
  ...
}:
buildNpmPackage (finalAttrs: {
  inherit nodejs src version;

  pname = "bgutil-ytdlp-pot-provider";

  sourceRoot = "${finalAttrs.src.name}/server";

  nativeBuildInputs = [
    pkg-config
    typescript
  ];

  buildInputs = [
    cairo
    giflib
    libjpeg
    librsvg
    pango
    pixman
  ];

  makeCacheWritable = true;
  npmDepsHash = "sha256-lCK7ukI60Exe+PW0rATm3szzWDv8AaVJPS6Hl9Rfm18=";

  buildPhase = ''
    runHook preBuild

    tsc

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r build $out/build
    sed -i "1i\#!${lib.getExe finalAttrs.nodejs}" $out/build/main.js
    cp -r node_modules $out/node_modules
    ln -s $out/build/main.js $out/bin/bgutil-ytdlp-pot-provider
    chmod +x $out/bin/bgutil-ytdlp-pot-provider

    runHook postInstall
  '';

  meta = {
    description = "Proof-of-origin token provider plugin for yt-dlp";
    homepage = "https://github.com/Brainicism/bgutil-ytdlp-pot-provider";
    license = lib.licenses.gpl3Plus;
    mainProgram = "bgutil-ytdlp-pot-provider";
    maintainers = [
      {
        email = "vgrechannik@gmail.com";
        name = "Vladislav Grechannik";
        github = "VlaDexa";
        githubId = 52157081;
      }
    ];
  };
})
