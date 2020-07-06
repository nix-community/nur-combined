{ stdenv, lib, buildGoPackage, buildGoModule, fetchFromGitHub, pkg-config, libvirt, podman, oc_4_4, oc_4_3 }:

with lib;
rec {
  crcGen =
    { version
    , sha256
    , bundle
    , oc
    , crc_driver_libvirt
    , patches
    }: buildGoPackage rec {
      inherit patches;

      pname = "crc";
      name = "${pname}-${version}";

      src = fetchFromGitHub {
        inherit sha256;
        owner = "code-ready";
        repo = "crc";
        rev = "${version}";
      };

      goPackagePath = "github.com/code-ready/crc";
      subPackages = [ "cmd/crc" ];
      buildFlagsArray = let t = "${goPackagePath}/pkg/crc"; in
        ''
          -ldflags=
            -X ${t}/version.crcVersion=${version}
            -X ${t}/version.bundleVersion=${bundle}
            -X ${t}/constants.OcBinaryName=${oc}/bin/oc
            -X ${t}/constants.PodmanBinaryName=${podman}/bin/podman
            -X ${t}/machine/libvirt.MachineDriverCommand=${crc_driver_libvirt}/bin/machine-driver-libvirt
        '';

      meta = with stdenv.lib; {
        homepage = https://github.com/code-ready/crc;
        description = "OpenShift 4.x cluster for testing and development purposes";
        license = licenses.asl20;
        maintainers = with maintainers; [ vdemeester ];
      };
    };

  crc_driver_libvirtGen =
    { version
    , sha256
    , vendorSha256
    ,
    }: buildGoModule rec {
      inherit vendorSha256;
      pname = "crc_driver_libvirt";
      name = "${pname}-${version}";

      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ libvirt ];

      subPackages = [ "cmd/machine-driver-libvirt" ];
      src = fetchFromGitHub {
        inherit sha256;
        owner = "code-ready";
        repo = "machine-driver-libvirt";
        rev = "${version}";
      };
      modSha256 = "${vendorSha256}";

    };


  # bundle is https://storage.googleapis.com/crc-bundle-github-ci/crc_libvirt_4.4.3.zip
  crc_1_9 = makeOverridable crcGen {
    version = "1.9.0";
    sha256 = "1q2jdm847snjj7wqchsik7qpczvx4awgi5rgvw930mm2b635r3aq";
    bundle = "4.3.10";
    oc = oc_4_3;
    patches = [ ./patches/1_9.patch ];
    crc_driver_libvirt = crc_driver_libvirt_0_12_7;
  };
  crc_1_10 = makeOverridable crcGen {
    version = "1.10.0";
    sha256 = "11vy42zb2xzhwsgnz17894gfn03knvp2yr094k3zhly6wkxbwbk3";
    bundle = "4.4.3";
    oc = oc_4_4;
    patches = [ ./patches/1_10.patch ];
    crc_driver_libvirt = crc_driver_libvirt_0_12_7;
  };
  crc_1_11 = makeOverridable crcGen {
    version = "1.11.0";
    sha256 = "1r302qwpmh3wj9lb46fza3swksylm4zrq9jijz56qk9392yxj1v4";
    bundle = "4.4.5";
    oc = oc_4_4;
    patches = [ ./patches/1_11.patch ];
    crc_driver_libvirt = crc_driver_libvirt_0_12_8;
  };
  crc_driver_libvirt_0_12_7 = makeOverridable crc_driver_libvirtGen {
    version = "0.12.7";
    sha256 = "1mv6wqyzsc24y2gnw0nxmiy52sf3lgfnqkq98v8jdvq3fn6lgacm";
    vendorSha256 = "04nnmsvillavcq1wfjc38r7hgq1mx0zhp4anz6q1j78rdcd6aigy";
  };
  crc_driver_libvirt_0_12_8 = makeOverridable crc_driver_libvirtGen {
    version = "0.12.8";
    sha256 = "1ks6vb7276xn4mr2f6d6cg4dhp3mrqgxwr36v0md0fbl6bai6ppk";
    vendorSha256 = "04nnmsvillavcq1wfjc38r7hgq1mx0zhp4anz6q1j78rdcd6aigy";
  };
}
