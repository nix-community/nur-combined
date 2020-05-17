self: super: rec {
  # Pytradfri
  pytradfri = super.callPackage ./pytradfri {};
  aiocoap = super.callPackage ./aiocoap {};
  dtlssocket = super.callPackage ./dtlssocket {};
  linkheader = super.callPackage ./linkheader {};

  # testinfra
  testinfra = super.callPackage ./testinfra {};

  # Midi stuff
  rtmidi = super.callPackage ./rtmidi {};
  mido = super.callPackage ./mido {};

  # WLED
  wled = super.callPackage ./wled {};
  cattrs = super.callPackage ./cattrs {};

  # pyps4-2ndscreen
  pyps4-2ndscreen = super.callPackage ./pyps4-2ndscreen {};
}
