{ multiStdenv, lib, fetchFromGitHub, writeShellScript, glslang, xorg
, vulkan-loader, vulkan-headers, pkgsi686Linux }:

multiStdenv.mkDerivation rec {
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

  buildInputs = [
    glslang
    xorg.libX11
    vulkan-headers
    vulkan-loader
    #i686
    pkgsi686Linux.xorg.libX11
  ];

  # Prevent homeless error
  preConfigure = "export HOME=$PWD";

  postInstall = ''
    # reshade shaders
    mkdir -p $out/share/reshade/shaders
    cp -r $shaders/Shaders/*.* $out/share/reshade/shaders
    mkdir -p $out/share/reshade/textures
    cp -r $shaders/Textures/*.* $out/share/reshade/textures

    # vkbasalt
    mkdir -p $out/share/vulkan/implicit_layer.d
    install -dm 755 ./.local/share/vulkan/implicit_layer.d $out/share/vulkan
    cp $src/config/vkBasalt{32,64}.json $out/share/vulkan/implicit_layer.d/
    sed -i 's+@lib+/usr/lib32/libvkbasalt.so+g' $out/share/vulkan/implicit_layer.d/vkBasalt32.json
    sed -i 's+@lib+/usr/lib/libvkbasalt.so+g' $out/share/vulkan/implicit_layer.d/vkBasalt64.json

    mkdir -p $out/{lib,lib32}
    install -Dm 755 ./build/libvkbasalt64.so $out/lib/libvkbasalt.so
    install -Dm 755 ./build/libvkbasalt32.so $out/lib32/libvkbasalt.so

    mkdir -p $out/share/vkBasalt
    cp $src/config/vkBasalt.conf $out/share/vkBasalt/vkBasalt.conf.example
    sed -i 's|*path/to/reshade-shaders/Shaders\*|/usr/share/reshade/shaders|g' $out/share/vkBasalt/vkBasalt.conf.example
    sed -i 's|*path/to/reshade-shaders/Textures\*|/usr/share/reshade/textures|g' $out/share/vkBasalt/vkBasalt.conf.example

    mkdir -p $out/share/vkBasalt/shader
    install -Dm 644 ./build/shader/*.spv $out/share/vkBasalt/shader
  '';

  meta = with multiStdenv.lib; {
    description =
      "a Vulkan post processing layer to enhance the visual graphics of games";
    homepage = "https://github.com/DadSchoorse/vkBasalt";
    license = licenses.zlib;
    maintainers = with maintainers; [ joshuafern ];
    platforms = platforms.unix;
  };
}
