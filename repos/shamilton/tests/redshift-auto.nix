{ modules
, hm-module-test
}:

hm-module-test {
  name = "redshift-auto";
  hmModule = modules.hmModules.redshift-auto;
  hmModuleConfig = {
    services.redshift-auto = {
      enable = true;
      onCalendar = "*-*-* 15:35:12";
      lightColour = 4500;
      nightColour = 2000;
    };
  };
}
