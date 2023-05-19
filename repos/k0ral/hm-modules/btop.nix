{ config, lib, pkgs ? import <nixpkgs> { }, ... }:
with lib;

let
  cfg = config.module.btop;
in {
  options.module.btop = {
    enable = mkEnableOption "btop module";
  };

  config = mkIf cfg.enable {
    programs.btop = {
      enable = true;
      settings = {
        color_theme = "Default";
        theme_background =false;
        truecolor=true;
        shown_boxes = "cpu mem net proc";
        update_ms=2000;
        proc_update_mult=2;
        proc_sorting="memory";
        proc_reversed=false;
        proc_tree=true;
        tree_depth=3;
        proc_colors=true;
        proc_gradient=true;
        proc_per_core=false;
        proc_mem_bytes=true;
        cpu_graph_upper="total";
        cpu_graph_lower="total";
        cpu_invert_lower=true;
        cpu_single_graph=false;
        show_uptime=true;
        check_temp=true;
        cpu_sensor="Auto";
        show_coretemp=true;
        temp_scale="celsius";
        show_cpu_freq=true;
        draw_clock="%X";
        background_update=true;
        custom_cpu_name="";
        disks_filter="";
        mem_graphs=true;
        show_swap=true;
        swap_disk=false;
        show_disks=true;
        only_physical=true;
        use_fstab=false;
        show_io_stat=true;
        io_mode=false;
        io_graph_combined=false;
        io_graph_speeds="";
        net_download="10M";
        net_upload="10M";
        net_auto=true;
        net_sync=false;
        net_color_fixed=false;
        net_iface="";
        show_battery=true;
        show_init=false;
        update_check=false;
        log_level="WARNING";
      };
    };
  };
}
