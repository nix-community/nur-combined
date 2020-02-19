{ stdenv, fetchurl, writers, sources
, cpio, gcc-arm-embedded, python, qemu, unzip, which }:

stdenv.mkDerivation rec {
  pname = "embox";
  version = stdenv.lib.substring 0 7 src.rev;
  src = sources.embox;
  template = "arm/qemu";

  cjson = fetchurl {
    url = "http://download.embox.rocks/cJSONFiles.zip";
    sha256 = "19qdsfq4r7gjr39lkjplz418gkl2xg5j5fpdz9phlxlbggnklqhd";
  };

  patches = [ ./0001-fix-build.patch ];

  nativeBuildInputs = [
    cpio
    gcc-arm-embedded
    python
    unzip
    which
  ];

  postPatch = ''
    patchShebangs ./mk
    mkdir -p ./download
    ln -s ${cjson} ./download/cjson.zip
  '';

  configurePhase = "make confload-${template}";

  preferLocalBuild = true;

  installPhase = let
    runScript = writers.writeBash "run-embox" ''
      ${qemu}/bin/qemu-system-arm \
        -M integratorcp \
        -kernel @out@/share/embox/images/embox.img \
        -m 256 \
        -net nic,netdev=n0,model=smc91c111,macaddr=AA:BB:CC:DD:EE:02 \
        -netdev tap,script=@out@/share/embox/scripts/qemu_start,downscript=@out@/share/embox/scripts/qemu_stop,,id=n0 \
        -nographic
    '';
  in ''
    mkdir -p $out/bin
    substitute ${runScript} $out/bin/run-embox --subst-var out
    chmod +x $out/bin/run-embox

    install -Dm644 build/base/bin/embox $out/share/embox/images/embox.img
    install -Dm644 conf/*.conf* -t $out/share/embox/conf
    install -Dm755 scripts/qemu/start_script $out/share/embox/scripts/qemu_start
    install -Dm755 scripts/qemu/stop_script $out/share/embox/scripts/qemu_stop
  '';

  meta = with stdenv.lib; {
    inherit (src) description homepage;
    license = licenses.bsd2;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.linux;
  };
}
