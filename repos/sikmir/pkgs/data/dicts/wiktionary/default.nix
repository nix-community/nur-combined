{ callPackage }:

{
  en-ru = callPackage ./base.nix {
    lang = "en-ru";
    version = "2020-11-25";
    sha256 = "0rznkaxfqx5ympb6k2nisa4r9siw7gvmzq208pr46ya0qsz5if7h";
  };

  de-ru = callPackage ./base.nix {
    lang = "de-ru";
    version = "2020-11-27";
    sha256 = "1m40ac8mrvsb7ksm08c0nip1abnjy8jfaj5qad9pm18fpp68b494";
  };

  fi-ru = callPackage ./base.nix {
    lang = "fi-ru";
    version = "2020-11-23";
    sha256 = "0mac6gs437inn3b0q8prq3vm2qw0wnhbyhmlq2g40kxh033hjzc1";
  };

  ru-en = callPackage ./base.nix {
    lang = "ru-en";
    version = "2020-11-21";
    sha256 = "1dw76ak0rcqpb508wqzfsv9xfmjipx07zb212fnj1nhyrvmw388y";
  };

  ru-de = callPackage ./base.nix {
    lang = "ru-de";
    version = "2020-11-21";
    sha256 = "1kw726vq5ghjb17a28m6bqp8jca2pqj5s72g1da00288wy3ccx02";
  };

  ru-uk = callPackage ./base.nix {
    lang = "ru-uk";
    version = "2020-11-21";
    sha256 = "0gx1pjyi24vk02kwmxygb252qgqnw2vqwjaasxlq2s7825nhr8rm";
  };

  ru-eo = callPackage ./base.nix {
    lang = "ru-eo";
    version = "2020-11-21";
    sha256 = "0bfbygk8pflahjil7r4gfdcimp306wx4bbccz92hp2dvdy83sngg";
  };

  ru-fi = callPackage ./base.nix {
    lang = "ru-fi";
    version = "2020-11-21";
    sha256 = "0z6r2mgq9rzlr7rnfxch6h17nj6dj7wbpj2p4hyjd0awnvzc85s2";
  };

  ru-sv = callPackage ./base.nix {
    lang = "ru-sv";
    version = "2020-11-21";
    sha256 = "0123a26xi37wfp5b012v6634mxfdjyxa110bfxsjcpm379slbcnb";
  };
}
