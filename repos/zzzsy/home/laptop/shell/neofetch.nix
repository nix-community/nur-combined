''
  print_info () {
    prin "Eat  , Sleep  , Linux  ."
    info underline
    prin "Hardware Information"
    # info "󰌢 " model
    info "󰍛 " cpu
    # info "󰘚 " gpu
    # info " " disk
    info "󰟖 " memory
    info "󰍹 " resolution
    # info "󱈑 " battery 
    info underline
    prin "Software Information"
    info " " distro
    info " " kernel
    info " " de
    info " " wm
    info " " shell
    info " " term
    info " " term_font
    info "󰉼 " theme
    info "󰀻 " icons
    info "󰊠 " packages
    info "󰅐 " uptime
    info underline
    info cols
    prin " " # Padding
    prin "$(color 3)󰮯 \n \n $(color 5)󰊠 \n \n $(color 2)󰊠  \n \n $(color 6)󰊠  \n \n $(color 4)󰊠  \n \n $(color 1)󰊠  \n \n $(color 7)󰊠  \n \n "
  }
  title_fqdn="off"
  kernel_shorthand="on"
  distro_shorthand="on"
  os_arch="on"
  uptime_shorthand="tiny"
  memory_percent="on"
  memory_unit="mib"
  package_managers="on"
  shell_path="off"
  shell_version="on"
  speed_type="bios_limit"
  speed_shorthand="on"
  cpu_brand="on"
  cpu_speed="off"
  cpu_cores="off"
  cpu_temp="off"
  gpu_brand="on"
  gpu_type="all"
  refresh_rate="on"
  gtk_shorthand="on"
  gtk2="on"
  gtk3="on"
  public_ip_host=""
  public_ip_timeout=2
  de_version="on"
  disk_show=('/')
  disk_subtitle="mount"
  disk_percent="on"
  music_player="auto"
  song_format="%artist% - %album% - %title%"
  song_shorthand="on"
  mpc_args=(-p 7777)
  colors=(distro)
  bold="on"
  underline_enabled="on"
  underline_char="-"
  separator="⋮"
  block_range=(0 7)
  color_blocks="off"
  block_width=3
  block_height=1
  col_offset="auto"
  bar_char_elapsed="-"
  bar_char_total="="
  bar_border="on"
  bar_length=15
  bar_color_elapsed="distro"
  bar_color_total="distro"
  cpu_display="off"
  memory_display="off"
  battery_display="off"
  disk_display="off"
  #image_backend="chafa"
  ascii_distro="auto"
  ascii_colors=(distro)
  ascii_bold="on"
  crop_mode="fit"
  crop_offset="center"
  image_size="auto"
  gap=2
  yoffset=0
  xoffset=0
  background_color=
  stdout="off"
''
