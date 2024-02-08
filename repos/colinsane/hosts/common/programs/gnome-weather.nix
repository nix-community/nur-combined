# preferences are saved via dconf; see `dconf dump /`
# cache dir is just for weather data (or maybe a http cache)
{ ... }:
{
  sane.programs."gnome.gnome-weather" = {
    sandbox.method = "bwrap";
    sandbox.wrapperType = "inplace";
    sandbox.net = "clearnet";
    sandbox.extraHomePaths = [
      ".config/dconf"  # stores city/location settings
    ];
    persist.byStore.plaintext = [
      ".cache/libgweather"
    ];
  };
}
