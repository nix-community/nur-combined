{ newScope
, pkgs
, requireFile
, rootArchive ? requireFile {
    name = "linux-amd64_deb.tgz";
    message = "Download the cryptopro release first!";
    url = "https://cryptopro.ru/products/downloads/getfastC";
    sha256 = "sha256-e2rTgoKTHK1XviT2z5Zh2W9l7S44V/l2NG1BF7Lw1tg=";
  }
}:

let
  inherit (pkgs) lib;
  self = {
    callPackage = pkgs.newScope (pkgs // self // self.components);
    unpackedTar = self.callPackage
      ({ runCommand }: runCommand "linux-amd64_deb" { } ''
        mkdir $out
        cd $out
        tar --strip-components=1 -xvf ${rootArchive}
      '')
      { };
    symlinkedSources = self.callPackage
      ({ symlinkJoin }: symlinkJoin {
        name = "cprocsp-unpached";
        paths = builtins.attrValues self.unpackedDebs;
      })
      { };
    symlinkedComponents = self.callPackage
      ({ symlinkJoin }: symlinkJoin {
        name = "cprocsp-unpached";
        paths = builtins.attrValues self.components;
      })
      { };
    componentList = self.callPackage
      ({ runCommand, choose }: runCommand "components.nix"
        {
          nativeBuildInputs = [ choose ];
        } ''
        echo '[' > $out
        choose 1 < ${self.unpackedTar}/integrity.sh \
        | grep '.*\.deb' \
        | sed 's|^\([[:alnum:]_-]*[[:alpha:]][[:alnum:]]*\)[_-]\([[:digit:]_\.-]\+[[:digit:]]\).*deb$|{ pname = "\1"; version = "\2"; path = "\0"; }|' \
        | sed 's|^|  |' \
        >> $out
        echo ']' >> $out
      '')
      { };
    sources = import ./components.nix;
    callComponent = { pname, version, path }:
      self.callPackage ./generic.nix { inherit pname version; src = "${self.unpackedTar}/${path}"; };
    components = builtins.listToAttrs
      (builtins.map (x: lib.nameValuePair x.pname (self.callComponent x)) self.sources);
    unpackedDebs = builtins.listToAttrs
      (builtins.map
        (x: lib.nameValuePair x.pname (pkgs.stdenv.mkDerivation {
          inherit (x) pname version;
          src = "${self.unpackedTar}/${x.path}";
          nativeBuildInputs = [
            pkgs.dpkg
          ];
          phases = [ "installPhase" ];
          installPhase = ''
            runHook preInstall
            dpkg-deb -R "$src" $out
            runHook postInstall
          '';
        }))
        self.sources);
  };
in
self
