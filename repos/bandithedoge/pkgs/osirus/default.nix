{
  pkgs,
  sources,
  rom ? pkgs.lib.warn "Osirus will not function without a Virus B or Virus C ROM file. These files are illegal to share so you must find them on your own. Provide one by installing this package as such: `osirus.override {rom = <path-to-rom-file>;}`" null,
  ...
}:
pkgs.stdenv.mkDerivation {
  pname = "Osirus";
  inherit (sources.osirus-test-console) version;

  nativeBuildInputs = with pkgs; [
    dpkg
    autoPatchelfHook
  ];

  buildInputs = with pkgs; [
    freetype
    alsa-lib
  ];

  unpackPhase =
    map (src: ''
      mkdir -p root
      dpkg-deb --fsys-tarfile "${src.src}" | tar --extract --directory=root
    '') (with sources; [
      osirus-test-console
      osirus-clap
      osirus-lv2
      osirus-vst2
      osirus-vst3
      osirusfx-clap
      osirusfx-lv2
      osirusfx-vst2
      osirusfx-vst3
    ]);

  buildPhase =
    ''
      mkdir -p $out/bin
      cp -r root/usr/local/lib $out
      cp root/usr/local/virusTestConsole $out/bin
    ''
    + pkgs.lib.optionalString (rom != null) ''
      mkdir -p $out/share/osirus
      cp ${rom} $out/share/osirus/osirus_rom.bin

      ln -s $out/share/osirus/osirus_rom.bin $out/bin
      ln -s $out/share/osirus/osirus_rom.bin $out/lib/clap
      ln -s $out/share/osirus/osirus_rom.bin $out/lib/lv2
      ln -s $out/share/osirus/osirus_rom.bin $out/lib/vst
      ln -s $out/share/osirus/osirus_rom.bin $out/lib/vst3
    '';
}
