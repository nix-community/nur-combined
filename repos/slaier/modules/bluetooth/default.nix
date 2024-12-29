{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        ControllerMode = "bredr";
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
  };
}
