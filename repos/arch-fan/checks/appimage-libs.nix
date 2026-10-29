# Fails when an ELF inside a wrapAppImage package needs a shared library that
# neither the AppImage bundles nor its FHS env provides. Such a package builds
# fine but dies at launch with "cannot open shared object file" — e.g. after
# nixpkgs drops a library from appimageTools' defaults. Fix it by adding the
# providing package to the package's `extraPkgs`.
{
  binutils-unwrapped,
  runCommand,
  package,
}:

runCommand "${package.name}-libs" { nativeBuildInputs = [ binutils-unwrapped ]; } ''
  # Bundled libraries can sit anywhere (RUNPATHs vary), FHS ones in /usr/lib64.
  find ${package.contents} -name '*.so*' -printf '%f\n' > provided
  find ${package.fhsenv}/usr/lib64 -maxdepth 1 -name '*.so*' -printf '%f\n' >> provided

  { find ${package.contents} -type f -exec readelf --dynamic {} + 2>/dev/null || true; } |
    sed -n 's/.*(NEEDED).*\[\(.*\)\]$/\1/p' > needed

  missing=$(comm -23 <(sort -u needed) <(sort -u provided))
  if [[ -n $missing ]]; then
    echo "${package.name}: needed libraries missing from the FHS env (add them to extraPkgs):" >&2
    echo "$missing" >&2
    exit 1
  fi
  touch $out
''
