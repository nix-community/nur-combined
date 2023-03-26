{ runCommand
, neovim-unwrapped
, firenvim ? vimPlugins.firenvim or null, vimPlugins
, lib
}: runCommand "firenvim-native" {
  nativeBuildInputs = [ neovim-unwrapped ];
  inherit firenvim;
  vimExe = neovim-unwrapped.meta.mainProgram or (lib.getName neovim-unwrapped);
  meta.broken = firenvim == null;
} ''
  mkdir home
  export HOME=$PWD/home
  export XDG_CONFIG_HOME=$HOME/.config
  export XDG_DATA_HOME=$HOME/.local/share
  export XDG_RUNTIME_DIR=$PWD/run
  $vimExe --headless -n --clean \
    --cmd "source $firenvim/autoload/firenvim.vim" \
    --cmd "call firenvim#install(1)" \
    --cmd quit
  ls -l

  install -d $out/lib/{mozilla,librewolf} $out/etc/{chromium,vivaldi,opt/chrome,opt/brave,opt/edge}
  mv $HOME/.mozilla/native-messaging-hosts $out/lib/mozilla/
  mv $HOME/.librewolf/native-messaging-hosts $out/lib/librewolf/
  mv $XDG_CONFIG_HOME/vivaldi/NativeMessagingHosts $out/etc/vivaldi/native-messaging-hosts
  mv $XDG_CONFIG_HOME/chromium/NativeMessagingHosts $out/etc/chromium/native-messaging-hosts
  mv $XDG_CONFIG_HOME/google-chrome/NativeMessagingHosts $out/etc/opt/chrome/native-messaging-hosts
  mv $XDG_CONFIG_HOME/BraveSoftware/Brave-Browser/NativeMessagingHosts $out/etc/opt/brave/native-messaging-hosts
  mv $XDG_CONFIG_HOME/microsoft-edge/NativeMessagingHosts $out/etc/opt/edge/native-messaging-hosts

  FIRENVIM_BIN=$XDG_DATA_HOME/firenvim/firenvim
  sed -i \
    -e "s|$XDG_CONFIG_HOME|\\\$XDG_CONFIG_HOME|" \
    -e "s|$XDG_DATA_HOME|\\\$XDG_DATA_HOME|" \
    -e "s|$XDG_RUNTIME_DIR|\\\$XDG_RUNTIME_DIR|" \
    -e "s|$(type -P $vimExe)|$vimExe|" \
    -e "/XDG_DATA_DIRS=/d" \
    -e "/export PATH=/d" \
    $FIRENVIM_BIN
  install -Dm0755 -t $out/lib/firenvim $FIRENVIM_BIN
  find $out -name '*.json' -exec sed -i \
    -e "s|$FIRENVIM_BIN|$out/lib/firenvim/firenvim|" \
    "{}" \;
''
