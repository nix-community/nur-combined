{ stdenv, coreutils, writeScript, makeDesktopItem, bash, bubblewrap, socat, electrum }:

let
  hostScript = writeScript "electrum-bubblewrap-host-script"
    ''
    #!${bash}/bin/bash
    
    export TDIR=$(${coreutils}/bin/mktemp -d --suffix .bwrap -p $XDG_RUNTIME_DIR)
    export SOCKET=$TDIR/bwrap.socket
    ${socat}/bin/socat UNIX-LISTEN:$SOCKET TCP:localhost:50002 &
    
    (exec ${bubblewrap}/bin/bwrap \
        --proc /proc \
        --dev /dev \
        --dev-bind-try /dev/video0 /dev/video0 \
        --dev-bind-try /dev/video1 /dev/video1 \
        --dev-bind /dev/dri /dev/dri \
        --ro-bind /nix /nix \
        --tmpfs /run \
        --ro-bind /run/opengl-driver /run/opengl-driver \
        --bind $TDIR $TDIR \
        --ro-bind ${bash}/bin/bash ${bash}/bin/bash \
        --tmpfs /tmp \
        --ro-bind /tmp/.X11-unix/X0 /tmp/.X11-unix/X0 \
        --ro-bind /etc/fonts /etc/fonts \
        --tmpfs $HOME \
        --ro-bind $HOME/.Xauthority $HOME/.Xauthority \
        --bind $HOME/.electrum $HOME/.electrum \
        --ro-bind ${containerScript} ${containerScript} \
        --ro-bind $HOME/.local/share $HOME/.local/share \
        --bind-try $HOME/tnxs $HOME/tnxs \
        --bind-try $HOME/.cache/matplotlib $HOME/.cache/matplotlib \
        --unshare-net \
        -- ${containerScript} "$@")
    
    rm -fR $TDIR
    '';

  containerScript = writeScript "electrum-bubblewrap-container-script"
    ''
    #!${bash}/bin/bash
    
    ${socat}/bin/socat TCP-LISTEN:50002 UNIX-CONNECT:$SOCKET &
    ${coreutils}/bin/sleep 1
    
    ${electrum}/bin/electrum "$@"
    '';  
in stdenv.mkDerivation rec {
  name = "electrum-hardened";
  version = "2020-05-17";

  phases = [ "installPhase" ];

  installPhase = ''
    install -D ${hostScript} $out/bin/electrum-hardened

    mkdir -p $out/share
    cp --recursive ${desktopItem}/share/applications $out/share
    ln -s ${electrum}/share/icons $out/share/icons
  '';

  desktopItem = makeDesktopItem {
    inherit name;
    exec = "electrum-hardened";
    icon = "electrum";
    desktopName = "Electrum-Hardened (The Electrum wallet in a Bubblewrap container)";
    comment = meta.description;
    categories = "Finance;Network;";
    mimeType = "x-scheme-handler/bitcoin;";
    genericName = "Bitcoin Wallet";
  };

  meta = with stdenv.lib; {
    description = "The Electrum Bitcoin wallet, but restricted by a Bubblewrap Linux container for enhanced privacy protection.";
    homepage = https://github.com/spesmilo/electrum;
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ emmanuelrosa ];
  };
}
