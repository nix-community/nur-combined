{
  lib,
  stdenvNoCC,
  substituteAll,
  writeScriptBin,
  fetchurl,
  makeWrapper,
  fastfetch,
  coreutils,
  gawk,
  bash,
  glfIcon ? "GLF" ### Use GLF icon or GLFos icon (to change icon) (How to create an overlay with this expression ?)
}:

### sets the option to two choices (otherwise, throw error)
assert lib.elem glfIcon [ "GLF" "GLFos" ]
  || throw "glfIcon must be either \"GLF\" or \"GLFos\" (got: ${glfIcon})";

stdenvNoCC.mkDerivation rec {
  pname = "GLFfetch";
  version = "0-unstable-2025-09-01"; # Last commit date

  src = fetchurl {
    ### Use srcUrl as a url
    url = "https://framagit.org/gaming-linux-fr/glf-os/app-glf-os/glffetch/-/archive/aa53e020d0da6a67662c62d564240dacf819e189/glffetch-aa53e020d0da6a67662c62d564240dacf819e189.tar.gz";
    sha256 = "sha256-AgUQ4tmH4Wta+HuIvFZc89UHEdZcDiQdZiHsASCgDlE=";
  };

  outputs = [ "out" "assets" ];
  outputsToInstall = outputs;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ fastfetch bash.out coreutils gawk ];

  postPatch = ''
    ### Patch path in upstream archive
    ### *this command uses relative path in this context*

    ### Patch challenge.jsonc
    substituteInPlace challenge.jsonc \
      --replace-warn "~/.config/fastfetch/GLFfetch/GLF.png" "$assets/share/${pname}/${glfIcon}.png" \
      --replace-warn "~/.config/fastfetch/GLFfetch" "$assets/share/${pname}" \
      --replace-warn "󰣇" "" \
      --replace-warn "/bin/bash" "${bash.out}/bin/bash"

    substituteInPlace scripts/challenge.sh \
      --replace-warn "/bin/bash" "${bash.out}/bin/bash" \
      --replace-warn "~/.config/fastfetch/GLFfetch" "$assets/share/${pname}"

    substituteInPlace scripts/completion.sh \
      --replace-warn "/bin/bash" "${bash.out}/bin/bash" \
      --replace-warn "~/.config/fastfetch/GLFfetch" "$assets/share/${pname}"

    substituteInPlace scripts/icon.sh \
      --replace-warn "/bin/bash" "${bash.out}/bin/bash" \
      --replace-warn '"$HOME"/.config/fastfetch/GLFfetch' "$assets/share/${pname}"

    substituteInPlace scripts/install_date.sh \
      --replace-warn "/bin/bash" "${bash.out}/bin/bash" \
      --replace-warn "~/.config/fastfetch/GLFfetch" "$assets/share/${pname}"

    ### Add path to vars.sh
    sed -i '1a PATH="${coreutils}/bin:${gawk}/bin"' scripts/vars.sh

    substituteInPlace scripts/vars.sh \
      --replace-warn "/bin/bash" "${bash.out}/bin/bash"
  '';

  installPhase = ''
    mkdir -p $out/bin $assets/share/${pname}
    mkdir -p $out/share/doc/${pname}

    ### Copy all files
    cp -r . $assets/share/${pname}/

    ### Move some files to doc
    mv $assets/share/${pname}/LICENSE $out/share/doc/${pname}/
    mv $assets/share/${pname}/README.md $out/share/doc/${pname}/

    ### Symlink "assets" output to "out" (to make them accessible to profile that GLFfetch is installed)
    ln -s $assets/share/${pname} $out/share/${pname}

    ${lib.optionalString (glfIcon == "GLFos") ''
      ### Link logo from nix store
      ln -s ${./logo.png} $assets/share/${pname}/${glfIcon}.png
      rm $assets/share/${pname}/GLF.png
    ''}

    chmod +x $assets/share/${pname}/scripts/*.sh

    makeWrapper ${fastfetch}/bin/fastfetch $out/bin/GLFfetch \
      --add-flags "--config $assets/share/${pname}/challenge.jsonc" \
      --set PATH ${lib.makeBinPath [ coreutils gawk ]}
  '';

  meta = {
    description = "A customized neofetch config file built for the GLF Linux challenges (github.com/minegameYTB/GLFfetch-nixos is it's fork)";
    homepage = "https://framagit.org/gaming-linux-fr/glf-os";
    license = lib.licenses.mit;
    mainProgram = "GLFfetch";
  };
}
