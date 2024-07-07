{ modules
, hm-module-test
}:

hm-module-test {
  name = "myvim";
  hmModule = modules.hmModules.myvim;
  hmModuleConfig = { programs.myvim.enable = true; };
}
