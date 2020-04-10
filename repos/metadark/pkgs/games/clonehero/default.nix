{ stdenv, fetchurl, autoPatchelfHook
, alsaLib, gtk2, libXrandr, libXScrnSaver, udev, zlib
}:

let
  name = "clonehero";
in stdenv.mkDerivation rec {
  pname = "${name}-unwrapped";
  version = "0.23.2.2";

  src = fetchurl {
    url = "http://dl.clonehero.net/${name}-v${stdenv.lib.removePrefix "0" version}/${name}-linux.tar.gz";
    sha256 = "0k9jcnd55yhr42gj8cmysd18yldp4k3cpk4z884p2ww03fyfq7mi";
  };

  outputs = [ "out" "doc" ];

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    alsaLib # ALSA sound
    gtk2
    libXrandr # X11 resolution detection
    libXScrnSaver # X11 screensaver prevention
    stdenv.cc.cc.lib
    udev # udev input drivers
    zlib
  ];

  installPhase = ''
    mkdir -p "$out/bin" "$out/share"
    install -Dm755 ${name} "$out/bin"
    cp -r clonehero_Data "$out/share"

    mkdir -p "$doc/share/${name}"
    cp README.txt "$doc/share/${name}"
  '';

  # Patch required run-time libraries as load-time libraries
  #
  # Libraries found with:
  # > strings clonehero | grep '\.so'
  # and
  # > strace clonehero 2>&1 | grep '\.so'
  postFixup = ''
    patchelf \
      --add-needed libasound.so.2 \
      --add-needed libudev.so.1 \
      --add-needed libXrandr.so.2 \
      --add-needed libXss.so.1 \
      "$out/bin/${name}"
  '';

  meta = with stdenv.lib; {
    description = "Clone of Guitar Hero and Rockband-style games";
    homepage = "https://clonehero.net";
    maintainers = with maintainers; [ metadark ];
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
