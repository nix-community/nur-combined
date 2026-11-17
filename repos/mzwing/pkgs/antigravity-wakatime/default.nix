{
  lib,
  stdenvNoCC,
  makeWrapper,
  nodejs_24,
  wakatime-cli,
  source,
}:
stdenvNoCC.mkDerivation {
  pname = "antigravity-wakatime";
  version = "1.0.0-unstable-${source.date}";
  inherit (source) src;

  nativeBuildInputs = [makeWrapper];

  # Upstream downloads and updates its own wakatime-cli into ~/.wakatime
  postPatch = ''
    substituteInPlace bin/antigravity-cli-wakatime.js \
      --replace-fail "const checkLatest = options.checkLatest === true;" "return getCliLocation();" \
      --replace-fail "return path.join(getWakatimeDir(), \`wakatime-cli-\''${osName()}-\''${architecture()}\''${ext}\`);" "return '${lib.getExe wakatime-cli}';"
  '';

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/scripts
    cp -r plugin.json hooks.json bin $out/
    makeWrapper ${lib.getExe nodejs_24} $out/scripts/run \
      --add-flags "$out/bin/antigravity-cli-wakatime.js --background" \
      --unset NODE_OPTIONS
    install -Dm644 LICENSE README.md -t $out/share/doc/antigravity-wakatime

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    grep -qF '"name": "antigravity-cli-wakatime"' $out/plugin.json
    grep -qF 'scripts/run' $out/hooks.json
    test -x $out/scripts/run
    grep -qF '${wakatime-cli}' $out/bin/antigravity-cli-wakatime.js

    runHook postInstallCheck
  '';

  meta = {
    description = "WakaTime plugin for Antigravity CLI";
    homepage = "https://github.com/wakatime/antigravity-wakatime";
    license = lib.licenses.bsd3;
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
