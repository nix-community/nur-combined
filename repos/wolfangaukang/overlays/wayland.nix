final: prev: {
  rofiwl-custom = prev.rofi.override {
    plugins = with prev.pkgs; [
      rofi-calc
      rofi-top
    ];
  };
}
