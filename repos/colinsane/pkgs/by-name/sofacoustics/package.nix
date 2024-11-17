{
  fetchurl,
  lib,
  newScope,
  nix-update-script,
  runCommandLocal,
  stdenvNoCC,
  symlinkJoin,
}:
lib.recurseIntoAttrs (lib.makeScope newScope (self: with self; {
  updateWithSuper = false;  #< don't update datasets unless user explicitly asks for that, because there are *so many*, and unchanging

  downloadSofacoustics = prefix: database: name: hash: stdenvNoCC.mkDerivation (finalAttrs: {
    name = "${database}-${name}";
    src = fetchurl {
      url = "${prefix}${name}.sofa";
      name = "${database}-${name}";
      inherit hash;
    };

    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/share/libmysofa
      cp $src $out/share/libmysofa/${database}-${name}.sofa
    '';
    doBuild = false;

    preferLocalBuild = true;
    # this update script is pretty useless -- except that it lets me auto-generate the hashes
    passthru.updateScript = nix-update-script {
      extraArgs = [ "--version" "skip" ];
    };
    passthru.asDefault = runCommandLocal "${database}-${name}-as-default" {} ''
      mkdir -p $out/share/libmysofa
      ln -s "${finalAttrs.finalPackage}/share/libmysofa/${database}-${name}.sofa" $out/share/libmysofa/default.sofa
    '';
  });

  ari = lib.recurseIntoAttrs (lib.mapAttrs (downloadSofacoustics "https://sofacoustics.org/data/database/ari/hrtf%20" "ari") {
    # in-the-ear measurements from real human subjects, complete with detailed anthropometric data.
    # - <https://www.oeaw.ac.at/fileadmin/Institute/ISF/IMG/software/readme.pdf>
    # - <https://www.sofaconventions.org/mediawiki/index.php/Files#Standard_(in-the-ear_canal)_HRTFs_of_humans>
    # - anthropometrics: <https://www.oeaw.ac.at/fileadmin/Institute/ISF/IMG/software/anthro.mat>
    # "hrtf, dtf: HRTFs and DTFs, respectively, equalized between 300 Hz and 18 kHz"
    # "hrtf b/c/d, dtf b/c/d: HRTFs and DTFs, equalized between 50 Hz and 18 kHz for hi-fi auralizations ("b" vs. "c" and "d" differ each other in their starting positions and the order of measurement positions: b: 0°→0°, c/d: 270°→270°; subject being rotated clockwise ↻; "c" measurements were recorded until 2023 in the ARI lab in Wohllebengasse, "d" measuremens are recorded in the new ARI lab in Postsparkasse since 2024)."

    b_nh2 = "sha256-+4EDf8Mn/RRUzuXaqj3bjKgIQGNFx1Pkxr8X211TzfM=";
    b_nh4 = "sha256-OtBsa5OWymBOlfqYM8oKkm9CeCO/1rWgmEX0H3T+zUM=";
    b_nh5 = "sha256-M+9YHle9vZgZSeLn+77w1bRDF8eQZ/N4kZhYPsJin0E=";
    b_nh8 = "sha256-Oe9W6cUt6kANq/F9H45bDjZ3a0AgEyyYqzjoatMcx08=";
    b_nh10 = "sha256-1PGp0w8G0dOi4qlHNYzT1nMLLT0mZOlTIrPPGIR4Phs=";
    b_nh11 = "sha256-fk8qufFFFhoIDJCnew0AKR5httn9hnaY8v5qOBLi9g8=";
    b_nh12 = "sha256-yzQLHq7OJkpBDUNJepyMZ0jCNuUOQn1fvuXkY9FcQlw=";
    b_nh13 = "sha256-ex2pU7XB8EKZB01jBLg5xsSMK97uHrXfmmOHpn5Coe4=";
    b_nh14 = "sha256-QyQZPLZInwhmL2lSKwbHLzOFbL6Wg+gUTzcJxdT6bHY=";
    b_nh15 = "sha256-wlapIVqpwBuGwS8ehaAAUOPLN3R1ETkIi7NRRAufEe8=";
    b_nh16 = "sha256-kSufYAxyTxwHI0RMmIFw/+Y6YxZe6xnHv66egRa3tJ8=";
    b_nh17 = "sha256-Dvbe7+p8mqIFdqarwsj5fnk18A63gb0R1YJ87EBHY9Q=";
    b_nh18 = "sha256-Lquu4S265wN6FEK1pZED0vmqwIRAShp4uYwhLiaHpM4=";
    b_nh19 = "sha256-uhjQHraenubvFU0sav31n0P6klxP4OE9uhwP5GD4+Ro=";
    b_nh21 = "sha256-MAKU5CSgjJOsBWDZalZ78OtWbjjjgYZZJfaQCWHpEkY=";
    b_nh22 = "sha256-Yx7xKNxYLQ3QU3HsODFDfiuEJ3XOOVPFfbBgfIL2bOY=";
    b_nh25 = "sha256-bPFACZS+ry0LK/IREc+bcz74O241tjE6KYwK1TWC3xM=";
    b_nh27 = "sha256-Jb5QI5vCpmCiqqqQGMQ7kq+rn7dNZw2Kyi+Y1heaED0=";
    b_nh28 = "sha256-7pdwN6+q0q9ScYaC61mn+zNTxKzNnGzUxxPrQ+6B3Dg=";
    b_nh29 = "sha256-zqHxKEz5b7xxXOFAX1fftACPhyVsAXpx0CzLGMD8joM=";
    b_nh30 = "sha256-VBzW36FWhGviMlQUpHkSWERxuZnZDdE2nxP55mXSOHU=";
    b_nh31 = "sha256-BrLyX7L1sQX55kEE7nFl0ytnyvsHBZVR/zhU7PpfJBQ=";
    b_nh32 = "sha256-xAgEM0q8cb+qlKvHfvN+n26hluZCG1+9nV1ry1ybFRw=";
    b_nh33 = "sha256-60R41sIFKqUPApuxtIXzNVfaH91mqtq16E2v+hOBkzM=";
    b_nh34 = "sha256-flr+hPEIFf2KcQlE4aQB7ZIadyte/nB3BnMjcnQHy1A=";
    b_nh35 = "sha256-k3C2HSVKMvSWxeEmY87hGGAPCKhDOHh2Y0wf8OrO24U=";
    b_nh36 = "sha256-BfWbyMb7X+NTwJwo+Ylxg+/Bdy6mGSrXXRfpOvyZYEI=";
    b_nh38 = "sha256-kqSimiQA3A6wGh91ivcK+8EUiFCeA6YYiD1wWq16XR0=";
    b_nh39 = "sha256-gTd3CTo/6nwRYbgYXPIIavzNsAvaO2IkEHy49I1CMjY=";
    b_nh40 = "sha256-QoCmeDQgJU3jymaoNnHsKJ6oYJk9cFvaIwFfjhyZ9Kc=";
    b_nh41 = "sha256-iEoAOLhxQ7SpiYmPIX9jIMMmb0y00X6WK5BGHy1/lH8=";
    b_nh42 = "sha256-pcBUvmJGGZSotpCK03F4ySiPuvO1c96TVspa+ixeym8=";
    b_nh43 = "sha256-DNd9YXfkXzzVsut8B3IGqtXyAIxHfs8hPczi4Oa6AMg=";
    b_nh46 = "sha256-DWymzXYJMrDhAFpRIUepI1FVm2xYJ+epqZFHIRsfHqM=";
    b_nh47 = "sha256-0v1Pl8eJ45WRFs2XiP/7Ew0tOE4Ejd3ut2K8EQd8hRI=";
    b_nh52 = "sha256-UA20Un5UJj102KzpMkqP9taMQ60aq3lIoRO+yHpSM5M=";
    b_nh53 = "sha256-4YI3C4v+3Uh99oFFWsT2ApXJFhlUHaSDkL09y74HOgA=";
    b_nh54 = "sha256-9SEHtxnbewvwMxHqe5CBT0SGSPzQNxWzA9hiaRkSl2o=";
    b_nh55 = "sha256-Uh5cqTR8lpkNtVn3VVxjWnzXk002CtF21VsddbbkcYg=";
    b_nh56 = "sha256-dPrkAvcVQEjFWPwJBAC1bc5JMoKyGq+H3UFoGyRJ6Js=";
    b_nh57 = "sha256-EeoMh5jRYmwPrGOqsNYD7enVxdXHhu5+Sajvzpo0FJM=";
    b_nh58 = "sha256-0+aV/1vt5YtC1aJjgfvyqdRrtTKvBRLF8lN4qAiE46c=";
    b_nh59 = "sha256-09ANGT2LgYSrZ2CwOnqTKOEBcVUE1rSop6XLNMan074=";
    b_nh60 = "sha256-eEuApICw5vCG5IH9m6bM28TGzwl8zyXIlV4OjHCcZbQ=";
    b_nh61 = "sha256-Ieo1ta1U0hVXgCmadWS6foeJAIQiX7mk722i9wxE2jU=";
    b_nh62 = "sha256-sOGGnJaRoCFJnENDztg1XVq5jje+jkvUd+2snYTKAU8=";
    b_nh63 = "sha256-zNa8bhBqtinMhp16N53G5e90jg0xk6Sm8LNtrETEDtY=";
    b_nh64 = "sha256-zUnOYRZcHHSJ2Gjs093LsWUTE+VKfEWUiv+uoqDst2k=";
    b_nh65 = "sha256-Y+USEjf186yzaPEncHzHYymKcbVwIE3OGVmQiMezbK4=";
    b_nh66 = "sha256-tEohtuGvweY20hyfWBi15niKBHrHfaZ+jp+FjkLtO5E=";
    b_nh68 = "sha256-+lf8735UDOOfj0bzQC0Qm+uANwQHPfWY2mVtemJZzzo=";
    b_nh70 = "sha256-FtzwFi44Gc8xHnbShHgMQxiTOGASlbmHVxrE/Ewkkt8=";
    b_nh71 = "sha256-7+yxCDI/fE537+14g2bQm5h6aCGoRcyke2JBgW0doCA=";
    b_nh72 = "sha256-X53s5Xq4HntyE+J4bWvCMKYAKJel+kvCHiWT3HPSWiQ=";
    b_nh74 = "sha256-/VdJXUp/0gn0+posUpcP/yl4sG7rwb3dIItHLQW8EFs=";
    b_nh89 = "sha256-9p+e4pScvvNwYPSFcI+bW5UUKJ6e4P5Y77cxPzjsAy4=";
    b_nh90 = "sha256-p1CIJS9aJ+zfepQlINsTvGARUKGnD/8VjznAHSArkfw=";
    b_nh91 = "sha256-md6khrpOmDzD4FKHCBsOSeTludI9bX2hQHYEzLimJxo=";
    b_nh92 = "sha256-E0FM0SD43doYSYLeo+KjoFrZgQbP/i+7iRRpcM+C3/g=";
    b_nh93 = "sha256-oFjvG5P9CsuA9NqihfRG3rZ1t9QFGGe4R6CHPWghdqM=";
    b_nh94 = "sha256-fZ8Tuw0OgGT2TLaGjLFyNvS3lab9XsDViuGBSzNRUb8=";
    b_nh95 = "sha256-hRlOodsgeOg0L9FAmxsQclYFagtUweqnTl3q0kh56jE=";
    b_nh96 = "sha256-xpec5uUfr2/ZxI7HFLo1vknsivfzB26bRha8P5m8BRw=";
    b_nh102 = "sha256-IWRCAAqh2LqL8dijXpPWBKK63EY7rYnQu8jX9y7VtJ8=";
    b_nh103 = "sha256-ghse5OIYPxrwdV5TKvZK0aAxcLQy/26uzKrj0b5a6vo=";
    b_nh104 = "sha256-XZ9ps+s+CGkfhNN7TgOKENty5QjTq1C7bq3JCT8xpRk=";
    b_nh110 = "sha256-M/FypprTC2sdi2JtVfdKKPNtidv4ItYVfMwkT/c1L+4=";
    b_nh111 = "sha256-2BjGkMTdJQoHe6hlEE3Ej1lgLW/U5qaj8pn62fJRaZY=";
    b_nh115 = "sha256-v+aKSnzTSHag6KU+6/wLPd+uKCJwERiwq6MiXN0KW14=";
    b_nh120 = "sha256-IVSqoe53hfVGS+ztwCaFh+/rTuYnJQLzPHbTh+l+YoU=";
    b_nh122 = "sha256-recRTBmflNaMNxRHERBIqXXkjQoNXUeEDH5ZKecbxVI=";
    b_nh123 = "sha256-0di5CKWTHOZX6KdeeQdQ3cZQkZuP8APQV2COt7tjdKE=";
    b_nh128 = "sha256-DifhdR97z1B30rnLMYcU+2hEviJvZCbvtQVmZcxWYiM=";
    b_nh129 = "sha256-xkMGb6jUpOd79p7b5saifgtmhIUBQZFXHhAHOndq7Lw=";
    b_nh130 = "sha256-hLCpqCxNUx0+FexZrREhZ3r/IulIkuTRExly3X7LqTg=";
    b_nh131 = "sha256-EE+SmIp2FXqTlv8F7ewoaYjLKs2PTP3+vhU9R7+rt1k=";
    b_nh132 = "sha256-IxsCtBh7Hj6emK2sOi6frOJGC8WrhKcxnZ2JoVZ3jp0=";
    b_nh133 = "sha256-vM0X0KsaqyLo6zmXKjBK9DuiiVId/rTS6+z1FCG8juM=";
    b_nh134 = "sha256-z4/gHjKNUebc7xYLWXvbMmoqQy5MTB+es8K82tthynI=";
    b_nh135 = "sha256-2n86K0PHRnOAs3IrtRf5owl7ub8DqtjzLM+MeiVeSbw=";
    b_nh136 = "sha256-nl3uUOTxaoqaKKfsAHL/2ItNuFArdAp4MyiXpWNnypM=";
    b_nh137 = "sha256-1b9rM3ZJXNKDP3l8YjvsgkzXHpiX9ojVXctDyyQDuXg=";
    b_nh138 = "sha256-UV0B7JsXjWP7JiTfnQedLNeFakTVFrC5DBqEobNMs4g=";
    b_nh139 = "sha256-c14fbM9E37toMs9t521e6pr0AU9uK1SvQYmxxDNzvI0=";
    b_nh140 = "sha256-tOCFgWOGBgK08WnbcVy3bRs93aD1Y79TRDba3AH+liA=";
    b_nh143 = "sha256-ewfKhphyI23ABVBREbYOLiVMZzN4X91UwKI4TPWGrlg=";
    b_nh146 = "sha256-VIV5n1jF4DCJpcjwlmlMuwckzOMWTuV9SxkRGVuDMjY=";
    b_nh154 = "sha256-KWav5y7Du10zJYxh/NM0YPttTEI33m64+q+oss+7xUQ=";
    b_nh156 = "sha256-raqe+5ntVr//xOnJG30NojpF5+6uq/dAxO0U9Z0x3k8=";
    b_nh157 = "sha256-Emy1CwM/ACypX2Yuz/PS4uNRcmru1o1NyWqK9eNPVM0=";
    b_nh158 = "sha256-VKEG/CKntuLjpVtyqZvuUeE1/iHag+52VKHcHElgSjA=";
    b_nh159 = "sha256-3dzk9oAK/PtCXDTrrtVICsSJaoIQjmd9NLJpUZkSuQg=";
    b_nh160 = "sha256-AYBKV26h8JRVBxhYQGL54N37pTS+U0BG4V3cFUtbv7s=";
    b_nh161 = "sha256-SRGs4o9g6bl1ffaqQIaFsYFKTE+Tpa5uKhrtjwUIedI=";
    b_nh162 = "sha256-xJ1mkfkRfgkuLBy5ZnjBOiefG+kqW1q0QKjjpf2M1Ck=";
    b_nh163 = "sha256-3d75/8OL5lW8Wf6pYOy8hyeJZAJ6k3tWYTskmFl5c2Q=";
    b_nh164 = "sha256-HUr3yuIpkShnnswgAqWPjNcHNL1NcemAPuI303TKZ24=";
    b_nh165 = "sha256-FtF5KFr6swzqCTlqJ+sSc8my2J2Cz1d9fvt6pMFm+uY=";
    b_nh166 = "sha256-7OBZtOuivPRdN7Skl53et/hN8r552uywL4JdEg0Yt9M=";
    b_nh167 = "sha256-cbFhtQCmDfz42Blfj3uuWAT+Vi3HSBN+ft4XNxp2AI8=";
    b_nh168 = "sha256-0SerECt7Day+eZQywUs4RR3aLU+j+MRhki+8FCs2YoE=";
    b_nh170 = "sha256-QqD0vqE7o1b4l453t2F5JL4lyqaHqvbkxnihEFh+SUI=";
    b_nh173 = "sha256-kOBwNgx6V72bJDJUW9DUHb6O/tn22sCe1bklrirw+bg=";
    b_nh174 = "sha256-mQZyqyj9a45itY/ZbndTk3YDc99xCL2hYHh9mYMmv4s=";
    b_nh206 = "sha256-dDGmDjgHNTA68emRv10KKWXAO7ZhtiFlmsl9w/4tWY8=";
    b_nh207 = "sha256-3f3z9gLocy3gNRMQItCjVNji9J3mzLlr4N7HSfug+E0=";
    b_nh209 = "sha256-um6lWKSMPecYQV7n4AHNfzKH1fvzk08Mn2b9Qj8rXmE=";
    b_nh210 = "sha256-TKcdcGmh5RVkiDtCBldXKX8wTUP1YZCuF7/hzhhUDOY=";
    b_nh211 = "sha256-O3UbWverecrKG8Pqw7yFOdRLJQ7HlzoQimWfedWon3U=";
    b_nh225 = "sha256-G8CggWLSM373fJZQVCQzYwqwUJwcnA8lkGa8rd7wa+w=";
    b_nh226 = "sha256-D9ozZPWa2Mhh8FNlc01WGUzZaZborq2bB2JrulsPJgk=";
    b_nh227 = "sha256-5w/yYW/OULj+k7BFAuo1Btl75T/aaSytFM42zbCrve4=";
    b_nh228 = "sha256-xwGOwGB0tO2RNAM1x9kgwME72W26WECIOz7jJTBaYWs=";
    b_nh229 = "sha256-fNs6ppXMu6MWCa1OInpTjt9oe7RyENgutZlDSaafGYw=";
    b_nh230 = "sha256-yjtX/m5gcaoePnTzOpKOxCst4EEXUjzgBA87dwoONTM=";
    b_nh231 = "sha256-SDtNllkQfCOdNdQG7994zjmPrC68cT9qRy7M7FM1gkQ=";
    b_nh232 = "sha256-/5BwQWJ5uIz0vHBakwFvCDqxOZmKJ1BaLqSx3h9Xk04=";
    b_nh233 = "sha256-np8Spf1ZZ9iZUJCZ2TaRaHVqaiFqrr5+fLqI+G1SPVM=";
    b_nh234 = "sha256-Q+CM/YDVfbk7SrHVK0ITMY4psj55WE/mJwprbmDm9Kg=";
    b_nh235 = "sha256-nw5PkAd0Vq+0buOF6+99Q74KTIraRbbp69PcG51QJzk=";
    b_nh236 = "sha256-8f5IuIEwIndS93toaYRdOnIqwJKyFAXU5mEe/SzFUXo=";
    b_nh240 = "sha256-3gc5Q9AEJAvNRMT3TkiLE8upUKtLvgy8u6QcUDocyMQ=";
    b_nh241 = "sha256-LXA+44AWQKSOZIrsgpuwk1G3K3GjlIVD7l+LgKVPVHQ=";
    b_nh242 = "sha256-7qiv/f2XxseMAzwjStn56ZSbCmmkO5SXoI7ddvXtBGM=";
    b_nh246 = "sha256-W8C4dQ8nEs3lEnAs/gNaHCTao79nHtUYb8g14DbNUaE=";
    b_nh249 = "sha256-ywDdV/p7/ydzaBx4Ik+mvZzPtnFNbxLXKmKTA0NL2oI=";
    b_nh251 = "sha256-DubXYNaMgWVbyeyP5VBZh/9jdrlp43EOmCcn4BhstLA=";
    b_nh252 = "sha256-arFwlg5SG0RoOSMgTGuoleIACG9tZ8b4ExrRnDALa+w=";
    b_nh253 = "sha256-TiXaWzYZA6O42QsV3mSOz4KrCJ9x/3AlGs1CWJKHd4A=";
    b_nh257 = "sha256-DZLih5cRVD9YG1UnVv5x1/FQck9QdKD4kviiODwVveo=";
    b_nh258 = "sha256-egdVMuHPKXBgKcwPPQYJjuSFRHrJW4+i1BjTwpxm3wo=";
    b_nh259 = "sha256-k1c0IoA9Cdhl43764VcPJLuX38vz0ybBmhVdNBm5Cx4=";
    b_nh677 = "sha256-eAENhQOjtAWnqRPhPMNDnMycKE/KTamFtlCFzwG3lKM=";
    b_nh690 = "sha256-0gkXAO98Kgdp8kwrBY4otaGbOStBHB64Ux0ZP9L3Cdc=";
    b_nh708 = "sha256-zhzzakWWthL1mVCk5RZoDO0q3vaPOJ+fbL2UmYYW90M=";
    b_nh709 = "sha256-ZPAq39XJb+5uGQgqHEeNM7XJh31VErut4/Wdn6GE21A=";
    b_nh710 = "sha256-ZBqqrvfI77Rm+/uc41u2kB1MZWz8gFertAXLL5N9ERo=";
    b_nh711 = "sha256-aVQGDdmqPsGQ8wr8OZet0+2M29LZY9DsTAecdjQDN3c=";
    b_nh719 = "sha256-kLlNEtlPeIjWbHCa7oCDuKFER2oXDNQp8ooIgYxRM1U=";
    b_nh720 = "sha256-VWAyCCyPImwZv0dmbKCj9rqSV4TS9BaHDyEHcMMQBzg=";
    b_nh724 = "sha256-IrkQsr3m4VXS6tE+c1vhj4Q0Qa58ArrOECULXFdl05A=";
    b_nh740 = "sha256-xrwPdtroyegf4kTTlF3P9Jg1TIKzD72iKQ2ieRocQWk=";
    b_nh741 = "sha256-eq0SY3UchgDGSz60G1wjxL0ZoPdeQOB2tVm2fTSWMXE=";
    b_nh742 = "sha256-3ZJ7LYgNWT/Y4QRPtWs+LfZJPbTfL484ZoecJhXX31Q=";
    b_nh768 = "sha256-27qwWmfCjxJ/Fg4EV3sRE93nxvG2px2xzk49IyzYlh0=";
    b_nh769 = "sha256-0MCKWyxE6gfU0y/xKxqRjDsmFWTHmBTs0kxHQgeWsRE=";
    b_nh770 = "sha256-R2wM0L7l5i/YSVvMIGRYVhubPnfYWEmcQcn8BK8qVoI=";
    b_nh771 = "sha256-5jSsdWHu0l2ZpZNnwt4DiZvSl+iYmkpoxonhcZK+VeQ=";
    b_nh772 = "sha256-eM9ri4K6YMhmezg6WeEEMfmaL/emD2qr1R07QR35UGo=";
    b_nh777 = "sha256-rLQMWQ61HQGzx26F9mVGR2jIYLPAJb2SK8HcHyzqHXo=";
    b_nh778 = "sha256-qdmGdmLCXRyr7ubweMwcxDSVOZGlcJQF9UIQ7sE69NA=";
    b_nh779 = "sha256-WCSNQKvtiUV8fhpK2v8KrZ+6El0xDmr6qhk9jzdNjnw=";
    b_nh780 = "sha256-Lx9qJTWkXUFgHjThME4gvDIHzZa/uCPUd08ZODwlgCo=";
    b_nh781 = "sha256-voWwXAg9yxMsVhBz37nAqWao5cX2YQFReoriQBMqbzI=";
    b_nh783 = "sha256-tDDVYGkKlsKIpD4EvzWCZcAtrScIHDzSCRNukdpPtNs=";
    b_nh784 = "sha256-VqlWZESbs/ABR0SVmJJh/Z4iGL+nPb69T1fWA9TRJIA=";
    b_nh785 = "sha256-RKk9QRAyf1XuE0Dn1ClqaPyXh3hBhv+qpGcejEwpsmw=";
    b_nh786 = "sha256-h25/dfVSlG6Qlxf7fX7/++hUo6dCN3u09ZSdkvHp2uw=";
    b_nh787 = "sha256-f2g04247YjjMqvjou5RcYdgWD7KCmtOkw+SP1PsaRzM=";
    b_nh788 = "sha256-7RzXlaSfYz91mP1AH+wQLPskcZGhnee6b1CsVFK0Rkk=";
    b_nh789 = "sha256-KlbCezG/cuuJVAEOufQwK/yQC0KOtHmuby5YgRFVTs4=";
    b_nh790 = "sha256-a2y+XidAhLAMrkoRepBZNn1Ak6iEDU9PEBSDsrE2iFs=";
    b_nh791 = "sha256-qKaoydvltPC1CWvvxwqQwkUxsf4DNyN+LGVLkcN7sEM=";
    b_nh792 = "sha256-YeDPQvST/qpynxDm252jCimzH7lWnRdINfjtg3dHmb4=";
    b_nh793 = "sha256-WEPlQ/DBRYrSViSZ7xOvvP5fUN+Eh5YfKpgyYh0J98g=";
    b_nh794 = "sha256-7ZhQCmPVaKKLJvpY6mc6zqoOutTc0E8Q4e/N+HLUSkU=";
    b_nh795 = "sha256-cNOO7ktMynxm8r4381KCsuei1k7BY6Ho+vhI+OwAbgU=";
    b_nh796 = "sha256-sG4Ud6baEit9vu/c/6m9ngJiGJnnN4L+pvXEnE+Z5aI=";
    b_nh805 = "sha256-UlhOOX2NA93AUZFT/YNUFIC8/T6vG16Ttsc1A42n488=";
    b_nh821 = "sha256-fzEpsOPQ12bwyd9QDm1jGcCj7vjkr+Izox0cIziiGvQ=";
    b_nh822 = "sha256-7dh7b2yc93ip4g360oA/jxVOj47u5VUBcXHzVQIpKUk=";
    b_nh825 = "sha256-c+6PuIeUGf7BSNfyOta/oQyNY0eN5xO/WM75Wq7oL7I=";
    b_nh826 = "sha256-Q6yCBQZioPd6hyEBPcznIslS+DSEqwxzaIesUU/7HMk=";
    b_nh827 = "sha256-cKNEF0XCM7wxEafKBxQ26Oel47ByTNJyxoW2RML53Mo=";
    b_nh828 = "sha256-dtDPTSRxeyJK37mgNPOjVNXOa3Zbzh4qD8YGvN3q8IM=";
    b_nh829 = "sha256-zCCZCrJWrmbOJ0ib8nBUTMpJ8xqhybIT5nwdngUcMVw=";
    b_nh830 = "sha256-aJY7uE60gL6W6PjBkqakbCDSyzAr3zG0tkhiWN0x5tM=";
  });
  ari-all = symlinkJoin {
    name = "ari-all";
    paths = builtins.attrValues (lib.removeAttrs ari [ "recurseForDerivations" ]);
  };

  listen = lib.recurseIntoAttrs (lib.mapAttrs (downloadSofacoustics "https://sofacoustics.org/data/database_sofa_0.6/listen/" "listen") {
    # physical measurements made in an anechoic room, on real subjects.
    # morphology of each subject can be seen on pages like: <http://recherche.ircam.fr/equipes/salles/listen/infomorph_display.php?subject=IRC_1052>
    # maybe measure your head size, and choose the closest subject?
    #
    # also available here, but doesn't seem to work with mpv (?)
    # - <https://sofacoustics.org/data/database/listen%20(dtf)/>
    # - <https://sofacoustics.org/data/database/listen%20(dtf,%20sos)/>
    # - <https://sofacoustics.org/data/database/listen%20(hrtf)/>
    #
    # created by:
    # (python) for i in range(1002, 1060): print(f'irc_{i} = "sha256-irc_{i}";')
    # (sh) ./scripts/update sofacoustics.listen

    irc_1002 = "sha256-w+qp4F6fsg5ZGrR3nG+GWKa8tvDK/Rp9Ke8CTN4yJkY=";
    irc_1003 = "sha256-BjjOPHTud5pkv9Q1wPS4Ns2mVeul1Ub54BwHxfa+5/U=";
    irc_1004 = "sha256-wJ5udlnACbDvz3+KP2UP+hta+2b9p/NxSfihnq97EMA=";
    irc_1005 = "sha256-jC/LZ6Y0WvQ0nkn3z8jJHou/Rs/VMnf/zz/DcH6Clec=";
    irc_1006 = "sha256-fUxZ7uvhO8QHK/WfIGV3xb/jyvKfOFqH3HkvkXZMxRo=";
    irc_1007 = "sha256-IKI0MyBL8nUupAk5Q35NTqfFqRRRIZKQ5ajoltbzuDY=";
    irc_1008 = "sha256-x7/6Hlg22XKGxYbadNd4j1Bw+eiNnqQmbpOOjRO8X2c=";
    irc_1009 = "sha256-IVOZLSqjc2CTCfrRRPXu42i548gjq/CEGG9nyn7SD6Q=";
    # irc_1010 = null;
    # irc_1011 = null;
    irc_1012 = "sha256-HeoGvM2jckK3FZ/litroM6zx4d4yrXrhcnj+cguEzpc=";
    irc_1013 = "sha256-HKr9cJWS9Axl8wMKdpeVeKofmlfOBX3bExAtV2INEsM=";
    irc_1014 = "sha256-mu78XozpAxXbBElldEJM6yr5EMP7RmdlHTi7Jp8m1tE=";
    irc_1015 = "sha256-hBx8kFHUEDunSMBtMgdLbbUtFnA3svF6x+0nmXN0ml4=";
    irc_1016 = "sha256-YHYAYGQ22u73VlaJqTup5VLN8bx86b4G9zbh5Jc8ZxU=";
    irc_1017 = "sha256-IE6xpwOQEp3EFSDG23SyhVPAZgc7gQvmi3A+r3QFMG4=";
    irc_1018 = "sha256-3sGBTH8ekf4yxSqj4c/XPibTkcAfS48tZvxJGMAFV4c=";
    # irc_1019 = null;
    irc_1020 = "sha256-KWQb77gzqbdfduEyylByQmQYNqE6m/gv7i0zn/JTfUA=";
    irc_1021 = "sha256-EoXQQm2doMEU3+DHSayYLmMuF9RzD7gP4lTeab0pH44=";
    irc_1022 = "sha256-Tb07b9L3CW499aqpUAgruwbRkmE1r95sVgWFfnzYts0=";
    irc_1023 = "sha256-BklsYScyKMhtW0c8xh3obBSu9XPBJFBj6T+JgLVz/M8=";
    # irc_1024 = null;
    irc_1025 = "sha256-plHH4qtkPyuMPVwS3tDblE0/A1ZkCufKpGSyYIuFGGs=";
    irc_1026 = "sha256-3EhfzfWocPzlMX3x5W9/l1OxpNnmL4/xyTLnOluY66A=";
    # irc_1027 = null;
    irc_1028 = "sha256-ftbAOVC3V+o53so5SQHLLax3zJR3d3nWe48DEQKVJ2I=";
    irc_1029 = "sha256-nVJMGceMHmPpwbj1x08lhA8bzujKv6LNQcwvuTqRFy0=";
    irc_1030 = "sha256-OdwN1IeM8dOT8cEkZrTw2N47cyGDYkFXb1VHqN1j3+g=";
    irc_1031 = "sha256-pq7k/2e05jmJfRZJgPPH43PIXNAMLV8Nwpa0AnwZqac=";
    irc_1032 = "sha256-SIK7wkYShqNNaky7P4a1LS5Yket7e/Ol8pLvy/V5eiI=";
    irc_1033 = "sha256-50z8ZFCZO2VwcAypjH8vwRLSaNUQZ797DWgNNwm1mCk=";
    irc_1034 = "sha256-rnGKR4MT4nx7uMp5HoP/mtAaZhT2itT0aP37zm2WF28=";
    # irc_1035 = null;
    # irc_1036 = null;
    irc_1037 = "sha256-sDsHxnGYznPR/PBf+GmIed0ky8i35uwWnsUiPO0684k=";
    irc_1038 = "sha256-0SbkgDoMmaPpcpQaNkA1ENKv12Eg1NacuT1o2UAFx90=";
    irc_1039 = "sha256-2+qDbvJ32ad87xCcvRKFsOLeSwUB3okOJGz97CIrRSQ=";
    irc_1040 = "sha256-BMwbChgHfOT98HMsz1lWeoGTr1QKYC2FpU4S7YfyFtI=";
    irc_1041 = "sha256-elJ/nA7dTe2yeLLUShrbL/rnZISWibEx+gl4sRHrc/E=";
    irc_1042 = "sha256-6pbce7QjD5N1GR5Ng8OdaoFodb46oNDDmqeKmVLl2BQ=";
    irc_1043 = "sha256-LXoj8g+05lIIj5scN9CvHqX+mtDA5S1w4eyyRJyoD70=";
    irc_1044 = "sha256-V+sAEnBh3K8Lfhsbwqt5vcL3llaUuI4Tzz3DwI+IzzU=";
    irc_1045 = "sha256-h8P76GMPURYX7AgCSnBkHgvjObhGDmgBNwwnnGfy1ro=";
    irc_1046 = "sha256-GbKVYVkDiZWw1/MBjPgVE6EzD5hhsNAE5rd+lm7/4es=";
    irc_1047 = "sha256-OX6lK4ix5hJNdopNJDY6gVzbbHXOpZ3hA/4WInOY03Q=";
    irc_1048 = "sha256-3OimKncJlZBL31wIALjsKzC6PI31q8zuddYSViGfNsw=";
    irc_1049 = "sha256-nBfZAZUBtm2unZp4oFIEE+lhqAttigrd9gCYLOaQwYg=";
    irc_1050 = "sha256-9gzgGHXQqTLsLz2hIUTMJeVEinYP14f93FcTL4VZ1G4=";
    irc_1051 = "sha256-aEOLWBRYh0t06gb4Gzukg3FfeYEwOwNigORUGmueIlw=";
    irc_1052 = "sha256-bX0mvLeaSwhLjD8CzLBpgq6a4g47mmgEv9Dsc8VbRxk=";
    irc_1053 = "sha256-WRJRA+oLb+jmI2G5AToWx6kFS+1viU0Lw72RLMIkda8=";
    irc_1054 = "sha256-w9oclSPfHvptDImCE9xQ5yDCWF6yHynWTA4mLYqVAGo=";
    irc_1055 = "sha256-E4O2p7NKUbPmCbgL4I51giKLaTPLKbMI4798VwWIThg=";
    irc_1056 = "sha256-9X+v3ZEXxak5oCZVtJ+tGP2Pgg6B389LBPBbOaE2BqU=";
    irc_1057 = "sha256-+fTjw+GBxv7QLAItQ4TDM0YLS6wjT1lCYoGWQ0+imsw=";
    irc_1058 = "sha256-XTwWEGfIrz6qXZRCogB0YavmUZy7Kia1Z4YVtGQF+rE=";
    irc_1059 = "sha256-tXjp1eeuuzCGJbsT9pLvzHPWzXk0z/s1GUFv7gkmhew=";
  });
  listen-all = symlinkJoin {
    name = "listen-all";
    paths = builtins.attrValues (lib.removeAttrs listen [ "recurseForDerivations" ]);
  };

  widespread = lib.recurseIntoAttrs (lib.mapAttrs (downloadSofacoustics "https://sofacoustics.org/data/database/widespread/" "widespread") {
    # WiDESPREaD: "A Wide Dataset of Ear Shapes and Pinna-Related Transfer Functions Generated by Random Ear Drawings"
    # - <https://sofacoustics.org/data/database/widespread/readme.txt>
    # - <https://sofacoustics.org/data/database/widespread/Widespread.pdf>
    # - randomly generated outer-ear shapes, HRTF derived via simulation
    # - you can either load the STL's and view the ears until you find one which looks similar to your own
    #   or try each .sofa file until you find one that sounds right.
    #
    # created by:
    # (python) for i in range(100): print(f'ICO1m_000{i:02} = "sha256-ICO1m_000{i:02}";')
    # (sh) ./scripts/update sofacoustics.widespread
    #
    # some files commented out because they don't exist (were removed from the dataset?)
    #
    # not present here: ICO2m_*, UV02m_*, UV05m_*, UV1m_*, UV2m_*.
    # - i don't understand the difference between those variants -- i think it's about numerical precision (so UV02m would be the best?)

    ICO1m_00001 = "sha256-OQRaNbvmj1Wctp0Md+pYDp8OdyVjf8/bLToXH+6mtsQ=";
    ICO1m_00002 = "sha256-3eooXmbggF1NB4J6xH17J2j/3IFwunpP/5+7oMyJaZw=";
    ICO1m_00003 = "sha256-Q03qYa7mHM63lAYh7VLQPiMwMnW681KDUr+oxrprILY=";
    ICO1m_00004 = "sha256-ZCpdEhH9v4jH98/zbtjbvkykeysXNE1/Y2iZaRUfbvU=";
    ICO1m_00005 = "sha256-2Yh9vxugy4Ol9KF7qJ5JmeVzELdWeu/v/RNiwc59d7M=";
    # ICO1m_00006 = null;
    ICO1m_00007 = "sha256-Mc/h5evsj0QADkYDrUEVRvKbjDH4oNX2o8t9C/iuA5c=";
    # ICO1m_00008 = null;
    ICO1m_00009 = "sha256-Bx35iIi11UiPvDQHj2gcsokJEFzpPsSQWu0JfcF9z00=";
    ICO1m_00010 = "sha256-R7UlK5uOFHmz6WGNv+FltwT/en580F91W2Tlwrs1mGI=";
    ICO1m_00011 = "sha256-OQDGPaGmWwaCIq5pkZbt73aGD1+T48eO4T5Sev2YIpU=";
    # ICO1m_00012 = null;
    ICO1m_00013 = "sha256-+09A1I9bFZxWnKuxOkIuZWTysG7ToAT3ln/7T2/YnnA=";
    ICO1m_00014 = "sha256-YHNRGoz8sw9W5DHL0K8yB4XeMqn0TOhhaCmA0XvkJVs=";
    ICO1m_00015 = "sha256-BuGlIeKlJnK9ATr1AKtJcXA1Ke2L8/uI6SY/ouBVs4E=";
    ICO1m_00016 = "sha256-aNmAwSSkU8G2HQQkD6F5kFMjeWGQSE5zxiWq5bAv3wU=";
    # ICO1m_00017 = null;
    # ICO1m_00018 = null;
    # ICO1m_00019 = null;
    ICO1m_00020 = "sha256-fy1Ewf52qICZF8ZXUtKt1i1/8RBlzZEP3MCsTVPrPLE=";
    ICO1m_00021 = "sha256-ksbIZA7D0oyVTY9BSsB1Wx5ECSkEvaXzyZr1Jir/1Jc=";
    ICO1m_00022 = "sha256-ADam4UFfXwjXHblCREHEmyoJRVkLev57E5nQrHdqPTs=";
    ICO1m_00023 = "sha256-rM2Tsj94ut37LuykQ5fJ0WhwMzoR79Lofz+9kVyTxP8=";
    ICO1m_00024 = "sha256-uxJ7Vh7wN9X1MJuL0rNCstb7dgKOIrs702RsmJk3/yU=";
    ICO1m_00025 = "sha256-DCTkcyfAKu71gzI1OM6+W0nit5swf3YhWp1jMn0eIlo=";
    ICO1m_00026 = "sha256-UCzPgT48zGwSkUiTpofFpgUdGhgOwFj1PxyTPh0KnfQ=";
    ICO1m_00027 = "sha256-Kwx/09aBpe22oVSXKocVpn78iIrLxHaoO3OsayZRQHs=";
    # ICO1m_00028 = null;
    ICO1m_00029 = "sha256-yTegCqbKD7sNSO69VrRbByOYyMeG1DM5gh43/Ils+5k=";
    ICO1m_00030 = "sha256-RFWTthxc7+yuHTHWcwfs9UKSRbGyEAfXvHiGTN3oHf4=";
    ICO1m_00031 = "sha256-lEM4s8u4YCaSHLiVVYmd6xCyZ9MB4CTImf0Wg9IUsNU=";
    ICO1m_00032 = "sha256-RW5baxv51wnviSr+oH2n/hu/YOa99QOSnUM+5zxg+DI=";
    ICO1m_00033 = "sha256-bymfB/Krcy5sNqA7cm3eVrefQdZdRn1cXsyLAxWONFA=";
    # ICO1m_00034 = null;
    # ICO1m_00035 = null;
    ICO1m_00036 = "sha256-+cS6EoJhrCrJ2lVDAVzIAspBFhDogiW3h3fC19ddx1s=";
    # ICO1m_00037 = null;
    ICO1m_00038 = "sha256-h0uxw4h3XnK4mMTjAOF8gAUa27lCp7sAmNL3i0TwgS4=";
    ICO1m_00039 = "sha256-BTG8OQ1VPxbWgOe+jPVno7AhA0pxzka5iSh39r3Hs0U=";
    # ICO1m_00040 = null;
    # ICO1m_00041 = null;
    ICO1m_00042 = "sha256-P+iBxCs2j6oe3reuEDJj0v3M1Q5VAatO8T29Xbz5G9k=";
    ICO1m_00043 = "sha256-t/DF8Pd9T0G6x9d86MWMGO/4B4YVlFeYapjLy7x2Lw0=";
    ICO1m_00044 = "sha256-lao2GiNTrhey19f2WybJrUXjkrqHzc967DlBmQNeHv8=";
    ICO1m_00045 = "sha256-D794CWEsWxqwknp3Gw6ofKW81dcJUOU6SJXBC9g+lg4=";
    # ICO1m_00046 = null;
    # ICO1m_00047 = null;
    ICO1m_00048 = "sha256-1NFVzShkVCxMvy69uAagh9jImQoa7amt4/KeFgOZlPA=";
    ICO1m_00049 = "sha256-h7Xg8GgjY6nfEnKkBok3rx5tCuoroRl9tL2JxGxwoHg=";
    # ICO1m_00050 = null;
    # ICO1m_00051 = null;
    # ICO1m_00052 = null;
    # ICO1m_00053 = null;
    ICO1m_00054 = "sha256-bo3HrprlVzHk/1WurIidlpZRq7mNAOSAWMyJecwsxZE=";
    # ICO1m_00055 = null;
    ICO1m_00056 = "sha256-ZKLT7xLTyA6Or3eALVYpQHHjpPe3yMz2hyf4KXDp4GM=";
    ICO1m_00057 = "sha256-9IZ6yidJsy6XqW1aD9Ysp1vyM3SlD+SSErR70zdDBVk=";
    ICO1m_00058 = "sha256-om3Z/DOX+dB6ahwLsgXGLRQhBG8Q6oDM5Qbv2e7MOgA=";
    ICO1m_00059 = "sha256-XbDQD9OobGAu1coJBQWwBFKRjycW0yGKGl8cy6arw9w=";
    # ICO1m_00060 = null;
    ICO1m_00061 = "sha256-dWgM9z51arqFzO8E5LduWUj5zi6Sg0pO2WjeMCRHIWg=";
    ICO1m_00062 = "sha256-qJbhIHywC3JvVXcrOLYBchyDObEjBpSK04ldINqj7aE=";
    ICO1m_00063 = "sha256-HO199eIJJwCdCnaYYxxjgR+1OrZ0k/68qNAOEOVX6f4=";
    ICO1m_00064 = "sha256-3dD+IaCUijUZcJTmvLplk/jrQiEgZw7FrYZ3NMwS7Wc=";
    ICO1m_00065 = "sha256-UfT55iq3FCZhocD978XhRYJp6sODKHnBWfaFa6xi+Sk=";
    # ICO1m_00066 = null;
    # ICO1m_00067 = null;
    ICO1m_00068 = "sha256-URac387SHKxVp8DEaDte8MYG23fXivamDq4BvQAISHQ=";
    ICO1m_00069 = "sha256-tOdqtUyd59h7U9WvdUnzbHZIrjMl34v+WXZ/IdlSL44=";
    # ICO1m_00070 = null;
    ICO1m_00071 = "sha256-Zh/T/q7Fa4xRpFdM+MFCFoTc2PdjLKtvgNv8C0jkjdg=";
    ICO1m_00072 = "sha256-ro6ADQudXhjFNDqubR1mmwyvqMQbyl9mA1bvgdga1fM=";
    # ICO1m_00073 = null;
    ICO1m_00074 = "sha256-3vgKeO+Vyuk1jMpz6m1tKmcVHUW1KnX8cgRb0pKmijE=";
    # ICO1m_00075 = null;
    ICO1m_00076 = "sha256-IMFnLYZ5SOrQ4jpG5M90PxNyzY0xa6FpWiBDgvrc48E=";
    # ICO1m_00077 = null;
    ICO1m_00078 = "sha256-srxlionrHgtp2DwKj46zLzntiuCBxM+4Tsjzg/Jf8Y8=";
    ICO1m_00079 = "sha256-j+gOEN9X7JK7BszTIxmyLiV5bxTyMQiWEEk7T20OoWA=";
    # ICO1m_00080 = null;
    # ICO1m_00081 = null;
    ICO1m_00082 = "sha256-UyNFtRxDT77XIPN5WpPWVbDyiI110oUKWdmJV6HN+5M=";
    ICO1m_00083 = "sha256-YFw2hCtxZse1mAN5PwvxiC8ItOgtpx1L4Tqy0EEWCKk=";
    # ICO1m_00084 = null;
    ICO1m_00085 = "sha256-v6oMvI5i4RxHE05udNtzjxWKCzBhdyun8U6Y3XFJ6TA=";
    ICO1m_00086 = "sha256-S+U7qiplJngCnsimEkh7v2abVPMSs0hnTIGQnI4C0/Q=";
    ICO1m_00087 = "sha256-jt+ZSQt4cIxpc7Iru9jH+KXC4OKWwC9oUZb/xOAtR9c=";
    # ICO1m_00088 = null;
    ICO1m_00089 = "sha256-TUM1ePqdlCx9YPt5pSoOtEdgf3Hz06pba4xeqjsZ9Tg=";
    ICO1m_00090 = "sha256-i8t0jYSrBPIrFLFoSi5+tFO7IMeSIyDzQ4rFu+ONZAQ=";
    # ICO1m_00091 = null;
    ICO1m_00092 = "sha256-0SgBLvFsYaRBY4pzXQ3+VIW6itBgJ8GZguSK4Mh14Vo=";
    # ICO1m_00093 = null;
    # ICO1m_00094 = null;
    ICO1m_00095 = "sha256-rhz5YEEVXjrCyzTeV4h+wYO8tYMhtQmhx3bjuiILO4g=";
    # ICO1m_00096 = null;
    ICO1m_00097 = "sha256-OpNqIKEv/f+D55HTWbTDt4Zt6Zu0tmRSHwnwdWqZdQU=";
    # ICO1m_00098 = null;
    ICO1m_00099 = "sha256-Kz4w/eIx8HWKLRiCKzn9PCl0v3p9fNksuatMtK54zpY=";
    # ...
    # and on it goes (add the others if you want i guess)
  });
  widespread-all = symlinkJoin {
    name = "widespread-all";
    paths = builtins.attrValues (lib.removeAttrs widespread [ "recurseForDerivations" ]);
  };
}))
