{
  lib,
  buildNpmPackage,
  fetchFromForgejo,
  makeWrapper,
  nodejs,
}:

buildNpmPackage (finalAttrs: {
  pname = "out-of-your-element";
  version = "3.7";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromForgejo {
    domain = "gitdab.com";
    owner = "cadence";
    repo = "out-of-your-element";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JMT5wPTYXeqXP832Lm9QTXj1ukaCXXJGtSsXNj6GnIs=";
  };

  patches = [
    ./0001-fix-setup-remove-connectivity-check.patch
  ];

  npmDepsHash = "sha256-SYxAef1MJTGCLPMBM+RVKUEY1UNR6tSHMeU62CqF1OM=";
  dontNpmBuild = true;

  nativeInstallInputs = [
    makeWrapper
  ];

  preInstall = ''
    npm install-scripts approve better-sqlite3
  '';

  postInstall = ''
    mkdir -p "$out/bin"

    makeWrapper ${lib.getExe nodejs} "$out/bin/out-of-your-element" \
      --add-flag "$out/lib/node_modules/out-of-your-element/start.js"
    makeWrapper ${lib.getExe nodejs} "$out/bin/addbot" \
      --add-flag "$out/lib/node_modules/out-of-your-element/addbot.js"

    for script in "$out/lib/node_modules/out-of-your-element/scripts/"*.js; do
      [ -e "$script" ] || continue
      name="$(basename "$script" .js)"

      makeWrapper ${lib.getExe nodejs} "$out/bin/$name" \
        --add-flag "$script"
    done
  '';

  meta = {
    description = "Matrix-Discord bridge with modern features";
    homepage = "https://gitdab.com/cadence/out-of-your-element";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ bartoostveen ];
    mainProgram = "out-of-your-element";
    platforms = lib.platforms.all;
  };
})
