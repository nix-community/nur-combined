{lib, stdenv, fetchurl, buildProjectGenerator ? false,
pkg-config, bash,
opencv, gcc, openal, glew, freeglut, freeimage, gst_all_1,  
cairo, libudev0-shim, freetype, fontconfig, libsndfile, curl, libcardiacarrest, alsaLib, udev,
boost, uriparser, rtaudio, xorg, libraw1394, libdrm, openssl, libusb1, gtk3, assimp, glfw, pugixml,
poco,
...}:
let
  version = "v0.11.0";
in
stdenv.mkDerivation {
  name = "openframeworks-${version}";
  
  src = fetchurl {
    url = "https://openframeworks.cc/versions/${version}/of_${version}_linux64gcc6_release.tar.gz";
    sha256 = "1cb9mv1zn9pgdjky1vnxg8yzypqld6cg0all3bf9zrw1w0yfwg2i";
  };
  
  buildInputs = [
  	pkg-config 
  	gst_all_1.gstreamer gst_all_1.gst-plugins-base gst_all_1.gst-plugins-bad gst_all_1.gst-plugins-good gst_all_1.gst-plugins-ugly gst_all_1.gst-libav opencv gcc openal glew freeglut freeimage
  	cairo libudev0-shim freetype fontconfig libsndfile curl libcardiacarrest alsaLib udev
  	boost uriparser rtaudio xorg.libXmu xorg.libXxf86vm libraw1394 libdrm openssl libusb1 gtk3 assimp glfw pugixml
  	poco
  ];
  
  unpackPhase = ''
    mkdir -p $out/
    tar -xzf $src -C $out/ --strip-components 1
  '';
  
  patchPhase = ''
  	sed -i -E 's/ADDON_PKG_CONFIG_LIBRARIES =(.*)opencv\s/ADDON_PKG_CONFIG_LIBRARIES =\1opencv4 /g' $out/addons/ofxOpenCv/addon_config.mk;
  	sed -i -E 's/ADDON_PKG_CONFIG_LIBRARIES =(.*)opencv$/ADDON_PKG_CONFIG_LIBRARIES =\1opencv4/g' $out/addons/ofxOpenCv/addon_config.mk;
  	
  	sed -i -E 's/#include "RtAudio\.h"/#include "rtaudio\/RtAudio\.h"/' $out/libs/openFrameworks/sound/ofRtAudioSoundStream.cpp;
  	
  	substituteInPlace $out/scripts/linux/compileOF.sh --replace "/usr/bin/env bash" "${bash}/bin/bash"
  	${if buildProjectGenerator then "" else "#"}substituteInPlace $out/scripts/linux/compilePG.sh --replace "/bin/bash" "${bash}/bin/bash"
  '';
  
  dontConfigure = true;
  
  buildPhase = ''
    cd $out
    $out/scripts/linux/compileOF.sh -j $NIX_BUILD_CORES
    ${if buildProjectGenerator then "" else "#"}$out/scripts/linux/compilePG.sh -j $NIX_BUILD_CORES
  '';
  dontInstall = true;
  dontFixup = true;

  meta = {
    description = "A toolkit for graphics and computational art.";
    longDescription = ''
      Don't install it to your nix profile; it *just can't* be installed.
      To set it up for development use:
      - nix-build it to a safe place in your home folder: 
        mkdir -p ~/opt/; nix-build '<nixpkgs>' -A nur.repos.cwyc.openframeworks -o ~/opt/openframeworks
      - Install Qt Creator
      - Run the script to install the Qt Creator plugin to your ~/.config folder:
        [OF DIRECTORY]/scripts/qtcreator/install_template.sh
      - Create a new openframeworks project in Qt Creator. When prompted for your openframeworks folder, selected where you placed it.
      A cleaner package bundled with qtcreator is in the works.
    '';
    homepage = "https://openframeworks.cc/download/";
    license = stdenv.lib.licenses.mit;
    meta.platforms = stdenv.lib.platforms.linux;
  };
}