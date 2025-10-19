{
  lib,
  stdenv,
  pins,
  python3,
}:
stdenv.mkDerivation rec {
  pname = "switch-dbibackend";
  version = "486";

  src = pins.switch-dbibackend.outPath;

  buildInputs = [
    (python3.withPackages (
      ps: with ps; [
        pyusb
        tkinter
      ]
    ))
  ];

  installPhase = ''
    mkdir -p $out/bin/
    cp dbibackend $out/bin/
    chmod +x $out/bin/dbibackend
    patchShebangs $out/bin
  '';

  meta = with lib; {
    description = "The ultimate solution to install `NSP`, `NSZ`, `XCI` and `XCZ` and work with Nintendo Switch";
    longDescription = ''
      The ultimate solution to install `NSP`, `NSZ`, `XCI` and `XCZ` and work
      with Nintendo Switch. Supports installation over MTP, USB, http (from
      your personal server), external USB and more. Support for viewing images
      in `jpg`, `png` and `psd` formats. Support for working with `zip` and
      `rar` archives, as well as with `cbr`/`cbz` containers. Support for text
      files, plain text view and hex view. Can be used as a file manager (copy,
      move, delete files and folders, create folders). Work with saves
      (including backup and restore) and much more.
    '';
    homepage = "https://github.com/rashevskyv/dbi";
    maintainers = with maintainers; [ arobyn ];
    platforms = [ "x86_64-linux" ];
  };
}
