{
  runCommand,
  sane-dtmf-generator,
}:
runCommand "sane-dtmf" {
  nativeBuildInputs = [
    sane-dtmf-generator
  ];
} ''
  mkdir dtmf
  for t in 0 1 2 3 4 5 6 7 8 9 A B C D '#' '*'; do
    sane-dtmf-generator "$t" --out dtmf/"$t".wav
  done
  mkdir -p $out/share/sounds
  cp -R dtmf $out/share/sounds/dtmf
''
