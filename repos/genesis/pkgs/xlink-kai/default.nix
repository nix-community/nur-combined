{ stdenv, pkgs, fetchurl, autoPatchelfHook, makeWrapper
  , frida-tools
  , frida-agent-example }:

let
  libPath = stdenv.lib.makeLibraryPath [ stdenv.cc.cc ];
  version = "7.4.39";

in stdenv.mkDerivation rec {
  pname = "xlink-kai";
  inherit version;

  src = fetchurl {
    url = "https://cdn.teamxlink.co.uk/binary/kaiEngine-7.4.39-539601671.headless.debian.x86_64.tar.gz";
    sha256 = "0z0ma6hxbjvfvyibxk988zw2622k2ia637xw0v5hfvh838sjijsl";
  };

  # avoid dynamic fetching by kaiEngine
  webui = fetchurl {
    name = "webui.zip";
    url = "https://client.teamxlink.co.uk/binary/webui_0.9978-38.zip";
    sha256 = "625662901391a70213680c5e59baffc495f8d95596cb620ac5e9eb42a833dd51";
  };

  nativeBuildInputs = [ autoPatchelfHook stdenv.cc.cc makeWrapper ];
  buildInputs = [ frida-tools frida-agent-example ];

  dontStrip = true;
  #
  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

  fridaOptions = "--no-pause"; #--runtime=v8
  #TODO frida accept only one script
  fridaScript = "_agent.js";

  installPhase = ''
    #set -x
    # To run without root/sudo grant cap_net_admin capability to the engine with:
    # TODO : write wrapper with libcap
    # setcap cap_net_admin=eip kaiengine
    install -Dm755 kaiengine $out/bin/kaiengine
    install -Dm644 "${webui}" $out/data/webui.zip

    # poor packaging of frida-agent-example , use full path
    frida-compile ${./index.ts} -o $out/lib/_agent.js -c

    # this trick doesn't work there (-why?)
    # --suffix-each LD_LIBRARY_PATH : ${libPath} \

    makeWrapper ${frida-tools}/bin/frida $out/bin/${pname} \
     --add-flags "-l \$SCRIPT_DIR/${fridaScript} $fridaOptions -f \
       $out/bin/kaiengine -- --appdata $out/data/ \
       --configfile \$XDG_CONFIG_HOME/xlink-kai/kaiengine.conf" \
     --run "mkdir -p \$XDG_CONFIG_HOME/xlink-kai" \
     --run "ldd $out/bin/kaiengine" \
     --run "if [ -f _agent.js ]; then export SCRIPT_DIR=\$(pwd); else export SCRIPT_DIR=$out/lib/;fi"
  '';

meta = with stdenv.lib; {
    broken = true;
    description = "tunneling program that allows the play LAN games online";
    homepage = https://www.teamxlink.co.uk;
    license = licenses.unfree;
    maintainers = with maintainers; [ genesis ];
    platforms = [ "x86_64-linux" ];
  };
}
