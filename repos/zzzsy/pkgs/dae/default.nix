{
  lib,
  clang,
  fetchFromGitHub,
  buildGoModule,
}:
let
  metadata = builtins.fromJSON (builtins.readFile ./metadata.json);
in
buildGoModule rec {
  pname = "dae";
  inherit (metadata) version vendorHash;

  src = fetchFromGitHub {
    owner = "daeuniverse";
    repo = pname;
    inherit (metadata) rev hash;
    fetchSubmodules = true;
  };

  proxyVendor = true;

  nativeBuildInputs = [ clang ];

  hardeningDisable = [ "zerocallusedregs" ];

  buildPhase = ''
    make CFLAGS="-D__REMOVE_BPF_PRINTK -fno-stack-protector -Wno-unused-command-line-argument" \
    NOSTRIP=y \
    VERSION=${version} \
    OUTPUT=$out/bin/dae
  '';

  # network required
  doCheck = false;

  postInstall = ''
    install -Dm444 install/dae.service $out/lib/systemd/system/dae.service
    substituteInPlace $out/lib/systemd/system/dae.service \
      --replace-fail /usr/bin/dae $out/bin/dae
  '';

  meta = with lib; {
    description = "A Linux high-performance transparent proxy solution based on eBPF";
    homepage = "https://github.com/daeuniverse/dae";
    license = licenses.agpl3Only;
    platforms = platforms.linux;
    mainProgram = "dae";
  };
}
