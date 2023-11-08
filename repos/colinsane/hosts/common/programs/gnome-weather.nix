# preferences are saved via dconf; see `dconf dump /`
# cache dir is just for weather data (or maybe a http cache)
{ ... }:
{
  sane.programs.gnome-weather = {
    persist.byStore.plaintext = [
      ".cache/libgweather"
    ];
  };
}
