{
  lib,
  stdenvNoCC,
  makeWrapper,
  nodejs_24,
  source,
}:
stdenvNoCC.mkDerivation {
  pname = "agy-hud";
  version = "0.2.1-unstable-${source.date}";
  inherit (source) src;

  nativeBuildInputs = [makeWrapper];
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/agy-hud
    cp -r dist package.json $out/lib/agy-hud/
    makeWrapper ${lib.getExe nodejs_24} $out/bin/agy-hud \
      --add-flags $out/lib/agy-hud/dist/index.js
    install -Dm644 LICENSE README.md -t $out/share/doc/agy-hud

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    payload='{"model":{"id":"gemini-4-argon","display_name":"Gemini 4 Argon"},"cwd":"/tmp","context_window":{"context_window_size":1000000,"used_percentage":1.5},"terminal_width":100}'
    hudHome=$(mktemp -d)
    echo "$payload" | HOME="$hudHome" $out/bin/agy-hud | grep -qF 'Gemini 4 Argon'
    mkdir -p "$hudHome/.gemini/antigravity-cli/plugins/agy-hud"
    echo '{"language":"zh-Hans"}' >"$hudHome/config.json"
    ln -s "$hudHome/config.json" "$hudHome/.gemini/antigravity-cli/plugins/agy-hud/config.json"
    echo "$payload" | HOME="$hudHome" $out/bin/agy-hud | grep -qF '上下文'

    runHook postInstallCheck
  '';

  meta = {
    description = "Real-time statusline HUD for Antigravity CLI";
    homepage = "https://github.com/lllopic/agy-hud";
    license = lib.licenses.mit;
    mainProgram = "agy-hud";
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
