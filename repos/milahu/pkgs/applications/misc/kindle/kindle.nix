{ pkgs
, lib
, stdenv
, wine
, p7zip
, callPackage
, version ? "1.17.44170"
}:

let
  versions = import ./versions.nix;
in

stdenv.mkDerivation {
  pname = "kindle";
  inherit version;
  src = versions.${version}.src;

  # VeriSign Class 3 Public Primary Certification Authority - G5
  # PEM only. this should work too
  cert = builtins.fetchurl {
    url = "https://github.com/dooglus/intersango/raw/master/cert/facacbc6.0";
    sha256 = "sha256:198rixz2ichmzspss3s6wn4zz44p98cq9al52vks0b037cy0p92a";
  };

  propagatedBuildInputs = [ wine ];
  nativeBuildInputs = [ p7zip ];

  phases = "buildPhase";

  buildPhase = ''
    mkdir -p $out/opt/kindle
    cd $out/opt/kindle
    7z x -y $src
    # -> Kindle.exe

    mkdir -p $out/etc/ssl/certs
    cp -v $cert $out/etc/ssl/certs/facacbc6.0

    mkdir $out/bin
    cat >$out/bin/kindle <<EOF
    #! /bin/sh
    export PATH=$PATH:${wine}/bin

    if ! [ -e /etc/ssl/certs/facacbc6.0 ]; then
      echo FIXME you must sudo and add the SSL certificate /etc/ssl/certs/facacbc6.0
      echo to fix: unable to connect https://bugs.winehq.org/show_bug.cgi?id=50471
      echo please run:
      echo "sudo mkdir -p /etc/ssl/certs/ && sudo ln -s $out/etc/ssl/certs/facacbc6.0 /etc/ssl/certs/facacbc6.0"
      echo "TODO find a better solution with LD_PRELOAD (intercept syscalls: statx, fopen, ...)" \
        "to provide the virtual file /etc/ssl/certs/facacbc6.0"
      exit 1
    fi

    wine $out/opt/kindle/Kindle.exe "\$@"
    EOF
    chmod +x $out/bin/kindle
  '';

  meta = with lib; {
    description = "Amazon ebook reader";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
