{ lib
, stdenv
, variant
, jetbrainsPlatforms
}:

with lib;

{ pname
, version

, plugname
, plugid

, buildInputs ? []
, packageRequires ? []
, meta ? {}

, ...
}@args:

let

  defaultMeta = {
    broken = false;
    platforms = variant.meta.platforms;
  } // optionalAttrs ((args.src.meta.homepage or "") != "") {
    homepage = args.src.meta.homepage;
  } // optionalAttrs ((args.src.meta.description or "") != "") {
    description = args.src.meta.description;
  };

in

stdenv.mkDerivation ({
  inherit pname version;

  unpackCmd = ''
    case "$curSrc" in
      *.jar)
        # don't unpack; keep original source filename without the hash
        local filename=$(basename "$curSrc")
        filename="''${filename:33}"
        cp $curSrc $filename
        chmod +w $filename
        sourceRoot="."
        ;;
      *)
        _defaultUnpack "$curSrc"
        ;;
    esac
  '';

  # FIXME: Entirely possible this isn't correct for niche plugins;
  # at the very least there are some plugins that come with JS
  installPhase = ''
    mkdir -p "$out/lib"
    find -iname '*.jar' -exec cp {} "$out/lib/" \;
  '';

  buildInputs = [ ] ++ packageRequires ++ buildInputs;
  propagatedBuildInputs = packageRequires;

  passthru = { inherit jetbrainsPlatforms plugid plugname; };

  doCheck = false;

  meta = defaultMeta // meta;
}

// removeAttrs args [ "buildInputs" "packageRequires" "meta" ])
