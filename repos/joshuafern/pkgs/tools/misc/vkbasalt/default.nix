{ multiStdenv, lib, fetchFromGitHub, writeShellScript, glslang, xorg
, vulkan-loader, vulkan-headers, pkgsi686Linux }:

let
  vkbasalt_run = writeShellScript "vkbasalt" ''
    #!/bin/sh
    # Find what path this script runs from
    SCRIPT_PATH=$(dirname "$0")

    # Initialize user config as needed
    [ ! -d $XDG_DATA_HOME/vulkan/implicit_layer.d ] && mkdir -p $XDG_DATA_HOME/vulkan/implicit_layer.d
    [ ! -f $XDG_DATA_HOME/vulkan/implicit_layer.d/vkBasalt32.json ] && \
    cat $SCRIPT_PATH/../share/vulkan/implicit_layer.d/vkBasalt32.json.example > $XDG_DATA_HOME/vulkan/implicit_layer.d/vkBasalt32.json && \
    sed -i "s+@lib+$SCRIPT_PATH/../lib32/libvkbasalt32.so+g" $XDG_DATA_HOME/vulkan/implicit_layer.d/vkBasalt32.json && \
    echo "Wrote "$XDG_DATA_HOME"/vulkan/implicit_layer.d/vkBasalt32.json"
    [ ! -f $XDG_DATA_HOME/vulkan/implicit_layer.d/vkBasalt64.json ] && \
    cat $SCRIPT_PATH/../share/vulkan/implicit_layer.d/vkBasalt64.json.example > $XDG_DATA_HOME/vulkan/implicit_layer.d/vkBasalt64.json && \
    sed -i "s+@lib+$SCRIPT_PATH/../lib/libvkbasalt64.so+g" $XDG_DATA_HOME/vulkan/implicit_layer.d/vkBasalt64.json && \
    echo "Wrote "$XDG_DATA_HOME"/vulkan/implicit_layer.d/vkBasalt64.json"
    [ ! -d $XDG_DATA_HOME/vkBasalt ] && \
    mkdir -p $XDG_DATA_HOME/vkBasalt && \
    cat $SCRIPT_PATH/../share/vkBasalt/vkBasalt.conf.example > $XDG_DATA_HOME/vkBasalt/vkBasalt.conf && \
    echo "reshadeTexturePath = "$SCRIPT_PATH"/../share/reshade/textures" >> $XDG_DATA_HOME/vkBasalt/vkBasalt.conf && \
    echo "reshadeIncludePath = "$SCRIPT_PATH"/../share/reshade/shaders" >> $XDG_DATA_HOME/vkBasalt/vkBasalt.conf && \
    echo "Wrote "$XDG_DATA_HOME"/vkBasalt/vkBasalt.conf"

    if [ $# -eq 0 ]; then
      echo "No arguments provided!"
      exit 1
    fi

    # Setup and run
    ENABLE_VKBASALT=1 \
    VKBASALT_SHADER_PATH=$SCRIPT_PATH/../usr/share/vkBasalt/shader \
    exec "$@"
  '';
in multiStdenv.mkDerivation rec {
  pname = "vkbasalt";
  version = "unstable-2020-04-24";

  src = fetchFromGitHub {
    owner = "DadSchoorse";
    repo = pname;
    rev = "d8f363bdbae2e522d8b737701514fd7c3e6e92c7";
    sha256 = "141mjg7b1hy8bzk7dc9v2hqzvmfb1di4z6c1g1bdf6ha6ck2c4k3";
    fetchSubmodules = true;
  };

  shaders = fetchFromGitHub {
    owner = "crosire";
    repo = "reshade-shaders";
    rev = "b7f24f02b06c2d2f8f56cef5094e4221d9781cd6";
    sha256 = "1b6dwlx00k2kghdimyb6gdmc77jkdb3b7hk37g05j9vjndbjmy5z";
  };

  # Huge speedup
  enableParallelBuilding = true;

  buildInputs = [ glslang xorg.libX11 vulkan-headers vulkan-loader pkgsi686Linux.xorg.libX11 ];

  # Prevent homeless error
  preConfigure = "export HOME=$PWD";

  postInstall = ''
    # vkbasalt
    mkdir -p $out/{lib,lib32}
    install -Dm 755 ./build/libvkbasalt64.so $out/lib/libvkbasalt64.so
    install -Dm 755 ./build/libvkbasalt32.so $out/lib32/libvkbasalt32.so
    mkdir -p $out/usr/share/vkBasalt/shader
    install -Dm 644 ./build/shader/*.spv $out/usr/share/vkBasalt/shader
    mkdir -p $out/share/vulkan/implicit_layer.d
    cp $src/config/vkBasalt32.json $out/share/vulkan/implicit_layer.d/vkBasalt32.json.example
    cp $src/config/vkBasalt64.json $out/share/vulkan/implicit_layer.d/vkBasalt64.json.example
    mkdir -p $out/share/vkBasalt
    cp $src/config/vkBasalt.conf $out/share/vkBasalt/vkBasalt.conf.example
    # reshade shaders
    mkdir -p $out/share/reshade/shaders
    cp -r $shaders/Shaders/*.* $out/share/reshade/shaders
    mkdir -p $out/share/reshade/textures
    cp -r $shaders/Textures/*.* $out/share/reshade/textures
    # wrapper
    mkdir -p $out/bin
    cp ${vkbasalt_run} $out/bin/${pname}
  '';

  meta = with multiStdenv.lib; {
    description =
      "A Vulkan post processing layer to enhance the visual graphics of games";
    homepage = "https://github.com/DadSchoorse/vkBasalt";
    license = licenses.zlib;
    maintainers = with maintainers; [ joshuafern ];
    platforms = platforms.unix;
  };
}
