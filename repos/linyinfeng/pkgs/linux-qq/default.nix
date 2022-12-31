{ sources, lib, appimageTools }:

appimageTools.wrapType2 {
  name = "linux-qq";
  inherit (sources.linux-qq) pname src version;

  meta = with lib; {
    description = "Official QQ client for Linux";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ yinfeng ];
    broken = true;
  };
}
