{ config, ...}:

{
  programs.htop = {
    enable = true;
    settings = {
      delay = 2;
      header_margin = 0;
      hide_kernel_threads = 1;
      hide_userland_threads = 1;
      highlight_megabytes = 1;
      left_meter_modes = [ 1 1 1 2 ];
      left_meters = [ "AllCPUs2" "Memory" "Swap" "Zram" ];
      right_meter_modes = [ 2 2 2 2 ];
      right_meters = [ "Tasks" "LoadAverage" "Uptime" "Systemd" ];
      show_program_path = 0;
      tree_view = 1;
      highlight_changes = 1;
      highlight_changes_delay_secs = 2;
      update_process_names = 1;
      # manually removed "nice" and "prio" column
      fields = "0 48 38 39 40 2 46 47 49 1";
    };
  };

  environment.sessionVariables.HTOPRC = config.environment.etc."htoprc".source;
}
