{ stdenv, fetchFromGitHub, glibc, python, kernel }:
let
  makeFlags = "DESTDIR= PREFIX=$(out)";  # is this not standard?
  buildModule =
  { name, src, kernel, postUnpack }:
  stdenv.mkDerivation {
    inherit name src postUnpack;

    hardeningDisable = [ "pic" ];

    KERNELDIR = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";

    INSTALL_ROOT = "\${out}";

    nativeBuildInputs = kernel.moduleBuildDependencies;
  };
  src = fetchFromGitHub {
    owner = "JohnAZoidberg";
    repo = "linux-okernel-components";
    rev = "2921e8da757e451a54517297991bf70e8b427985";
    sha256 = "0ylwz9yw16jb6d12xbfq9hncw30h12ds5y16vb4rcdv2vpq8f4lc";
  };
in
rec {
  userspace-tools = stdenv.mkDerivation {
    inherit src makeFlags;
    name = "okernel-userspace-tools";

    postUnpack = "sourceRoot=\${sourceRoot}/userspace_tools/";

    nativeBuildInputs = [ glibc.static ];
  };
  cve-201608655 = stdenv.mkDerivation {
    inherit src;
    name = "cve-201608655";

    postUnpack = "sourceRoot=\${sourceRoot}/test_mappings/exploits/CVE-2016-8655/";

    buildPhase = ''
      gcc chocobo_root.c -lpthread -o chocobo_root
    '';

    installPhase = ''
      mkdir -p $out/bin
      mv chocobo_root $out/bin/
    '';
  };
  cve-2017-7308 = stdenv.mkDerivation {
    inherit src;
    name = "cve-201608655";

    postUnpack = "sourceRoot=\${sourceRoot}/test_mappings/exploits/CVE-2017-7308/";

    buildPhase = ''
      gcc original_poc.c -o original_poc
    '';

    installPhase = ''
      mkdir -p $out/bin
      mv original_poc $out/bin/
    '';
  };
  kvc = stdenv.mkDerivation {
    inherit src makeFlags;
    name = "kvc";

    postUnpack = "sourceRoot=\${sourceRoot}/test_mappings/protected-mem/kvc/";
  };
  pvm = stdenv.mkDerivation {
    inherit src makeFlags;
    name = "pvm";

    postUnpack = "sourceRoot=\${sourceRoot}/test_mappings/protected-mem/pmc/";
  };
  smep = stdenv.mkDerivation {
    inherit src makeFlags;
    name = "smep";

    postUnpack = "sourceRoot=\${sourceRoot}/test_mappings/smep/";
  };
  user-mem-track = stdenv.mkDerivation {
    inherit src makeFlags;
    name = "user-mem-track";

    postUnpack = "sourceRoot=\${sourceRoot}/test_mappings/user-mem-track/";
  };
  kvmod = buildModule {
    inherit kernel src;
    name = "kvmod";

    postUnpack = "sourceRoot=\${sourceRoot}/test_mappings/protected-mem/kvmod/";
  };
  kwriter = stdenv.mkDerivation {
    inherit src;
    name = "kwriter";

    postUnpack = "sourceRoot=\${sourceRoot}/test_mappings/kwriter/";

    hardeningDisable = [ "pic" ];
    buildInputs = [ python ];

    KERNELDIR = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
    INSTALL_ROOT = "\${out}";

    nativeBuildInputs = kernel.moduleBuildDependencies;

    installPhase = ''
      mkdir -p $out/bin
      mv chkresults $out/bin/
      chmod +x $out/bin/chkresults

      make install
    '';
  };
  oktest-init = buildModule {
    inherit kernel src;
    name = "oktest-init";

    postUnpack = "sourceRoot=\${sourceRoot}/test_mappings/oktest-init/";
  };
  vsys-update = buildModule {
    inherit kernel src;
    name = "vsys-update";

    postUnpack = "sourceRoot=\${sourceRoot}/test_mappings/vsys-update/";
  };
}
