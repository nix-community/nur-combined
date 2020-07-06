{
  programs.htop = {
    enable = true;
    delay = 10;
    meters = {
      left = [ "AllCPUs2" "Memory" "Swap" ];
      right = [ "Clock" "Hostname" "Tasks" "LoadAverage" "Uptime" "Battery" ];
    };
  };
}
