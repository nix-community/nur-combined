{ pkgs }:

with pkgs.lib; rec {
  # Add your library functions here
  #

  # Extension of fetch url that allows chunked fetches
  fetchurlChunked = {chunksize ? 1024 * 1024 * 64, hashes,url,...}@args : with pkgs.lib;
  let
    chunknum = length(hashes);
    fetchurlArgs = removeAttrs args ["chunksize" "chunknum" "hashes"];
    i = range 0 (chunknum - 1);
    d = i :
      let
      min = toString (i * chunksize);
      max = if i == chunknum then "" else toString ((i+1) * chunksize - 1);
      in
      pkgs.fetchurl ({
        name = baseNameOf url + "-" + (toString i);
        sha256 = builtins.elemAt hashes i;
        curlOpts = "-H Range:bytes=${min}-${max} ";
      } // fetchurlArgs);
  in pkgs.runCommand "${baseNameOf url + ".chunked"}" {
    chunks = map d i;
    passthru.original_name = baseNameOf url;
    passthru.useTar = false;
  } ''
    for i in $chunks; do
      printf '%s\n' $i >> $out
    done
  '';

  # Split something into chunks
  splitFile = splitDrv false;
  splitDir = splitDrv true;
  splitDrv = useTar : file : num :
  let numDigits = 3;
  in
    pkgs.runCommand "${file.name}.chunked" rec {
    chunks = builtins.genList (x: "x${fixedWidthNumber numDigits x}") num;
    outputs = ["out"] ++ chunks;
    src = file;
    passthru.original_name = file.name;
    passthru.useTar = useTar;
  } ''
    if [ "${toString useTar}" = "1" ]; then
      tar -cf tmp.tar -C $src .
      src=tmp.tar
    fi
    split -a ${toString numDigits} -d -n ${toString num} $src
    for i in $(find . -iname "x*" -exec basename {} \; | sort); do
      mv $i $(eval echo \$$i)
      printf '%s\n' $(eval echo \$$i) >> $out
    done
  '';

  joinDrv = drv : extraArgs :
    pkgs.runCommand "${drv.original_name}" ({
      preferLocalBuild = true;
      allowSubstitutes = false;
    } // extraArgs) ''
      if [ "${toString drv.useTar}" = "1" ]; then
        mkdir $out
        cat ${drv.out} | xargs cat | tar -xf - -C $out
      else
        cat ${drv.out} | xargs cat > $out
      fi
  '';

  # Obtain the runtime closure of a derivation's build-time:
  buildDeps = pkg: let
      drv = builtins.readFile pkg.drvPath;
      storeDirRe = lib.replaceStrings [ "." ] [ "\\." ] builtins.storeDir;
      storeBaseRe = "[0-9a-df-np-sv-z]{32}-[+_?=a-zA-Z0-9-][+_?=.a-zA-Z0-9-]*";
      re = "(${storeDirRe}/${storeBaseRe}\\.drv)";
      inputs = lib.concatLists (lib.filter lib.isList (builtins.split re drv));
    in map import inputs;

}

