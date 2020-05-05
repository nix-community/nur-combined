{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

with lib;
rec {
  crcGen =
    { version
    , sha256
    , bundle
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

        goPackagePath = "github.com/code-ready/crc";
        subPackages = [ "cmd/crc" ];
        buildFlagsArray = let t = "${goPackagePath}/pkg/crc/version"; in ''
          -ldflags=
            -X ${t}.crcVersion=${version}
            -X ${t}.bundleVersion=${bundle}
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
  };
  crc_1_10 = makeOverridable crcGen {
    version = "1.10.0";
    sha256 = "11vy42zb2xzhwsgnz17894gfn03knvp2yr094k3zhly6wkxbwbk3";
    bundle = "4.4.3";
  };
}
