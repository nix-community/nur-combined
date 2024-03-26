{ callPackage }:

let
  mkElectron = callPackage ./generic.nix { };
in
mkElectron "11.5.0" {
  x86_64-linux = "613ef8ac00c5abda425dfa48778a68f58a2e9c7c1f82539bb1a41afabbd6193f";
  x86_64-darwin = "32937dca29fc397f0b15dbab720ed3edb88eee24f00f911984b307bf12dc8fd5";
  i686-linux = "cd154c56d02d7b1f16e2bcd5650bddf0de9141fdbb8248adc64f6d607e5fb725";
  armv7l-linux = "3f5a41037aaad658051d8bc8b04e8dece72b729dd1a1ed8311b365daa8deea76";
  aarch64-linux = "f698a7743962f553fe36673f1c85bccbd918efba8f6dca3a3df39d41c8e2de3e";
  aarch64-darwin = "749fb6bd676e174de66845b8ac959985f30a773dcb2c05553890bd99b94c9d60";
  headers = "1zkdgpjrh1dc9j8qyrrrh49v24960yhvwi2c530qbpf2azgqj71b";
}
