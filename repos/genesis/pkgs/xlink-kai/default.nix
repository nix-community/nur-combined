{ stdenv, pkgs, fetchurl, autoPatchelfHook, makeWrapper, frida-tools, frida-compile }:

let
  libPath = stdenv.lib.makeLibraryPath [ stdenv.cc.cc ];
  version = "7.4.38";

in stdenv.mkDerivation rec {
  pname = "xlink-kai";
  inherit version;

  src = fetchurl {
    url = "https://github.com/Team-XLink/releases/releases/download/v7.4.38/kaiEngine-7.4.38-539579851.headless.ubuntu.x86_64.tar.gz";
    sha256 = "0k2b7g3vm81dpr08kjsv7g85l4brljywv1gy7dm41v0z87vzi52r";
  };

  # avoid dynamic fetching by kaiEngine
  webui = fetchurl {
    name = "webui.zip";
    url = "https://client.teamxlink.co.uk/binary/webui_0.9978-38.zip";
    sha256 = "625662901391a70213680c5e59baffc495f8d95596cb620ac5e9eb42a833dd51";
  };

  nativeBuildInputs = [ autoPatchelfHook stdenv.cc.cc makeWrapper ];
  buildInputs = [ frida-tools frida-compile ];

  dontStrip = true;
  #
  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

  fridaOptions = "--runtime=v8 --no-pause";
  #TODO frida accept only one script
  fridaScript = "_agent.js";

  installPhase = ''
    set -x
    # To run without root/sudo grant cap_net_admin capability to the engine with:
    # TODO : write wrapper with libcap
    # setcap cap_net_admin=eip kaiengine
    install -Dm755 kaiengine $out/bin/kaiengine
    install -Dm644 "${webui}" $out/data/webui.zip

    # could be compiled using frida-compile
    # see https://github.com/oleavr/frida-agent-example

    #frida-compile ${./index.ts} -o _agent.js -c
    # nix-shell -p nodejs --run "npm install"
    # nix-shell -p nodejs --run "npm run watch"
    i#nstall -Dm644 _agent.js $out/lib/_agent.js
    install -Dm644 ${./agent.js} $out/lib/_agent.js

    # this trick doesn't work there (-why?)
    # --suffix-each LD_LIBRARY_PATH : ${libPath} \

    makeWrapper ${frida-tools}/bin/frida $out/bin/${pname} \
     --add-flags "-l \$SCRIPT_DIR/${fridaScript} $fridaOptions -f \
       $out/bin/kaiengine -- --appdata $out/data/ \
       --configfile \$XDG_CONFIG_HOME/xlink-kai/kaiengine.conf" \
     --run "mkdir -p \$XDG_CONFIG_HOME/xlink-kai" \
     --run "ldd $out/bin/kaiengine" \
     --run "if [ -f _agent.js ]; then export SCRIPT_DIR=\$(pwd) ;else export SCRIPT_DIR=$out/lib/;fi"
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
