{ lib, stdenv, fetchurl, libtool, pkgconfig, libgcrypt, tpm2-tss, openssl, curl, pandoc,
  python36, file
}:
stdenv.mkDerivation rec {
  version = "3.1.2";
  name = "tpm2-tools-${version}";

  src = fetchurl {
    url = "https://github.com/tpm2-software/tpm2-tools/releases/download/${version}/tpm2-tools-${version}.tar.gz";
    sha256 = "1532yg75znkwwzrljvi818ajc8d25di602dp6kfqqkbv4hmnq4w0";
  };

  buildInputs = [
    libtool pkgconfig
    tpm2-tss
    openssl libgcrypt
    curl.dev

    pandoc
    (python36.withPackages(ps: with ps; [ pyyaml ]))
  ];

  preConfigure = ''
    substituteInPlace configure --replace "/usr/bin/file" "${file}/bin/file"
  '';

  # TODO enable unit tests

  meta = {
    homepage = https://github.com/tpm2-software/tpm2-tools;
    description = "The source repository for the TPM (Trusted Platform Module) 2 tools";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.johnazoidberg ];
  };
}
