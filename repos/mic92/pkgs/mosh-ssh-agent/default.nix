{ lib, stdenv, mosh, fetchFromGitHub, fetchpatch }:

mosh.overrideAttrs (old: {
  name = "mosh-ssh-agent-2021-08-13";

  # TODO: incoperate https://github.com/mobile-shell/mosh/pull/1104
  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "mosh";
    rev = "a27e1095536451b323a6096f336a365978044555";
    sha256 = "sha256-XlO2Evcwnimg1ILLm8uzIkePQHZdELIt4qWaT21nMfE=";
  };

  patches = [
    ./ssh_path.patch
  ];

  meta = with lib; {
    description = "Mosh fork with ssh-agent support";
    homepage = "https://github.com/Mic92/mosh";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
  };
})
