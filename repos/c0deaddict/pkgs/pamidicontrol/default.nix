{ lib, fetchFromGitHub, buildGoModule, portmidi }:

buildGoModule rec {
  name = "pamidicontrol";
  version = "master";

  src = fetchFromGitHub {
    owner = "solarnz";
    repo = "pamidicontrol";
    rev = "1c07a4b141b68f241a0ef2cd955c1e5b97f4de30";
    sha256 = "13f6kxkspwj92kfd2zikjvndljdql83c869j8v915bd6wf0f992r";
  };

  buildInputs = [ portmidi ];

  vendorSha256 = null;
  modSha256 = vendorSha256;

  meta = with lib; {
    homepage = "https://github.com/solarnz/pamidicontrol";
    description = "A utility to control the volume of PulseAudio streams / sinks / sources with a midi device.";
    license = licenses.mit;
    maintainers = with maintainers; [ c0deaddict ];
  };
}
