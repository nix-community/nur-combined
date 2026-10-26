{
  # keep-sorted start
  dependencyRoot ? null,
  pname,
  src,
  # keep-sorted end
}:
''
  mkdir -p "$out/share/doc/${pname}"
  install -m644 ${src}/LICENSE ${src}/THIRD_PARTY_NOTICES.md ${src}/native/render/fonts/JetBrainsMono-OFL.txt "$out/share/doc/${pname}/"
  ln -s ${src} "$out/share/doc/${pname}/source"
  cat > "$out/share/doc/${pname}/SOURCE.md" <<'EOF'
  # Corresponding source

  Albedo's own code is licensed under the Mozilla Public License 2.0 (LICENSE).
  Third-party components retain their own licenses (THIRD_PARTY_NOTICES.md).

  The adjacent source symlink contains the complete, unmodified upstream source
  used for this package, including dependency lockfiles and build instructions.
  Exact upstream revision: ${src.rev}
  Source store path: ${src}
  Retrieve the same revision independently:

      git clone https://tangled.org/okami.mom/albedo
      git -C albedo checkout ${src.rev}

  NUR packaging expressions are in pkgs/albedo-git at
  https://github.com/adam01110/nur (use the revision that built this package).
  When redistributing binaries, include this source store path (for example,
  nix copy --to DESTINATION ${src}) or provide the corresponding source alongside
  them; do not rely solely on a moving branch or on a local store path surviving.
  EOF
''
+ (
  if dependencyRoot == null
  then ""
  else ''
    mkdir -p "$out/share/doc/${pname}/dependencies"
    (
      cd "${dependencyRoot}"
      while IFS= read -r -d "" notice; do
        install -Dm644 "$notice" "$out/share/doc/${pname}/dependencies/$notice"
      done < <(find . -type f \( -iname 'license*' -o -iname 'copying*' -o -iname 'notice*' -o -iname 'copyright*' \) -print0)
    )
  ''
)
