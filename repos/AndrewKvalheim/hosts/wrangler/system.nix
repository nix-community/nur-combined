{ ... }:

{
  imports = [
    ../../system.nix
    <nixos-hardware/lenovo/thinkpad/t14/amd/gen2>
    /etc/nixos/hardware-configuration.nix
    ./system.local.nix
  ];

  # Host parameters
  host = {
    name = "wrangler";
    dir = ./.;
    metrics = rec {
      cpuCores = 16;
      cpuMarkMulti = 16738;
      cpuMarkSingle = 2880;
      displayDensity = 2.0;
      displayWidth = 3840;
      ramGb = 48 - vramGb;
      vramGb = 8;
    };
  };

  # Keyboard
  services.udev.extraHwdb = ''
    # From:
    #   角 ░  ░  ░  ░  ░  ░  ░  ░  ░  ░  ░  ░  ░  ░
    #    ↹  ░  ░  ░  ░  ░  ░  ░  ░  ░  ░  ░  ░
    #     ░  ░  ░  ░  ░  g  ░  ░  ░  ░  ░  ░  ░  ░
    #      ⇧  ░  ░  c  ░  ░  ░  ░  ░  ░  ░  ░  ░
    #      ⎈  ❖  ⎇  無    ␣  換 仮 ⇮  ⎙  ░
    # To:
    #   ⎙  ░  ░  ░  ░  ░  ░  ░  ░  ░  ░  ░  ░  ░  ░
    #    g  ░  ░  ░  ░  ░  ░  ░  ░  ░  ░  ░  ░
    #     ░  ░  ░  ░  ░  ↵  ░  ░  ░  ░  ░  ░  ░  ░
    #      c  ░  ░  ␣  ░  ░  ░  ░  ░  ░  ░  ░  ░
    #      ❖  ⎇  ⎈  ↹     ⇧  ⇧  ⇮  ⎇  ❖  ░
    evdev:name:AT Translated Set 2 keyboard:*
      KEYBOARD_KEY_29=sysrq
      KEYBOARD_KEY_0f=g
      KEYBOARD_KEY_22=enter
      KEYBOARD_KEY_2a=c
      KEYBOARD_KEY_2e=space
      KEYBOARD_KEY_1d=leftmeta
      KEYBOARD_KEY_db=leftalt
      KEYBOARD_KEY_38=leftctrl
      KEYBOARD_KEY_7b=tab
      KEYBOARD_KEY_39=leftshift
      KEYBOARD_KEY_79=rightshift
      KEYBOARD_KEY_70=rightalt
      KEYBOARD_KEY_b8=leftalt
      KEYBOARD_KEY_b7=rightmeta
  '';
  services.kmonad.keyboards.default.device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";

  # Nix
  system.stateVersion = "22.05"; # Permanent

  # Mouse
  services.input-remapper.enable = true;

  # Networking
  systemd.network.links = {
    "10-wifi".linkConfig.Name = "wifi";
  };
}
