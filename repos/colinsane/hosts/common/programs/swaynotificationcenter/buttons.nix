# icon sources:
# - <https://www.vertex42.com/ExcelTips/unicode-symbols.html>
# - <https://onlinetools.com/unicode/add-combining-characters>
# - `font-manager`
#   - this one shows all the "private use" emoji, for e.g. font Noto
# - nerd-fonts: <https://github.com/ryanoasis/nerd-fonts>
#   - grep `glyphnames.json` for the icon you want. about half of them are labeled usefully?

let
  serviceButton = name: label: {
    inherit label;
    type = "toggle";
    command = "swaync-service-dispatcher toggle ${name}";
    update-command = "swaync-service-dispatcher print ${name}";
    active = true;
  };
in
{
  # icon sets:
  # - GPS
  #   ⌖ 🛰 🌎           󰇧  󰍒 󱋼 󰍎 󰍐 󰓾 󱘇
  # - modem
  #   📡 📱 ᯤ ⚡    🌐  📶 🗼 󰀂    󰺐  󰩯
  # - calls
  #    󰏲   󰏾   󱆗 󱆖 󰏸
  #   SIP ☏ ✆ ℡ 📞📱
  # - email
  #   ✉ [E]  E⃞    󰇰    󰻨  󰻪  󰇮  󰾱 󰶍
  #   󱡰 󱡯
  #   📧 📨 📩  📬 📫
  # - messaging
  #      󱥂  󰆁   󰆉 󰍪 󰡡 󱀢 󱗠 󱜾 󱜽 󱥁 󱗟 󰍦 󰍦 󰊌 󰿌 󰿍 󰚢 
  #       󰭻   󰋉   
  #     
  #     
  #   …⃝ Θ
  #   󰌌 ⌨   ✍
  #   💬🗨️ 📟📤 📱📲
  #   ⏏️ ⇪ ⇫ ⮸ ⭿ ⍐ ⎘
  # - XMPP
  #   󰟿  🦕 🦖
  # - Signal
  #   🔵 🗣   󰈎 󰒯 󰒰 
  # - Matrix
  #   🇲 𝐌  ₘ  m̄  m⃞  m̋⃞  M⃞  󰫺 󰬔
  # - discord
  #     󰙯 󰊴 󰺷 🎮
  gps = serviceButton "gps.target" "";
  cell-modem = serviceButton "eg25-control-powered" "󰺐";

  abaddon = serviceButton "abaddon" " ";
  dino = serviceButton "dino" "󰟿";
  discord = serviceButton "discord" " ";
  dissent = serviceButton "dissent" " ";
  fractal = serviceButton "fractal" "[m]";
  geary = serviceButton "geary" "";
  gnome-calls = serviceButton "gnome-calls" "";
  signal-desktop = serviceButton "signal-desktop" "󰭻";
  stamp = serviceButton "stamp" "";
}
