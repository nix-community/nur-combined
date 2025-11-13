{
  sources,
  version,
  lib,
  buildLua,
}:
buildLua (final: {
  inherit (sources) pname src;
  inherit version;

  scriptName = "uosc_danmaku";
  scriptPath = ".";
  passthru.scriptName = final.scriptName;

  meta = {
    description = "在MPV播放器中加载弹弹play弹幕";
    homepage = "https://github.com/Tony15246/uosc_danmaku";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    platforms = lib.platforms.unix;
  };
})
