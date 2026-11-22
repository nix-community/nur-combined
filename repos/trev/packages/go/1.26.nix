{
  callPackage,
  go_1_26,
}:

callPackage ./generic.nix {
  go = go_1_26;
  version = "1.26.11";
  hash = "sha256-1EEBsP8n7SpMda1GwXucdDWSCeLrLKfJ32y0/baOGWk=";
}
