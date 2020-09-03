{ callPackage }:

{
  en-ru = callPackage ./base.nix {
    lang = "en-ru";
    version = "2020-09-02";
    sha256 = "0vqnxb4cs81b5wkhmkwxsyg85mi23sym0dkmxxwky53aksrd14m6";
  };

  de-ru = callPackage ./base.nix {
    lang = "de-ru";
    version = "2020-08-28";
    sha256 = "1pnq7ip4yvcdam2ayvwjqaggb0dfiqdby421q0awm9cfa1pgm6dc";
  };

  fi-ru = callPackage ./base.nix {
    lang = "fi-ru";
    version = "2020-08-31";
    sha256 = "0qxwnw8k97cyffdnh01295niqk6yz4db1gh8izl4mf7y6rapm2r3";
  };

  ru-en = callPackage ./base.nix {
    lang = "ru-en";
    version = "2020-08-21";
    sha256 = "0hzpv0mw03yqz9f8ckx8qhvy6pyzsw6rm42ix36q6f19i1h4qj0g";
  };

  ru-de = callPackage ./base.nix {
    lang = "ru-de";
    version = "2020-08-21";
    sha256 = "0bixh9hky66v7w3xd724k4amzw8p7kgpy1xr7a31126l4mk1dzwl";
  };

  ru-uk = callPackage ./base.nix {
    lang = "ru-uk";
    version = "2020-08-21";
    sha256 = "02rl69iqnvplh1zkdnpq9x12y533c0kzd7869irg1qxw4cwr8pm2";
  };

  ru-eo = callPackage ./base.nix {
    lang = "ru-eo";
    version = "2020-08-21";
    sha256 = "0qhwh8f9qfdgsqrvcpb5n3g20lh9w2k2paqhv4z3lmapsv1f1njb";
  };

  ru-fi = callPackage ./base.nix {
    lang = "ru-fi";
    version = "2020-08-21";
    sha256 = "063hyng3xj1gqjy9fyc7fffs33g0kpwr35y1gqa8kkmb2sfdhwka";
  };

  ru-sv = callPackage ./base.nix {
    lang = "ru-sv";
    version = "2020-08-21";
    sha256 = "0bmd8wlrxs3a3gxwhr6cpxz7rprdy92lppg7rjxn8hixfyc69akj";
  };
}
