{ pkgs }:
let
  serviceButton = svcType: name: label: {
    inherit label;
    type = "toggle";
    command = "swaync-service-dispatcher toggle ${svcType} ${name}";
    update-command = "swaync-service-dispatcher print ${svcType} ${name}";
    active = true;
  };
in
{
  gps = serviceButton "s6" "eg25-control-gps" "";  # GPS services; other icons: gps, ⌖, 🛰, 🌎, 
  cell-modem = serviceButton "s6" "eg25-control-powered" "󰺐";  # icons: 5g, 📡, 📱, ᯤ, ⚡, , 🌐, 📶, 🗼, 󰀂, , 󰺐, 󰩯
  vpn = serviceButton "systemd" "wg-quick-vpn-servo" "vpn::hn";

  gnome-calls = serviceButton "s6" "gnome-calls" "SIP";
  geary = serviceButton "s6" "geary" "󰇮";  # email (Geary); other icons: ✉, [E], 📧, 󰇮
  abaddon = serviceButton "s6" "abaddon" "󰊴";  # Discord chat client; icons: 󰊴, 🎮
  dissent = serviceButton "s6" "dissent" "󰊴";  # Discord chat client; icons: 󰊴, 🎮
  signal-desktop = serviceButton "s6" "signal-desktop" "💬";  # Signal messenger; other icons: 󰍦
  dino = serviceButton "s6" "dino" "XMPP";  # XMPP calls (jingle)
  fractal = serviceButton "s6" "fractal" "[m]";  # Matrix messages
}
