{ stdenv, lib, buildGoPackage, buildGoModule, fetchFromGitHub, pkg-config, libvirt, podman, oc_4_4, oc_4_3 }:

with lib;
rec {
  crcGen =
    { version
    , sha256
    , bundle
    , oc
    }:

    buildGoPackage rec {
      pname = "crc";
      name = "${pname}-${version}";

      src = fetchFromGitHub {
        owner = "code-ready";
        repo = "crc";
        rev = "${version}";
        sha256 = "${sha256}";
      };

      patches = [ ./0001-checkLibvirtEnabled-support-linked-too.patch ];

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

  # bundle is https://storage.googleapis.com/crc-bundle-github-ci/crc_libvirt_4.4.3.zip
  crc_1_9 = makeOverridable crcGen {
    version = "1.9.0";
    sha256 = "1q2jdm847snjj7wqchsik7qpczvx4awgi5rgvw930mm2b635r3aq";
    bundle = "4.3.10";
    oc = oc_4_3;
  };
  crc_1_10 = makeOverridable crcGen {
    version = "1.10.0";
    sha256 = "11vy42zb2xzhwsgnz17894gfn03knvp2yr094k3zhly6wkxbwbk3";
    bundle = "4.4.3";
    oc = oc_4_4;
  };
  crc_driver_libvirt = buildGoModule rec {
    pname = "crc_driver_libvirt";
    name = "${pname}-${version}";

    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ libvirt ];

    subPackages = [ "cmd/machine-driver-libvirt" ];
    src = fetchFromGitHub {
      owner = "code-ready";
      repo = "machine-driver-libvirt";
      rev = "0.12.7";
      sha256 = "1mv6wqyzsc24y2gnw0nxmiy52sf3lgfnqkq98v8jdvq3fn6lgacm";
    };
    modSha256 = "04nnmsvillavcq1wfjc38r7hgq1mx0zhp4anz6q1j78rdcd6aigy";

  };
}
