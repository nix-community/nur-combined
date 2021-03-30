{ lib
, stdenv
, fetchFromGitHub
, fetchurl
, writers
, cpio
, gcc-arm-embedded
, python
, qemu
, unzip
, which
, template ? "arm/qemu"
}:
let
  cjson = fetchurl {
    url = "mirror://sourceforge/cjson/cJSONFiles.zip";
    sha256 = "19qdsfq4r7gjr39lkjplz418gkl2xg5j5fpdz9phlxlbggnklqhd";
  };

  runScript = writers.writeBash "run-embox" ''
    ${qemu}/bin/qemu-system-arm \
      -M integratorcp \
      -kernel @out@/share/embox/images/embox.img \
      -m 256 \
      -net nic,netdev=n0,model=smc91c111,macaddr=AA:BB:CC:DD:EE:02 \
      -netdev tap,script=@out@/share/embox/scripts/qemu_start,downscript=@out@/share/embox/scripts/qemu_stop,id=n0 \
      -nographic
  '';
in
stdenv.mkDerivation rec {
  pname = "embox";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "embox";
    repo = "embox";
    rev = "v${version}";
    sha256 = "0lvlmw60ab3n48cqb857phsvw9mpc5qfva4dw7wyilgs635x567c";
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

  installPhase = ''
    mkdir -p $out/bin
    substitute ${runScript} $out/bin/run-embox --subst-var out
    chmod +x $out/bin/run-embox

    install -Dm644 build/base/bin/embox $out/share/embox/images/embox.img
    install -Dm644 conf/*.conf* -t $out/share/embox/conf
    install -Dm755 scripts/qemu/start_script $out/share/embox/scripts/qemu_start
    install -Dm755 scripts/qemu/stop_script $out/share/embox/scripts/qemu_stop
  '';

  meta = with lib; {
    description = "Modular and configurable OS for embedded applications";
    homepage = "http://embox.github.io/";
    license = licenses.bsd2;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    skip.ci = true;
  };
}
