{
  runCommand,
  vaculib,
  python,
}:
runCommand "types-dnspython" { passthru.pythonModule = python; } ''
  declare dir="$out/${python.sitePackages}"
  mkdir -p "$dir"
  cp -T -r -- ${vaculib.path ./dns-stubs} "$dir/dns-stubs"
''
