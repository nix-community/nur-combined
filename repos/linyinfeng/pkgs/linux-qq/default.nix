{ sources, lib, appimageTools }:

appimageTools.wrapType2 {
  name = "linux-qq";
  inherit (sources.linux-qq) pname src version;

  meta = with lib; {
    description = "Official QQ client for Linux";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ yinfeng ];
    # The package is in **open** beta
    # But I currently has no test permission to try this package
    # So, mark it broken
    broken = true;
  };
}
