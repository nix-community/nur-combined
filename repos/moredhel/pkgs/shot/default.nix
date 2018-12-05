{ pkgs, stdenv, fetchFromGitHub, writeTextFile }:
let script = with pkgs; ''
#!/usr/bin/env sh

set -e

date=$(date +%Y-%m-%d-%H:%M:%S)
filename="screenshot_$date.png"
file_orig="/tmp/$filename"

${gnome3.gnome-screenshot}/bin/gnome-screenshot --area --file="$file_orig"

title="$filename"
if [ $? -ne 0 ]; then exit 1; fi

folder="$(${xdg-user-dirs}/bin/xdg-user-dir 'PICTURES')/Screenshots"
if [ ! -d "folder" ]; then
  mkdir -p "$folder"
fi

f="screenshot_$date.png"
file="$folder/$f"
cp "$file_orig" "$file"
rm "$file_orig"

set +e
# file now saved
# it's okay if some of these fail

${awscli}/bin/aws s3 cp "$file" s3://moredhel-public
echo "https://files.aoeu.me/$f"
echo "https://files.aoeu.me/$f" |  ${xclip}/bin/xclip -selection clipboard
${libnotify}/bin/notify-send "Screenshot Saved" "$f"
'';
in
stdenv.mkDerivation rec {
  name = "shot";
  src = writeTextFile {
          name = "shot";
          text = script;
          executable = true;
          };

  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    echo "$src"
    cp $src $out/bin/shot
    chmod +x $out/bin/shot
  '';

  meta.description = ''A simple Screenshot script.'';
}
