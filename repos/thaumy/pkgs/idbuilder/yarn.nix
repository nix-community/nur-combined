{ fetchurl, fetchgit, linkFarm, runCommand, gnutar }: rec {
  offline_cache = linkFarm "offline" packages;
  packages = [
    {
      name = "_adobe_css_tools___css_tools_4.2.0.tgz";
      path = fetchurl {
        name = "_adobe_css_tools___css_tools_4.2.0.tgz";
        url  = "https://registry.yarnpkg.com/@adobe/css-tools/-/css-tools-4.2.0.tgz";
        sha512 = "E09FiIft46CmH5Qnjb0wsW54/YQd69LsxeKUOWawmws1XWvyFGURnAChH0mlr7YPFR1ofwvUQfcL0J3lMxXqPA==";
      };
    }
    {
      name = "_babel_helper_string_parser___helper_string_parser_7.21.5.tgz";
      path = fetchurl {
        name = "_babel_helper_string_parser___helper_string_parser_7.21.5.tgz";
        url  = "https://registry.yarnpkg.com/@babel/helper-string-parser/-/helper-string-parser-7.21.5.tgz";
        sha512 = "5pTUx3hAJaZIdW99sJ6ZUUgWq/Y+Hja7TowEnLNMm1VivRgZQL3vpBY3qUACVsvw+yQU6+YgfBVmcbLaZtrA1w==";
      };
    }
    {
      name = "_babel_helper_validator_identifier___helper_validator_identifier_7.19.1.tgz";
      path = fetchurl {
        name = "_babel_helper_validator_identifier___helper_validator_identifier_7.19.1.tgz";
        url  = "https://registry.yarnpkg.com/@babel/helper-validator-identifier/-/helper-validator-identifier-7.19.1.tgz";
        sha512 = "awrNfaMtnHUr653GgGEs++LlAvW6w+DcPrOliSMXWCKo597CwL5Acf/wWdNkf/tfEQE3mjkeD1YOVZOUV/od1w==";
      };
    }
    {
      name = "_babel_parser___parser_7.21.9.tgz";
      path = fetchurl {
        name = "_babel_parser___parser_7.21.9.tgz";
        url  = "https://registry.yarnpkg.com/@babel/parser/-/parser-7.21.9.tgz";
        sha512 = "q5PNg/Bi1OpGgx5jYlvWZwAorZepEudDMCLtj967aeS7WMont7dUZI46M2XwcIQqvUlMxWfdLFu4S/qSxeUu5g==";
      };
    }
    {
      name = "_babel_types___types_7.21.5.tgz";
      path = fetchurl {
        name = "_babel_types___types_7.21.5.tgz";
        url  = "https://registry.yarnpkg.com/@babel/types/-/types-7.21.5.tgz";
        sha512 = "m4AfNvVF2mVC/F7fDEdH2El3HzUg9It/XsCxZiOTTA3m3qYfcSVSbTfM6Q9xG+hYDniZssYhlXKKUMD5m8tF4Q==";
      };
    }
    {
      name = "_esbuild_android_arm64___android_arm64_0.17.19.tgz";
      path = fetchurl {
        name = "_esbuild_android_arm64___android_arm64_0.17.19.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/android-arm64/-/android-arm64-0.17.19.tgz";
        sha512 = "KBMWvEZooR7+kzY0BtbTQn0OAYY7CsiydT63pVEaPtVYF0hXbUaOyZog37DKxK7NF3XacBJOpYT4adIJh+avxA==";
      };
    }
    {
      name = "_esbuild_android_arm___android_arm_0.17.19.tgz";
      path = fetchurl {
        name = "_esbuild_android_arm___android_arm_0.17.19.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/android-arm/-/android-arm-0.17.19.tgz";
        sha512 = "rIKddzqhmav7MSmoFCmDIb6e2W57geRsM94gV2l38fzhXMwq7hZoClug9USI2pFRGL06f4IOPHHpFNOkWieR8A==";
      };
    }
    {
      name = "_esbuild_android_x64___android_x64_0.17.19.tgz";
      path = fetchurl {
        name = "_esbuild_android_x64___android_x64_0.17.19.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/android-x64/-/android-x64-0.17.19.tgz";
        sha512 = "uUTTc4xGNDT7YSArp/zbtmbhO0uEEK9/ETW29Wk1thYUJBz3IVnvgEiEwEa9IeLyvnpKrWK64Utw2bgUmDveww==";
      };
    }
    {
      name = "_esbuild_darwin_arm64___darwin_arm64_0.17.19.tgz";
      path = fetchurl {
        name = "_esbuild_darwin_arm64___darwin_arm64_0.17.19.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/darwin-arm64/-/darwin-arm64-0.17.19.tgz";
        sha512 = "80wEoCfF/hFKM6WE1FyBHc9SfUblloAWx6FJkFWTWiCoht9Mc0ARGEM47e67W9rI09YoUxJL68WHfDRYEAvOhg==";
      };
    }
    {
      name = "_esbuild_darwin_x64___darwin_x64_0.17.19.tgz";
      path = fetchurl {
        name = "_esbuild_darwin_x64___darwin_x64_0.17.19.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/darwin-x64/-/darwin-x64-0.17.19.tgz";
        sha512 = "IJM4JJsLhRYr9xdtLytPLSH9k/oxR3boaUIYiHkAawtwNOXKE8KoU8tMvryogdcT8AU+Bflmh81Xn6Q0vTZbQw==";
      };
    }
    {
      name = "_esbuild_freebsd_arm64___freebsd_arm64_0.17.19.tgz";
      path = fetchurl {
        name = "_esbuild_freebsd_arm64___freebsd_arm64_0.17.19.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/freebsd-arm64/-/freebsd-arm64-0.17.19.tgz";
        sha512 = "pBwbc7DufluUeGdjSU5Si+P3SoMF5DQ/F/UmTSb8HXO80ZEAJmrykPyzo1IfNbAoaqw48YRpv8shwd1NoI0jcQ==";
      };
    }
    {
      name = "_esbuild_freebsd_x64___freebsd_x64_0.17.19.tgz";
      path = fetchurl {
        name = "_esbuild_freebsd_x64___freebsd_x64_0.17.19.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/freebsd-x64/-/freebsd-x64-0.17.19.tgz";
        sha512 = "4lu+n8Wk0XlajEhbEffdy2xy53dpR06SlzvhGByyg36qJw6Kpfk7cp45DR/62aPH9mtJRmIyrXAS5UWBrJT6TQ==";
      };
    }
    {
      name = "_esbuild_linux_arm64___linux_arm64_0.17.19.tgz";
      path = fetchurl {
        name = "_esbuild_linux_arm64___linux_arm64_0.17.19.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/linux-arm64/-/linux-arm64-0.17.19.tgz";
        sha512 = "ct1Tg3WGwd3P+oZYqic+YZF4snNl2bsnMKRkb3ozHmnM0dGWuxcPTTntAF6bOP0Sp4x0PjSF+4uHQ1xvxfRKqg==";
      };
    }
    {
      name = "_esbuild_linux_arm___linux_arm_0.17.19.tgz";
      path = fetchurl {
        name = "_esbuild_linux_arm___linux_arm_0.17.19.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/linux-arm/-/linux-arm-0.17.19.tgz";
        sha512 = "cdmT3KxjlOQ/gZ2cjfrQOtmhG4HJs6hhvm3mWSRDPtZ/lP5oe8FWceS10JaSJC13GBd4eH/haHnqf7hhGNLerA==";
      };
    }
    {
      name = "_esbuild_linux_ia32___linux_ia32_0.17.19.tgz";
      path = fetchurl {
        name = "_esbuild_linux_ia32___linux_ia32_0.17.19.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/linux-ia32/-/linux-ia32-0.17.19.tgz";
        sha512 = "w4IRhSy1VbsNxHRQpeGCHEmibqdTUx61Vc38APcsRbuVgK0OPEnQ0YD39Brymn96mOx48Y2laBQGqgZ0j9w6SQ==";
      };
    }
    {
      name = "_esbuild_linux_loong64___linux_loong64_0.17.19.tgz";
      path = fetchurl {
        name = "_esbuild_linux_loong64___linux_loong64_0.17.19.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/linux-loong64/-/linux-loong64-0.17.19.tgz";
        sha512 = "2iAngUbBPMq439a+z//gE+9WBldoMp1s5GWsUSgqHLzLJ9WoZLZhpwWuym0u0u/4XmZ3gpHmzV84PonE+9IIdQ==";
      };
    }
    {
      name = "_esbuild_linux_mips64el___linux_mips64el_0.17.19.tgz";
      path = fetchurl {
        name = "_esbuild_linux_mips64el___linux_mips64el_0.17.19.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/linux-mips64el/-/linux-mips64el-0.17.19.tgz";
        sha512 = "LKJltc4LVdMKHsrFe4MGNPp0hqDFA1Wpt3jE1gEyM3nKUvOiO//9PheZZHfYRfYl6AwdTH4aTcXSqBerX0ml4A==";
      };
    }
    {
      name = "_esbuild_linux_ppc64___linux_ppc64_0.17.19.tgz";
      path = fetchurl {
        name = "_esbuild_linux_ppc64___linux_ppc64_0.17.19.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/linux-ppc64/-/linux-ppc64-0.17.19.tgz";
        sha512 = "/c/DGybs95WXNS8y3Ti/ytqETiW7EU44MEKuCAcpPto3YjQbyK3IQVKfF6nbghD7EcLUGl0NbiL5Rt5DMhn5tg==";
      };
    }
    {
      name = "_esbuild_linux_riscv64___linux_riscv64_0.17.19.tgz";
      path = fetchurl {
        name = "_esbuild_linux_riscv64___linux_riscv64_0.17.19.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/linux-riscv64/-/linux-riscv64-0.17.19.tgz";
        sha512 = "FC3nUAWhvFoutlhAkgHf8f5HwFWUL6bYdvLc/TTuxKlvLi3+pPzdZiFKSWz/PF30TB1K19SuCxDTI5KcqASJqA==";
      };
    }
    {
      name = "_esbuild_linux_s390x___linux_s390x_0.17.19.tgz";
      path = fetchurl {
        name = "_esbuild_linux_s390x___linux_s390x_0.17.19.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/linux-s390x/-/linux-s390x-0.17.19.tgz";
        sha512 = "IbFsFbxMWLuKEbH+7sTkKzL6NJmG2vRyy6K7JJo55w+8xDk7RElYn6xvXtDW8HCfoKBFK69f3pgBJSUSQPr+4Q==";
      };
    }
    {
      name = "_esbuild_linux_x64___linux_x64_0.17.19.tgz";
      path = fetchurl {
        name = "_esbuild_linux_x64___linux_x64_0.17.19.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/linux-x64/-/linux-x64-0.17.19.tgz";
        sha512 = "68ngA9lg2H6zkZcyp22tsVt38mlhWde8l3eJLWkyLrp4HwMUr3c1s/M2t7+kHIhvMjglIBrFpncX1SzMckomGw==";
      };
    }
    {
      name = "_esbuild_netbsd_x64___netbsd_x64_0.17.19.tgz";
      path = fetchurl {
        name = "_esbuild_netbsd_x64___netbsd_x64_0.17.19.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/netbsd-x64/-/netbsd-x64-0.17.19.tgz";
        sha512 = "CwFq42rXCR8TYIjIfpXCbRX0rp1jo6cPIUPSaWwzbVI4aOfX96OXY8M6KNmtPcg7QjYeDmN+DD0Wp3LaBOLf4Q==";
      };
    }
    {
      name = "_esbuild_openbsd_x64___openbsd_x64_0.17.19.tgz";
      path = fetchurl {
        name = "_esbuild_openbsd_x64___openbsd_x64_0.17.19.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/openbsd-x64/-/openbsd-x64-0.17.19.tgz";
        sha512 = "cnq5brJYrSZ2CF6c35eCmviIN3k3RczmHz8eYaVlNasVqsNY+JKohZU5MKmaOI+KkllCdzOKKdPs762VCPC20g==";
      };
    }
    {
      name = "_esbuild_sunos_x64___sunos_x64_0.17.19.tgz";
      path = fetchurl {
        name = "_esbuild_sunos_x64___sunos_x64_0.17.19.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/sunos-x64/-/sunos-x64-0.17.19.tgz";
        sha512 = "vCRT7yP3zX+bKWFeP/zdS6SqdWB8OIpaRq/mbXQxTGHnIxspRtigpkUcDMlSCOejlHowLqII7K2JKevwyRP2rg==";
      };
    }
    {
      name = "_esbuild_win32_arm64___win32_arm64_0.17.19.tgz";
      path = fetchurl {
        name = "_esbuild_win32_arm64___win32_arm64_0.17.19.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/win32-arm64/-/win32-arm64-0.17.19.tgz";
        sha512 = "yYx+8jwowUstVdorcMdNlzklLYhPxjniHWFKgRqH7IFlUEa0Umu3KuYplf1HUZZ422e3NU9F4LGb+4O0Kdcaag==";
      };
    }
    {
      name = "_esbuild_win32_ia32___win32_ia32_0.17.19.tgz";
      path = fetchurl {
        name = "_esbuild_win32_ia32___win32_ia32_0.17.19.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/win32-ia32/-/win32-ia32-0.17.19.tgz";
        sha512 = "eggDKanJszUtCdlVs0RB+h35wNlb5v4TWEkq4vZcmVt5u/HiDZrTXe2bWFQUez3RgNHwx/x4sk5++4NSSicKkw==";
      };
    }
    {
      name = "_esbuild_win32_x64___win32_x64_0.17.19.tgz";
      path = fetchurl {
        name = "_esbuild_win32_x64___win32_x64_0.17.19.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/win32-x64/-/win32-x64-0.17.19.tgz";
        sha512 = "lAhycmKnVOuRYNtRtatQR1LPQf2oYCkRGkSFnseDAKPl8lu5SOsK/e1sXe5a0Pc5kHIHe6P2I/ilntNv2xf3cA==";
      };
    }
    {
      name = "_jridgewell_sourcemap_codec___sourcemap_codec_1.4.15.tgz";
      path = fetchurl {
        name = "_jridgewell_sourcemap_codec___sourcemap_codec_1.4.15.tgz";
        url  = "https://registry.yarnpkg.com/@jridgewell/sourcemap-codec/-/sourcemap-codec-1.4.15.tgz";
        sha512 = "eF2rxCRulEKXHTRiDrDy6erMYWqNw4LPdQ8UQA4huuxaQsVeRPFl2oM8oDGxMFhJUWZf9McpLtJasDDZb/Bpeg==";
      };
    }
    {
      name = "_mdi_font___font_7.2.96.tgz";
      path = fetchurl {
        name = "_mdi_font___font_7.2.96.tgz";
        url  = "https://registry.yarnpkg.com/@mdi/font/-/font-7.2.96.tgz";
        sha512 = "e//lmkmpFUMZKhmCY9zdjRe4zNXfbOIJnn6xveHbaV2kSw5aJ5dLXUxcRt1Gxfi7ZYpFLUWlkG2MGSFAiqAu7w==";
      };
    }
    {
      name = "_tauri_apps_api___api_1.3.0.tgz";
      path = fetchurl {
        name = "_tauri_apps_api___api_1.3.0.tgz";
        url  = "https://registry.yarnpkg.com/@tauri-apps/api/-/api-1.3.0.tgz";
        sha512 = "AH+3FonkKZNtfRtGrObY38PrzEj4d+1emCbwNGu0V2ENbXjlLHMZQlUh+Bhu/CRmjaIwZMGJ3yFvWaZZgTHoog==";
      };
    }
    {
      name = "_tauri_apps_cli_darwin_arm64___cli_darwin_arm64_1.3.1.tgz";
      path = fetchurl {
        name = "_tauri_apps_cli_darwin_arm64___cli_darwin_arm64_1.3.1.tgz";
        url  = "https://registry.yarnpkg.com/@tauri-apps/cli-darwin-arm64/-/cli-darwin-arm64-1.3.1.tgz";
        sha512 = "QlepYVPgOgspcwA/u4kGG4ZUijlXfdRtno00zEy+LxinN/IRXtk+6ErVtsmoLi1ZC9WbuMwzAcsRvqsD+RtNAg==";
      };
    }
    {
      name = "_tauri_apps_cli_darwin_x64___cli_darwin_x64_1.3.1.tgz";
      path = fetchurl {
        name = "_tauri_apps_cli_darwin_x64___cli_darwin_x64_1.3.1.tgz";
        url  = "https://registry.yarnpkg.com/@tauri-apps/cli-darwin-x64/-/cli-darwin-x64-1.3.1.tgz";
        sha512 = "fKcAUPVFO3jfDKXCSDGY0MhZFF/wDtx3rgFnogWYu4knk38o9RaqRkvMvqJhLYPuWaEM5h6/z1dRrr9KKCbrVg==";
      };
    }
    {
      name = "_tauri_apps_cli_linux_arm_gnueabihf___cli_linux_arm_gnueabihf_1.3.1.tgz";
      path = fetchurl {
        name = "_tauri_apps_cli_linux_arm_gnueabihf___cli_linux_arm_gnueabihf_1.3.1.tgz";
        url  = "https://registry.yarnpkg.com/@tauri-apps/cli-linux-arm-gnueabihf/-/cli-linux-arm-gnueabihf-1.3.1.tgz";
        sha512 = "+4H0dv8ltJHYu/Ma1h9ixUPUWka9EjaYa8nJfiMsdCI4LJLNE6cPveE7RmhZ59v9GW1XB108/k083JUC/OtGvA==";
      };
    }
    {
      name = "_tauri_apps_cli_linux_arm64_gnu___cli_linux_arm64_gnu_1.3.1.tgz";
      path = fetchurl {
        name = "_tauri_apps_cli_linux_arm64_gnu___cli_linux_arm64_gnu_1.3.1.tgz";
        url  = "https://registry.yarnpkg.com/@tauri-apps/cli-linux-arm64-gnu/-/cli-linux-arm64-gnu-1.3.1.tgz";
        sha512 = "Pj3odVO1JAxLjYmoXKxcrpj/tPxcA8UP8N06finhNtBtBaxAjrjjxKjO4968KB0BUH7AASIss9EL4Tr0FGnDuw==";
      };
    }
    {
      name = "_tauri_apps_cli_linux_arm64_musl___cli_linux_arm64_musl_1.3.1.tgz";
      path = fetchurl {
        name = "_tauri_apps_cli_linux_arm64_musl___cli_linux_arm64_musl_1.3.1.tgz";
        url  = "https://registry.yarnpkg.com/@tauri-apps/cli-linux-arm64-musl/-/cli-linux-arm64-musl-1.3.1.tgz";
        sha512 = "tA0JdDLPFaj42UDIVcF2t8V0tSha40rppcmAR/MfQpTCxih6399iMjwihz9kZE1n4b5O4KTq9GliYo50a8zYlQ==";
      };
    }
    {
      name = "_tauri_apps_cli_linux_x64_gnu___cli_linux_x64_gnu_1.3.1.tgz";
      path = fetchurl {
        name = "_tauri_apps_cli_linux_x64_gnu___cli_linux_x64_gnu_1.3.1.tgz";
        url  = "https://registry.yarnpkg.com/@tauri-apps/cli-linux-x64-gnu/-/cli-linux-x64-gnu-1.3.1.tgz";
        sha512 = "FDU+Mnvk6NLkqQimcNojdKpMN4Y3W51+SQl+NqG9AFCWprCcSg62yRb84751ujZuf2MGT8HQOfmd0i77F4Q3tQ==";
      };
    }
    {
      name = "_tauri_apps_cli_linux_x64_musl___cli_linux_x64_musl_1.3.1.tgz";
      path = fetchurl {
        name = "_tauri_apps_cli_linux_x64_musl___cli_linux_x64_musl_1.3.1.tgz";
        url  = "https://registry.yarnpkg.com/@tauri-apps/cli-linux-x64-musl/-/cli-linux-x64-musl-1.3.1.tgz";
        sha512 = "MpO3akXFmK8lZYEbyQRDfhdxz1JkTBhonVuz5rRqxwA7gnGWHa1aF1+/2zsy7ahjB2tQ9x8DDFDMdVE20o9HrA==";
      };
    }
    {
      name = "_tauri_apps_cli_win32_ia32_msvc___cli_win32_ia32_msvc_1.3.1.tgz";
      path = fetchurl {
        name = "_tauri_apps_cli_win32_ia32_msvc___cli_win32_ia32_msvc_1.3.1.tgz";
        url  = "https://registry.yarnpkg.com/@tauri-apps/cli-win32-ia32-msvc/-/cli-win32-ia32-msvc-1.3.1.tgz";
        sha512 = "9Boeo3K5sOrSBAZBuYyGkpV2RfnGQz3ZhGJt4hE6P+HxRd62lS6+qDKAiw1GmkZ0l1drc2INWrNeT50gwOKwIQ==";
      };
    }
    {
      name = "_tauri_apps_cli_win32_x64_msvc___cli_win32_x64_msvc_1.3.1.tgz";
      path = fetchurl {
        name = "_tauri_apps_cli_win32_x64_msvc___cli_win32_x64_msvc_1.3.1.tgz";
        url  = "https://registry.yarnpkg.com/@tauri-apps/cli-win32-x64-msvc/-/cli-win32-x64-msvc-1.3.1.tgz";
        sha512 = "wMrTo91hUu5CdpbElrOmcZEoJR4aooTG+fbtcc87SMyPGQy1Ux62b+ZdwLvL1sVTxnIm//7v6QLRIWGiUjCPwA==";
      };
    }
    {
      name = "_tauri_apps_cli___cli_1.3.1.tgz";
      path = fetchurl {
        name = "_tauri_apps_cli___cli_1.3.1.tgz";
        url  = "https://registry.yarnpkg.com/@tauri-apps/cli/-/cli-1.3.1.tgz";
        sha512 = "o4I0JujdITsVRm3/0spfJX7FcKYrYV1DXJqzlWIn6IY25/RltjU6qbC1TPgVww3RsRX63jyVUTcWpj5wwFl+EQ==";
      };
    }
    {
      name = "_types_node___node_18.16.14.tgz";
      path = fetchurl {
        name = "_types_node___node_18.16.14.tgz";
        url  = "https://registry.yarnpkg.com/@types/node/-/node-18.16.14.tgz";
        sha512 = "+ImzUB3mw2c5ISJUq0punjDilUQ5GnUim0ZRvchHIWJmOC0G+p0kzhXBqj6cDjK0QdPFwzrHWgrJp3RPvCG5qg==";
      };
    }
    {
      name = "_vitejs_plugin_vue___plugin_vue_4.2.3.tgz";
      path = fetchurl {
        name = "_vitejs_plugin_vue___plugin_vue_4.2.3.tgz";
        url  = "https://registry.yarnpkg.com/@vitejs/plugin-vue/-/plugin-vue-4.2.3.tgz";
        sha512 = "R6JDUfiZbJA9cMiguQ7jxALsgiprjBeHL5ikpXfJCH62pPHtI+JdJ5xWj6Ev73yXSlYl86+blXn1kZHQ7uElxw==";
      };
    }
    {
      name = "_volar_language_core___language_core_1.4.1.tgz";
      path = fetchurl {
        name = "_volar_language_core___language_core_1.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@volar/language-core/-/language-core-1.4.1.tgz";
        sha512 = "EIY+Swv+TjsWpxOxujjMf1ZXqOjg9MT2VMXZ+1dKva0wD8W0L6EtptFFcCJdBbcKmGMFkr57Qzz9VNMWhs3jXQ==";
      };
    }
    {
      name = "_volar_source_map___source_map_1.4.1.tgz";
      path = fetchurl {
        name = "_volar_source_map___source_map_1.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@volar/source-map/-/source-map-1.4.1.tgz";
        sha512 = "bZ46ad72dsbzuOWPUtJjBXkzSQzzSejuR3CT81+GvTEI2E994D8JPXzM3tl98zyCNnjgs4OkRyliImL1dvJ5BA==";
      };
    }
    {
      name = "_volar_typescript___typescript_1.4.1_patch.2.tgz";
      path = fetchurl {
        name = "_volar_typescript___typescript_1.4.1_patch.2.tgz";
        url  = "https://registry.yarnpkg.com/@volar/typescript/-/typescript-1.4.1-patch.2.tgz";
        sha512 = "lPFYaGt8OdMEzNGJJChF40uYqMO4Z/7Q9fHPQC/NRVtht43KotSXLrkPandVVMf9aPbiJ059eAT+fwHGX16k4w==";
      };
    }
    {
      name = "_volar_vue_language_core___vue_language_core_1.6.5.tgz";
      path = fetchurl {
        name = "_volar_vue_language_core___vue_language_core_1.6.5.tgz";
        url  = "https://registry.yarnpkg.com/@volar/vue-language-core/-/vue-language-core-1.6.5.tgz";
        sha512 = "IF2b6hW4QAxfsLd5mePmLgtkXzNi+YnH6ltCd80gb7+cbdpFMjM1I+w+nSg2kfBTyfu+W8useCZvW89kPTBpzg==";
      };
    }
    {
      name = "_volar_vue_typescript___vue_typescript_1.6.5.tgz";
      path = fetchurl {
        name = "_volar_vue_typescript___vue_typescript_1.6.5.tgz";
        url  = "https://registry.yarnpkg.com/@volar/vue-typescript/-/vue-typescript-1.6.5.tgz";
        sha512 = "er9rVClS4PHztMUmtPMDTl+7c7JyrxweKSAEe/o/Noeq2bQx6v3/jZHVHBe8ZNUti5ubJL/+Tg8L3bzmlalV8A==";
      };
    }
    {
      name = "_vue_compiler_core___compiler_core_3.3.4.tgz";
      path = fetchurl {
        name = "_vue_compiler_core___compiler_core_3.3.4.tgz";
        url  = "https://registry.yarnpkg.com/@vue/compiler-core/-/compiler-core-3.3.4.tgz";
        sha512 = "cquyDNvZ6jTbf/+x+AgM2Arrp6G4Dzbb0R64jiG804HRMfRiFXWI6kqUVqZ6ZR0bQhIoQjB4+2bhNtVwndW15g==";
      };
    }
    {
      name = "_vue_compiler_dom___compiler_dom_3.3.4.tgz";
      path = fetchurl {
        name = "_vue_compiler_dom___compiler_dom_3.3.4.tgz";
        url  = "https://registry.yarnpkg.com/@vue/compiler-dom/-/compiler-dom-3.3.4.tgz";
        sha512 = "wyM+OjOVpuUukIq6p5+nwHYtj9cFroz9cwkfmP9O1nzH68BenTTv0u7/ndggT8cIQlnBeOo6sUT/gvHcIkLA5w==";
      };
    }
    {
      name = "_vue_compiler_sfc___compiler_sfc_3.3.4.tgz";
      path = fetchurl {
        name = "_vue_compiler_sfc___compiler_sfc_3.3.4.tgz";
        url  = "https://registry.yarnpkg.com/@vue/compiler-sfc/-/compiler-sfc-3.3.4.tgz";
        sha512 = "6y/d8uw+5TkCuzBkgLS0v3lSM3hJDntFEiUORM11pQ/hKvkhSKZrXW6i69UyXlJQisJxuUEJKAWEqWbWsLeNKQ==";
      };
    }
    {
      name = "_vue_compiler_ssr___compiler_ssr_3.3.4.tgz";
      path = fetchurl {
        name = "_vue_compiler_ssr___compiler_ssr_3.3.4.tgz";
        url  = "https://registry.yarnpkg.com/@vue/compiler-ssr/-/compiler-ssr-3.3.4.tgz";
        sha512 = "m0v6oKpup2nMSehwA6Uuu+j+wEwcy7QmwMkVNVfrV9P2qE5KshC6RwOCq8fjGS/Eak/uNb8AaWekfiXxbBB6gQ==";
      };
    }
    {
      name = "_vue_devtools_api___devtools_api_6.5.0.tgz";
      path = fetchurl {
        name = "_vue_devtools_api___devtools_api_6.5.0.tgz";
        url  = "https://registry.yarnpkg.com/@vue/devtools-api/-/devtools-api-6.5.0.tgz";
        sha512 = "o9KfBeaBmCKl10usN4crU53fYtC1r7jJwdGKjPT24t348rHxgfpZ0xL3Xm/gLUYnc0oTp8LAmrxOeLyu6tbk2Q==";
      };
    }
    {
      name = "_vue_reactivity_transform___reactivity_transform_3.3.4.tgz";
      path = fetchurl {
        name = "_vue_reactivity_transform___reactivity_transform_3.3.4.tgz";
        url  = "https://registry.yarnpkg.com/@vue/reactivity-transform/-/reactivity-transform-3.3.4.tgz";
        sha512 = "MXgwjako4nu5WFLAjpBnCj/ieqcjE2aJBINUNQzkZQfzIZA4xn+0fV1tIYBJvvva3N3OvKGofRLvQIwEQPpaXw==";
      };
    }
    {
      name = "_vue_reactivity___reactivity_3.3.4.tgz";
      path = fetchurl {
        name = "_vue_reactivity___reactivity_3.3.4.tgz";
        url  = "https://registry.yarnpkg.com/@vue/reactivity/-/reactivity-3.3.4.tgz";
        sha512 = "kLTDLwd0B1jG08NBF3R5rqULtv/f8x3rOFByTDz4J53ttIQEDmALqKqXY0J+XQeN0aV2FBxY8nJDf88yvOPAqQ==";
      };
    }
    {
      name = "_vue_runtime_core___runtime_core_3.3.4.tgz";
      path = fetchurl {
        name = "_vue_runtime_core___runtime_core_3.3.4.tgz";
        url  = "https://registry.yarnpkg.com/@vue/runtime-core/-/runtime-core-3.3.4.tgz";
        sha512 = "R+bqxMN6pWO7zGI4OMlmvePOdP2c93GsHFM/siJI7O2nxFRzj55pLwkpCedEY+bTMgp5miZ8CxfIZo3S+gFqvA==";
      };
    }
    {
      name = "_vue_runtime_dom___runtime_dom_3.3.4.tgz";
      path = fetchurl {
        name = "_vue_runtime_dom___runtime_dom_3.3.4.tgz";
        url  = "https://registry.yarnpkg.com/@vue/runtime-dom/-/runtime-dom-3.3.4.tgz";
        sha512 = "Aj5bTJ3u5sFsUckRghsNjVTtxZQ1OyMWCr5dZRAPijF/0Vy4xEoRCwLyHXcj4D0UFbJ4lbx3gPTgg06K/GnPnQ==";
      };
    }
    {
      name = "_vue_server_renderer___server_renderer_3.3.4.tgz";
      path = fetchurl {
        name = "_vue_server_renderer___server_renderer_3.3.4.tgz";
        url  = "https://registry.yarnpkg.com/@vue/server-renderer/-/server-renderer-3.3.4.tgz";
        sha512 = "Q6jDDzR23ViIb67v+vM1Dqntu+HUexQcsWKhhQa4ARVzxOY2HbC7QRW/ggkDBd5BU+uM1sV6XOAP0b216o34JQ==";
      };
    }
    {
      name = "_vue_shared___shared_3.3.4.tgz";
      path = fetchurl {
        name = "_vue_shared___shared_3.3.4.tgz";
        url  = "https://registry.yarnpkg.com/@vue/shared/-/shared-3.3.4.tgz";
        sha512 = "7OjdcV8vQ74eiz1TZLzZP4JwqM5fA94K6yntPS5Z25r9HDuGNzaGdgvwKYq6S+MxwF0TFRwe50fIR/MYnakdkQ==";
      };
    }
    {
      name = "_vuetify_loader_shared___loader_shared_1.7.1.tgz";
      path = fetchurl {
        name = "_vuetify_loader_shared___loader_shared_1.7.1.tgz";
        url  = "https://registry.yarnpkg.com/@vuetify/loader-shared/-/loader-shared-1.7.1.tgz";
        sha512 = "kLUvuAed6RCvkeeTNJzuy14pqnkur8lTuner7v7pNE/kVhPR97TuyXwBSBMR1cJeiLiOfu6SF5XlCYbXByEx1g==";
      };
    }
    {
      name = "balanced_match___balanced_match_1.0.2.tgz";
      path = fetchurl {
        name = "balanced_match___balanced_match_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/balanced-match/-/balanced-match-1.0.2.tgz";
        sha512 = "3oSeUO0TMV67hN1AmbXsK4yaqU7tjiHlbxRDZOpH0KW9+CeX4bRAaX0Anxt0tx2MrpRpWwQaPwIlISEJhYU5Pw==";
      };
    }
    {
      name = "brace_expansion___brace_expansion_1.1.11.tgz";
      path = fetchurl {
        name = "brace_expansion___brace_expansion_1.1.11.tgz";
        url  = "https://registry.yarnpkg.com/brace-expansion/-/brace-expansion-1.1.11.tgz";
        sha512 = "iCuPHDFgrHX7H2vEI/5xpz07zSHB00TpugqhmYtVmMO6518mCuRMoOYFldEBl0g187ufozdaHgWKcYFb61qGiA==";
      };
    }
    {
      name = "brace_expansion___brace_expansion_2.0.1.tgz";
      path = fetchurl {
        name = "brace_expansion___brace_expansion_2.0.1.tgz";
        url  = "https://registry.yarnpkg.com/brace-expansion/-/brace-expansion-2.0.1.tgz";
        sha512 = "XnAIvQ8eM+kC6aULx6wuQiwVsnzsi9d3WxzV3FpWTGA19F621kwdbsAcFKXgKUHZWsy+mY6iL1sHTxWEFCytDA==";
      };
    }
    {
      name = "commondir___commondir_1.0.1.tgz";
      path = fetchurl {
        name = "commondir___commondir_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/commondir/-/commondir-1.0.1.tgz";
        sha512 = "W9pAhw0ja1Edb5GVdIF1mjZw/ASI0AlShXM83UUGe2DVr5TdAPEA1OA8m/g8zWp9x6On7gqufY+FatDbC3MDQg==";
      };
    }
    {
      name = "concat_map___concat_map_0.0.1.tgz";
      path = fetchurl {
        name = "concat_map___concat_map_0.0.1.tgz";
        url  = "https://registry.yarnpkg.com/concat-map/-/concat-map-0.0.1.tgz";
        sha512 = "/Srv4dswyQNBfohGpz9o6Yb3Gz3SrUDqBH5rTuhGR7ahtlbYKnVxw2bCFMRljaA7EXHaXZ8wsHdodFvbkhKmqg==";
      };
    }
    {
      name = "csstype___csstype_3.1.2.tgz";
      path = fetchurl {
        name = "csstype___csstype_3.1.2.tgz";
        url  = "https://registry.yarnpkg.com/csstype/-/csstype-3.1.2.tgz";
        sha512 = "I7K1Uu0MBPzaFKg4nI5Q7Vs2t+3gWWW648spaF+Rg7pI9ds18Ugn+lvg4SHczUdKlHI5LWBXyqfS8+DufyBsgQ==";
      };
    }
    {
      name = "de_indent___de_indent_1.0.2.tgz";
      path = fetchurl {
        name = "de_indent___de_indent_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/de-indent/-/de-indent-1.0.2.tgz";
        sha512 = "e/1zu3xH5MQryN2zdVaF0OrdNLUbvWxzMbi+iNA6Bky7l1RoP8a2fIbRocyHclXt/arDrrR6lL3TqFD9pMQTsg==";
      };
    }
    {
      name = "debug___debug_4.3.4.tgz";
      path = fetchurl {
        name = "debug___debug_4.3.4.tgz";
        url  = "https://registry.yarnpkg.com/debug/-/debug-4.3.4.tgz";
        sha512 = "PRWFHuSU3eDtQJPvnNY7Jcket1j0t5OuOsFzPPzsekD52Zl8qUfFIPEiswXqIvHWGVHOgX+7G/vCNNhehwxfkQ==";
      };
    }
    {
      name = "esbuild___esbuild_0.17.19.tgz";
      path = fetchurl {
        name = "esbuild___esbuild_0.17.19.tgz";
        url  = "https://registry.yarnpkg.com/esbuild/-/esbuild-0.17.19.tgz";
        sha512 = "XQ0jAPFkK/u3LcVRcvVHQcTIqD6E2H1fvZMA5dQPSOWb3suUbWbfbRf94pjc0bNzRYLfIrDRQXr7X+LHIm5oHw==";
      };
    }
    {
      name = "estree_walker___estree_walker_2.0.2.tgz";
      path = fetchurl {
        name = "estree_walker___estree_walker_2.0.2.tgz";
        url  = "https://registry.yarnpkg.com/estree-walker/-/estree-walker-2.0.2.tgz";
        sha512 = "Rfkk/Mp/DL7JVje3u18FxFujQlTNR2q6QfMSMB7AvCBx91NGj/ba3kCfza0f6dVDbw7YlRf/nDrn7pQrCCyQ/w==";
      };
    }
    {
      name = "find_cache_dir___find_cache_dir_3.3.2.tgz";
      path = fetchurl {
        name = "find_cache_dir___find_cache_dir_3.3.2.tgz";
        url  = "https://registry.yarnpkg.com/find-cache-dir/-/find-cache-dir-3.3.2.tgz";
        sha512 = "wXZV5emFEjrridIgED11OoUKLxiYjAcqot/NJdAkOhlJ+vGzwhOAfcG5OX1jP+S0PcjEn8bdMJv+g2jwQ3Onig==";
      };
    }
    {
      name = "find_up___find_up_4.1.0.tgz";
      path = fetchurl {
        name = "find_up___find_up_4.1.0.tgz";
        url  = "https://registry.yarnpkg.com/find-up/-/find-up-4.1.0.tgz";
        sha512 = "PpOwAdQ/YlXQ2vj8a3h8IipDuYRi3wceVQQGYWxNINccq40Anw7BlsEXCMbt1Zt+OLA6Fq9suIpIWD0OsnISlw==";
      };
    }
    {
      name = "fs.realpath___fs.realpath_1.0.0.tgz";
      path = fetchurl {
        name = "fs.realpath___fs.realpath_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/fs.realpath/-/fs.realpath-1.0.0.tgz";
        sha512 = "OO0pH2lK6a0hZnAdau5ItzHPI6pUlvI7jMVnxUQRtw4owF2wk8lOSabtGDCTP4Ggrg2MbGnWO9X8K1t4+fGMDw==";
      };
    }
    {
      name = "fsevents___fsevents_2.3.2.tgz";
      path = fetchurl {
        name = "fsevents___fsevents_2.3.2.tgz";
        url  = "https://registry.yarnpkg.com/fsevents/-/fsevents-2.3.2.tgz";
        sha512 = "xiqMQR4xAeHTuB9uWm+fFRcIOgKBMiOBP+eXiyT7jsgVCq1bkVygt00oASowB7EdtpOHaaPgKt812P9ab+DDKA==";
      };
    }
    {
      name = "glob___glob_7.2.3.tgz";
      path = fetchurl {
        name = "glob___glob_7.2.3.tgz";
        url  = "https://registry.yarnpkg.com/glob/-/glob-7.2.3.tgz";
        sha512 = "nFR0zLpU2YCaRxwoCJvL6UvCH2JFyFVIvwTLsIf21AuHlMskA1hhTdk+LlYJtOlYt9v6dvszD2BGRqBL+iQK9Q==";
      };
    }
    {
      name = "he___he_1.2.0.tgz";
      path = fetchurl {
        name = "he___he_1.2.0.tgz";
        url  = "https://registry.yarnpkg.com/he/-/he-1.2.0.tgz";
        sha512 = "F/1DnUGPopORZi0ni+CvrCgHQ5FyEAHRLSApuYWMmrbSwoN2Mn/7k+Gl38gJnR7yyDZk6WLXwiGod1JOWNDKGw==";
      };
    }
    {
      name = "inflight___inflight_1.0.6.tgz";
      path = fetchurl {
        name = "inflight___inflight_1.0.6.tgz";
        url  = "https://registry.yarnpkg.com/inflight/-/inflight-1.0.6.tgz";
        sha512 = "k92I/b08q4wvFscXCLvqfsHCrjrF7yiXsQuIVvVE7N82W3+aqpzuUdBbfhWcy/FZR3/4IgflMgKLOsvPDrGCJA==";
      };
    }
    {
      name = "inherits___inherits_2.0.4.tgz";
      path = fetchurl {
        name = "inherits___inherits_2.0.4.tgz";
        url  = "https://registry.yarnpkg.com/inherits/-/inherits-2.0.4.tgz";
        sha512 = "k/vGaX4/Yla3WzyMCvTQOXYeIHvqOKtnqBduzTHpzpQZzAskKMhZ2K+EnBiSM9zGSoIFeMpXKxa4dYeZIQqewQ==";
      };
    }
    {
      name = "locate_path___locate_path_5.0.0.tgz";
      path = fetchurl {
        name = "locate_path___locate_path_5.0.0.tgz";
        url  = "https://registry.yarnpkg.com/locate-path/-/locate-path-5.0.0.tgz";
        sha512 = "t7hw9pI+WvuwNJXwk5zVHpyhIqzg2qTlklJOf0mVxGSbe3Fp2VieZcduNYjaLDoy6p9uGpQEGWG87WpMKlNq8g==";
      };
    }
    {
      name = "lru_cache___lru_cache_6.0.0.tgz";
      path = fetchurl {
        name = "lru_cache___lru_cache_6.0.0.tgz";
        url  = "https://registry.yarnpkg.com/lru-cache/-/lru-cache-6.0.0.tgz";
        sha512 = "Jo6dJ04CmSjuznwJSS3pUeWmd/H0ffTlkXXgwZi+eq1UCmqQwCh+eLsYOYCwY991i2Fah4h1BEMCx4qThGbsiA==";
      };
    }
    {
      name = "magic_string___magic_string_0.30.0.tgz";
      path = fetchurl {
        name = "magic_string___magic_string_0.30.0.tgz";
        url  = "https://registry.yarnpkg.com/magic-string/-/magic-string-0.30.0.tgz";
        sha512 = "LA+31JYDJLs82r2ScLrlz1GjSgu66ZV518eyWT+S8VhyQn/JL0u9MeBOvQMGYiPk1DBiSN9DDMOcXvigJZaViQ==";
      };
    }
    {
      name = "make_dir___make_dir_3.1.0.tgz";
      path = fetchurl {
        name = "make_dir___make_dir_3.1.0.tgz";
        url  = "https://registry.yarnpkg.com/make-dir/-/make-dir-3.1.0.tgz";
        sha512 = "g3FeP20LNwhALb/6Cz6Dd4F2ngze0jz7tbzrD2wAV+o9FeNHe4rL+yK2md0J/fiSf1sa1ADhXqi5+oVwOM/eGw==";
      };
    }
    {
      name = "minimatch___minimatch_3.1.2.tgz";
      path = fetchurl {
        name = "minimatch___minimatch_3.1.2.tgz";
        url  = "https://registry.yarnpkg.com/minimatch/-/minimatch-3.1.2.tgz";
        sha512 = "J7p63hRiAjw1NDEww1W7i37+ByIrOWO5XQQAzZ3VOcL0PNybwpfmV/N05zFAzwQ9USyEcX6t3UO+K5aqBQOIHw==";
      };
    }
    {
      name = "minimatch___minimatch_9.0.1.tgz";
      path = fetchurl {
        name = "minimatch___minimatch_9.0.1.tgz";
        url  = "https://registry.yarnpkg.com/minimatch/-/minimatch-9.0.1.tgz";
        sha512 = "0jWhJpD/MdhPXwPuiRkCbfYfSKp2qnn2eOc279qI7f+osl/l+prKSrvhg157zSYvx/1nmgn2NqdT6k2Z7zSH9w==";
      };
    }
    {
      name = "ms___ms_2.1.2.tgz";
      path = fetchurl {
        name = "ms___ms_2.1.2.tgz";
        url  = "https://registry.yarnpkg.com/ms/-/ms-2.1.2.tgz";
        sha512 = "sGkPx+VjMtmA6MX27oA4FBFELFCZZ4S4XqeGOXCv68tT+jb3vk/RyaKWP0PTKyWtmLSM0b+adUTEvbs1PEaH2w==";
      };
    }
    {
      name = "muggle_string___muggle_string_0.2.2.tgz";
      path = fetchurl {
        name = "muggle_string___muggle_string_0.2.2.tgz";
        url  = "https://registry.yarnpkg.com/muggle-string/-/muggle-string-0.2.2.tgz";
        sha512 = "YVE1mIJ4VpUMqZObFndk9CJu6DBJR/GB13p3tXuNbwD4XExaI5EOuRl6BHeIDxIqXZVxSfAC+y6U1Z/IxCfKUg==";
      };
    }
    {
      name = "nanoid___nanoid_3.3.6.tgz";
      path = fetchurl {
        name = "nanoid___nanoid_3.3.6.tgz";
        url  = "https://registry.yarnpkg.com/nanoid/-/nanoid-3.3.6.tgz";
        sha512 = "BGcqMMJuToF7i1rt+2PWSNVnWIkGCU78jBG3RxO/bZlnZPK2Cmi2QaffxGO/2RvWi9sL+FAiRiXMgsyxQ1DIDA==";
      };
    }
    {
      name = "once___once_1.4.0.tgz";
      path = fetchurl {
        name = "once___once_1.4.0.tgz";
        url  = "https://registry.yarnpkg.com/once/-/once-1.4.0.tgz";
        sha512 = "lNaJgI+2Q5URQBkccEKHTQOPaXdUxnZZElQTZY0MFUAuaEqe1E+Nyvgdz/aIyNi6Z9MzO5dv1H8n58/GELp3+w==";
      };
    }
    {
      name = "p_limit___p_limit_2.3.0.tgz";
      path = fetchurl {
        name = "p_limit___p_limit_2.3.0.tgz";
        url  = "https://registry.yarnpkg.com/p-limit/-/p-limit-2.3.0.tgz";
        sha512 = "//88mFWSJx8lxCzwdAABTJL2MyWB12+eIY7MDL2SqLmAkeKU9qxRvWuSyTjm3FUmpBEMuFfckAIqEaVGUDxb6w==";
      };
    }
    {
      name = "p_locate___p_locate_4.1.0.tgz";
      path = fetchurl {
        name = "p_locate___p_locate_4.1.0.tgz";
        url  = "https://registry.yarnpkg.com/p-locate/-/p-locate-4.1.0.tgz";
        sha512 = "R79ZZ/0wAxKGu3oYMlz8jy/kbhsNrS7SKZ7PxEHBgJ5+F2mtFW2fK2cOtBh1cHYkQsbzFV7I+EoRKe6Yt0oK7A==";
      };
    }
    {
      name = "p_try___p_try_2.2.0.tgz";
      path = fetchurl {
        name = "p_try___p_try_2.2.0.tgz";
        url  = "https://registry.yarnpkg.com/p-try/-/p-try-2.2.0.tgz";
        sha512 = "R4nPAVTAU0B9D35/Gk3uJf/7XYbQcyohSKdvAxIRSNghFl4e71hVoGnBNQz9cWaXxO2I10KTC+3jMdvvoKw6dQ==";
      };
    }
    {
      name = "path_exists___path_exists_4.0.0.tgz";
      path = fetchurl {
        name = "path_exists___path_exists_4.0.0.tgz";
        url  = "https://registry.yarnpkg.com/path-exists/-/path-exists-4.0.0.tgz";
        sha512 = "ak9Qy5Q7jYb2Wwcey5Fpvg2KoAc/ZIhLSLOSBmRmygPsGwkVVt0fZa0qrtMz+m6tJTAHfZQ8FnmB4MG4LWy7/w==";
      };
    }
    {
      name = "path_is_absolute___path_is_absolute_1.0.1.tgz";
      path = fetchurl {
        name = "path_is_absolute___path_is_absolute_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/path-is-absolute/-/path-is-absolute-1.0.1.tgz";
        sha512 = "AVbw3UJ2e9bq64vSaS9Am0fje1Pa8pbGqTTsmXfaIiMpnr5DlDhfJOuLj9Sf95ZPVDAUerDfEk88MPmPe7UCQg==";
      };
    }
    {
      name = "picocolors___picocolors_1.0.0.tgz";
      path = fetchurl {
        name = "picocolors___picocolors_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/picocolors/-/picocolors-1.0.0.tgz";
        sha512 = "1fygroTLlHu66zi26VoTDv8yRgm0Fccecssto+MhsZ0D/DGW2sm8E8AjW7NU5VVTRt5GxbeZ5qBuJr+HyLYkjQ==";
      };
    }
    {
      name = "pkg_dir___pkg_dir_4.2.0.tgz";
      path = fetchurl {
        name = "pkg_dir___pkg_dir_4.2.0.tgz";
        url  = "https://registry.yarnpkg.com/pkg-dir/-/pkg-dir-4.2.0.tgz";
        sha512 = "HRDzbaKjC+AOWVXxAU/x54COGeIv9eb+6CkDSQoNTt4XyWoIJvuPsXizxu/Fr23EiekbtZwmh1IcIG/l/a10GQ==";
      };
    }
    {
      name = "postcss___postcss_8.4.23.tgz";
      path = fetchurl {
        name = "postcss___postcss_8.4.23.tgz";
        url  = "https://registry.yarnpkg.com/postcss/-/postcss-8.4.23.tgz";
        sha512 = "bQ3qMcpF6A/YjR55xtoTr0jGOlnPOKAIMdOWiv0EIT6HVPEaJiJB4NLljSbiHoC2RX7DN5Uvjtpbg1NPdwv1oA==";
      };
    }
    {
      name = "rollup___rollup_3.23.0.tgz";
      path = fetchurl {
        name = "rollup___rollup_3.23.0.tgz";
        url  = "https://registry.yarnpkg.com/rollup/-/rollup-3.23.0.tgz";
        sha512 = "h31UlwEi7FHihLe1zbk+3Q7z1k/84rb9BSwmBSr/XjOCEaBJ2YyedQDuM0t/kfOS0IxM+vk1/zI9XxYj9V+NJQ==";
      };
    }
    {
      name = "sax___sax_1.2.4.tgz";
      path = fetchurl {
        name = "sax___sax_1.2.4.tgz";
        url  = "https://registry.yarnpkg.com/sax/-/sax-1.2.4.tgz";
        sha512 = "NqVDv9TpANUjFm0N8uM5GxL36UgKi9/atZw+x7YFnQ8ckwFGKrl4xX4yWtrey3UJm5nP1kUbnYgLopqWNSRhWw==";
      };
    }
    {
      name = "semver___semver_6.3.0.tgz";
      path = fetchurl {
        name = "semver___semver_6.3.0.tgz";
        url  = "https://registry.yarnpkg.com/semver/-/semver-6.3.0.tgz";
        sha512 = "b39TBaTSfV6yBrapU89p5fKekE2m/NwnDocOVruQFS1/veMgdzuPcnOM34M6CwxW8jH/lxEa5rBoDeUwu5HHTw==";
      };
    }
    {
      name = "semver___semver_7.5.1.tgz";
      path = fetchurl {
        name = "semver___semver_7.5.1.tgz";
        url  = "https://registry.yarnpkg.com/semver/-/semver-7.5.1.tgz";
        sha512 = "Wvss5ivl8TMRZXXESstBA4uR5iXgEN/VC5/sOcuXdVLzcdkz4HWetIoRfG5gb5X+ij/G9rw9YoGn3QoQ8OCSpw==";
      };
    }
    {
      name = "source_map_js___source_map_js_1.0.2.tgz";
      path = fetchurl {
        name = "source_map_js___source_map_js_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/source-map-js/-/source-map-js-1.0.2.tgz";
        sha512 = "R0XvVJ9WusLiqTCEiGCmICCMplcCkIwwR11mOSD9CR5u+IXYdiseeEuXCVAjS54zqwkLcPNnmU4OeJ6tUrWhDw==";
      };
    }
    {
      name = "source_map___source_map_0.7.4.tgz";
      path = fetchurl {
        name = "source_map___source_map_0.7.4.tgz";
        url  = "https://registry.yarnpkg.com/source-map/-/source-map-0.7.4.tgz";
        sha512 = "l3BikUxvPOcn5E74dZiq5BGsTb5yEwhaTSzccU6t4sDOH8NWJCstKO5QT2CvtFoK6F0saL7p9xHAqHOlCPJygA==";
      };
    }
    {
      name = "stylus___stylus_0.59.0.tgz";
      path = fetchurl {
        name = "stylus___stylus_0.59.0.tgz";
        url  = "https://registry.yarnpkg.com/stylus/-/stylus-0.59.0.tgz";
        sha512 = "lQ9w/XIOH5ZHVNuNbWW8D822r+/wBSO/d6XvtyHLF7LW4KaCIDeVbvn5DF8fGCJAUCwVhVi/h6J0NUcnylUEjg==";
      };
    }
    {
      name = "to_fast_properties___to_fast_properties_2.0.0.tgz";
      path = fetchurl {
        name = "to_fast_properties___to_fast_properties_2.0.0.tgz";
        url  = "https://registry.yarnpkg.com/to-fast-properties/-/to-fast-properties-2.0.0.tgz";
        sha512 = "/OaKK0xYrs3DmxRYqL/yDc+FxFUVYhDlXMhRmv3z915w2HF1tnN1omB354j8VUGO/hbRzyD6Y3sA7v7GS/ceog==";
      };
    }
    {
      name = "typescript___typescript_4.9.5.tgz";
      path = fetchurl {
        name = "typescript___typescript_4.9.5.tgz";
        url  = "https://registry.yarnpkg.com/typescript/-/typescript-4.9.5.tgz";
        sha512 = "1FXk9E2Hm+QzZQ7z+McJiHL4NW1F2EzMu9Nq9i3zAaGqibafqYwCVU6WyWAuyQRRzOlxou8xZSyXLEN8oKj24g==";
      };
    }
    {
      name = "upath___upath_2.0.1.tgz";
      path = fetchurl {
        name = "upath___upath_2.0.1.tgz";
        url  = "https://registry.yarnpkg.com/upath/-/upath-2.0.1.tgz";
        sha512 = "1uEe95xksV1O0CYKXo8vQvN1JEbtJp7lb7C5U9HMsIp6IVwntkH/oNUzyVNQSd4S1sYk2FpSSW44FqMc8qee5w==";
      };
    }
    {
      name = "vite_plugin_vuetify___vite_plugin_vuetify_1.0.2.tgz";
      path = fetchurl {
        name = "vite_plugin_vuetify___vite_plugin_vuetify_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/vite-plugin-vuetify/-/vite-plugin-vuetify-1.0.2.tgz";
        sha512 = "MubIcKD33O8wtgQXlbEXE7ccTEpHZ8nPpe77y9Wy3my2MWw/PgehP9VqTp92BLqr0R1dSL970Lynvisx3UxBFw==";
      };
    }
    {
      name = "vite___vite_4.3.8.tgz";
      path = fetchurl {
        name = "vite___vite_4.3.8.tgz";
        url  = "https://registry.yarnpkg.com/vite/-/vite-4.3.8.tgz";
        sha512 = "uYB8PwN7hbMrf4j1xzGDk/lqjsZvCDbt/JC5dyfxc19Pg8kRm14LinK/uq+HSLNswZEoKmweGdtpbnxRtrAXiQ==";
      };
    }
    {
      name = "vue_router___vue_router_4.2.1.tgz";
      path = fetchurl {
        name = "vue_router___vue_router_4.2.1.tgz";
        url  = "https://registry.yarnpkg.com/vue-router/-/vue-router-4.2.1.tgz";
        sha512 = "nW28EeifEp8Abc5AfmAShy5ZKGsGzjcnZ3L1yc2DYUo+MqbBClrRP9yda3dIekM4I50/KnEwo1wkBLf7kHH5Cw==";
      };
    }
    {
      name = "vue_template_compiler___vue_template_compiler_2.7.14.tgz";
      path = fetchurl {
        name = "vue_template_compiler___vue_template_compiler_2.7.14.tgz";
        url  = "https://registry.yarnpkg.com/vue-template-compiler/-/vue-template-compiler-2.7.14.tgz";
        sha512 = "zyA5Y3ArvVG0NacJDkkzJuPQDF8RFeRlzV2vLeSnhSpieO6LK2OVbdLPi5MPPs09Ii+gMO8nY4S3iKQxBxDmWQ==";
      };
    }
    {
      name = "vue_tsc___vue_tsc_1.6.5.tgz";
      path = fetchurl {
        name = "vue_tsc___vue_tsc_1.6.5.tgz";
        url  = "https://registry.yarnpkg.com/vue-tsc/-/vue-tsc-1.6.5.tgz";
        sha512 = "Wtw3J7CC+JM2OR56huRd5iKlvFWpvDiU+fO1+rqyu4V2nMTotShz4zbOZpW5g9fUOcjnyZYfBo5q5q+D/q27JA==";
      };
    }
    {
      name = "vue___vue_3.3.4.tgz";
      path = fetchurl {
        name = "vue___vue_3.3.4.tgz";
        url  = "https://registry.yarnpkg.com/vue/-/vue-3.3.4.tgz";
        sha512 = "VTyEYn3yvIeY1Py0WaYGZsXnz3y5UnGi62GjVEqvEGPl6nxbOrCXbVOTQWBEJUqAyTUk2uJ5JLVnYJ6ZzGbrSw==";
      };
    }
    {
      name = "vuetify___vuetify_3.3.1.tgz";
      path = fetchurl {
        name = "vuetify___vuetify_3.3.1.tgz";
        url  = "https://registry.yarnpkg.com/vuetify/-/vuetify-3.3.1.tgz";
        sha512 = "shmBLeNFjQ9Trf7XusRtKpqCak+EK7zdUiJP2QXbXFgOQP3Ju04iyE/SJWn2xFNYaoJjULWenwOcdlkq9SIZ8A==";
      };
    }
    {
      name = "wrappy___wrappy_1.0.2.tgz";
      path = fetchurl {
        name = "wrappy___wrappy_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/wrappy/-/wrappy-1.0.2.tgz";
        sha512 = "l4Sp/DRseor9wL6EvV2+TuQn63dMkPjZ/sp9XkghTEbV9KlPS1xUsZ3u7/IQO4wxtcFB4bgpQPRcR3QCvezPcQ==";
      };
    }
    {
      name = "yallist___yallist_4.0.0.tgz";
      path = fetchurl {
        name = "yallist___yallist_4.0.0.tgz";
        url  = "https://registry.yarnpkg.com/yallist/-/yallist-4.0.0.tgz";
        sha512 = "3wdGidZyq5PB084XLES5TpOSRA3wjXAlIWMhum2kRcv/41Sn2emQ0dycQW4uZXLejwKvg6EsvbdlVL+FYEct7A==";
      };
    }
  ];
}
