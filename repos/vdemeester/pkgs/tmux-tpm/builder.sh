source $stdenv/setup

echo $out
mkdir -p $out
cp -R $src/* $out/
