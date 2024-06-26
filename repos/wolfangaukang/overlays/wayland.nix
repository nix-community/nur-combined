final: prev:
{
  rofiwl-custom = prev.rofi-wayland.override {
    plugins = with prev.pkgs; [
      (rofi-calc.override { rofi-unwrapped = rofi-wayland-unwrapped; })
      (rofi-top.override { rofi-unwrapped = rofi-wayland-unwrapped; })
    ];
  };
}
