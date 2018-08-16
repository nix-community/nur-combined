{ stdenv, fetchurl, buildPackages, perl, fetchgit
, hostPlatform
}:

with stdenv.lib;

let

  common = args@{ rev, sha256, patches ? [] }: stdenv.mkDerivation rec {
    name = "cmpforopenssl-${rev}";

    src = fetchgit {
      url = "https://git.code.sf.net/p/cmpforopenssl/git";
      inherit sha256 rev;
      fetchSubmodules = false;
      deepClone = false;
    };

    patches =
      (args.patches or [])
      ++ [ ./nix-ssl-cert-file.patch ];

    outputs = [ "bin" "dev" "out" "man" ];
    setOutputFlags = false;
    separateDebugInfo = stdenv.isLinux;

    nativeBuildInputs = [ perl ];

    configureScript = "./config";

    configureFlags = [
      "shared"
      "--libdir=lib"
      "--openssldir=etc/ssl"
    ] ;

    makeFlags = [ "MANDIR=$(man)/share/man" ];

    # Parallel building is broken in OpenSSL.
    enableParallelBuilding = false;

    postInstall = ''
      # If we're building dynamic libraries, then don't install static
      # libraries.
      if [ -n "$(echo $out/lib/*.so $out/lib/*.dylib $out/lib/*.dll)" ]; then
          rm "$out/lib/"*.a
      fi

      mkdir -p $bin
      mv $out/bin $bin/

      mkdir $dev
      mv $out/include $dev/

      # remove dependency on Perl at runtime
      rm -r $out/etc/ssl/misc

      rmdir $out/etc/ssl/{certs,private}
    '';

    postFixup = ''
      # Check to make sure the main output doesn't depend on perl
      if grep -r '${buildPackages.perl}' $out; then
        echo "Found an erroneous dependency on perl ^^^" >&2
        exit 1
      fi
    '';


    meta = {
      homepage = https://sourceforge.net/p/cmpforopenssl ;
      description = "A cryptographic library that implements the SSL and TLS protocols";
      platforms = stdenv.lib.platforms.all;
      maintainers = [ stdenv.lib.maintainers.makefu ];
      priority = 0; # resolves collision with ‘man-pages’
    };
  };

in common {
    rev = "462b3";
    sha256 = "1h2k1c4lg27gmsyd72zrlr303jw765x8sscxblq2jwb44jag85na";
  }
