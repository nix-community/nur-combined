{ lib, fetchFromGitHub, buildGoPackage, btrfs-progs, go-md2man, utillinux, pkgconfig, libseccomp }:

with lib;
rec {
  containerdGen = { version, sha256 }:
    buildGoPackage rec {
      pname = "containerd";
      name = "${pname}-${version}";

      src = fetchFromGitHub {
        owner = "containerd";
        repo = "containerd";
        rev = "v${version}";
        sha256 = "${sha256}";
      };

      goPackagePath = "github.com/containerd/containerd";

      # FIXME: remove this
      allowGoReference = true;

      outputs = [ "out" "man" ];

      nativeBuildInputs = [ go-md2man utillinux pkgconfig ];

      buildInputs = [ btrfs-progs libseccomp ];

      buildFlags = [ "VERSION=v${version}" ];

      BUILDTAGS = [ ]
        ++ optional (btrfs-progs == null) "no_btrfs";

      buildPhase = ''
        cd go/src/${goPackagePath}
        patchShebangs .
        make binaries $buildFlags
      '';

      installPhase = ''
        for b in bin/*; do
          install -Dm555 $b $out/$b
        done

        make man
        manRoot="$man/share/man"
        mkdir -p "$manRoot"
        for manFile in man/*; do
          manName="$(basename "$manFile")" # "docker-build.1"
          number="$(echo $manName | rev | cut -d'.' -f1 | rev)"
          mkdir -p "$manRoot/man$number"
          gzip -c "$manFile" > "$manRoot/man$number/$manName.gz"
        done
      '';

      meta = {
        homepage = "https://containerd.io/";
        description = "A daemon to control runC";
        license = licenses.asl20;
        maintainers = with maintainers; [ offline vdemeester ];
        platforms = platforms.linux;
      };
    };

  containerd_1_2 = makeOverridable containerdGen {
    version = "1.2.13";
    sha256 = "1rac3iak3jpz57yarxc72bxgxvravwrl0j6s6w2nxrmh2m3kxqzn";
  };

  containerd_1_3 = makeOverridable containerdGen {
    version = "1.3.6";
    sha256 = "1dd7kis8zfns0hc1q4xabwv07b4466wf8wh14c8sgx4rzw184fkw";
  };

  containerd_1_4 = makeOverridable containerdGen {
    version = "1.4.0-beta.1";
    sha256 = "0q5cq42jkdpbxgikkzmvkkxpbjb3hjpv12i431b0z55cqqvc64mw";
  };
}
