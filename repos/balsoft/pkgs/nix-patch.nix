{ nix-patch, runCommandNoCC, bash, diffutils, coreutils }:
runCommandNoCC "nix-patch" { } ''
  mkdir -p $out/bin
  cp ${nix-patch}/nix-patch $out/bin
  substituteInPlace \
     $out/bin/nix-patch \
    --replace /bin/sh ${bash}/bin/bash \
    --replace diff\  ${diffutils}/bin/diff\  \
    --replace mktemp\  ${coreutils}/bin/mktemp\  \
    --replace mv\  ${coreutils}/bin/mv\  \
    --replace cp\  ${coreutils}/bin/cp\ 
''
