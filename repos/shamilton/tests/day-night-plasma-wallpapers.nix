{ modules
, hm-module-test
}:

hm-module-test {
  name = "day-night-plasma-wallpapers";
  hmModule = modules.hmModules.day-night-plasma-wallpapers;
  hmModuleConfig = {
    services.day-night-plasma-wallpapers = {
      enable = true;
      onCalendar = "*-*-* 16:02:01";
      sleepDuration = 60;
    };
  };
}
