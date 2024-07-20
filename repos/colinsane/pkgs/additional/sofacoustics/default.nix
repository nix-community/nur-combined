{
  fetchurl,
  lib,
  newScope,
  nix-update-script,
  stdenv,
  symlinkJoin,
}:
lib.makeScope newScope (self: with self; {
  # downloadSofacoustics = database: name: hash: fetchurl {
  #   url = "https://sofacoustics.org/data/database/${database}/${name}.sofa";
  #   pname = "${database}-${name}";
  #   version = "0-unstable";
  #   inherit hash;
  #   recursiveHash = true;
  #   postFetch = ''
  #     mv $out ${name}
  #     mkdir -p $out/share/sofa
  #     mv ${name} $out/share/sofa/${name}.sofa
  #   '';
  #   passthru.updateScript = nix-update-script { };
  # };
  downloadSofacoustics = prefix: database: name: hash: stdenv.mkDerivation {
    name = "${database}-${name}";
    src = fetchurl {
      url = "${prefix}${name}.sofa";
      name = "${database}-${name}";
      inherit hash;
    };

    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/share/sofa
      cp $src $out/share/sofa/${database}-${name}.sofa
    '';
    doBuild = false;

    preferLocalBuild = true;
    # this update script is pretty useless -- except that it lets me auto-generate the hashes
    passthru.updateScript = nix-update-script {
      extraArgs = [ "--version" "skip" ];
    };
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
})
