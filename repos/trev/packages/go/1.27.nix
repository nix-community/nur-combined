{
  callPackage,
  go_1_27,
}:

callPackage ./generic.nix {
  go = go_1_27;
  version = "1.27.4";
  hash = "sha256-c8+4VxrsDAEXdofbhxY9Rqog6XeWcncokaoXZU2aYJk=";
}
