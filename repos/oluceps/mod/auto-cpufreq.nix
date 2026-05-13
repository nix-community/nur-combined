{ inputs, ... }:
{
  flake.modules.nixos.auto-cpufreq =
    {
      ...
    }:
    {
      imports = [
        inputs.auto-cpufreq.nixosModules.default
      ];
      # ---Snip---
      programs.auto-cpufreq.enable = true;
      # # optionally, you can configure your auto-cpufreq settings, if you have any
      # programs.auto-cpufreq.settings = {
      #   charger = {
      #     governor = "performance";
      #     turbo = "auto";
      #   };

      #   battery = {
      #     governor = "powersave";
      #     turbo = "auto";
      #   };
      # };

    };
}
