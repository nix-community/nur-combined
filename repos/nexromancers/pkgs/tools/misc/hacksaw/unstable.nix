import ./generic.nix ({ lib,
... } @ args: self: super: {
  pname = "${super.pname}-unstable";
  version = "2020-05-02";

  src = super.src // {
    rev = "115bb30c870ff19a03a0a101e145ad8a822193e2";
    sha256 = "0ncyr0rw9f4bnvxcq6i8vkgj0ixg060inrssbwz4y3nq9nakbp61";
  };

  cargoSha256 = "13pgj1azsz6p74yrxjwsf28mn0cginw5rg0ricv69zzwlmy2wkji";
})
