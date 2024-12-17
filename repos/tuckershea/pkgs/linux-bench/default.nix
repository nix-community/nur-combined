{
  buildGoModule,
  fetchFromGitHub,
  lib,
  stdenv,
}:
let
  pname = "linux-bench";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "aquasecurity";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-wprsaIe6hgH28yHkSqdHQdFyQMvObQY6hChsfBTviTA=";
  };
  
  cfgDerivation = stdenv.mkDerivation {
    pname = "${pname}-cfg";
    inherit version;

    inherit src;

    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out
      cp -r $src/cfg $out/
    '';
  };
in
buildGoModule rec {
  inherit pname version src;

  vendorHash = "sha256-+Q/GVNKhzytAdw5Ni71bwW/TgFU/oIfd6CkOfWSg2VI=";

  patches = [
    ./linker-writable-default-cfgdir.patch
  ];

  ldflags = [
    "-X main.cfgDir=${cfgDerivation}/cfg"
  ];

  meta = with lib; {
    description = "Checks whether a Linux server according to security best practices as defined in the CIS Distribution-Independent Linux Benchmark";
    homepage = "https://github.com/aquasecurity/linux-bench";
    license = licenses.asl20;
    maintainers = [  ];
    platforms = platforms.linux;
  };
}
