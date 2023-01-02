{ fetchurl, fetchgit, linkFarm, runCommand, gnutar }: rec {
  offline_cache = linkFarm "offline" packages;
  packages = [
    {
      name = "_adobe_css_tools___css_tools_4.0.1.tgz";
      path = fetchurl {
        name = "_adobe_css_tools___css_tools_4.0.1.tgz";
        url  = "https://registry.yarnpkg.com/@adobe/css-tools/-/css-tools-4.0.1.tgz";
        sha512 = "+u76oB43nOHrF4DDWRLWDCtci7f3QJoEBigemIdIeTi1ODqjx6Tad9NCVnPRwewWlKkVab5PlK8DCtPTyX7S8g==";
      };
    }
    {
      name = "_babel_parser___parser_7.20.7.tgz";
      path = fetchurl {
        name = "_babel_parser___parser_7.20.7.tgz";
        url  = "https://registry.yarnpkg.com/@babel/parser/-/parser-7.20.7.tgz";
        sha512 = "T3Z9oHybU+0vZlY9CiDSJQTD5ZapcW18ZctFMi0MOAl/4BjFF4ul7NVSARLdbGO5vDqy9eQiGTV0LtKfvCYvcg==";
      };
    }
    {
      name = "_esbuild_android_arm64___android_arm64_0.16.12.tgz";
      path = fetchurl {
        name = "_esbuild_android_arm64___android_arm64_0.16.12.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/android-arm64/-/android-arm64-0.16.12.tgz";
        sha512 = "0LacmiIW+X0/LOLMZqYtZ7d4uY9fxYABAYhSSOu+OGQVBqH4N5eIYgkT7bBFnR4Nm3qo6qS3RpHKVrDASqj/uQ==";
      };
    }
    {
      name = "_esbuild_android_arm___android_arm_0.16.12.tgz";
      path = fetchurl {
        name = "_esbuild_android_arm___android_arm_0.16.12.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/android-arm/-/android-arm-0.16.12.tgz";
        sha512 = "CTWgMJtpCyCltrvipZrrcjjRu+rzm6pf9V8muCsJqtKujR3kPmU4ffbckvugNNaRmhxAF1ZI3J+0FUIFLFg8KA==";
      };
    }
    {
      name = "_esbuild_android_x64___android_x64_0.16.12.tgz";
      path = fetchurl {
        name = "_esbuild_android_x64___android_x64_0.16.12.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/android-x64/-/android-x64-0.16.12.tgz";
        sha512 = "sS5CR3XBKQXYpSGMM28VuiUnbX83Z+aWPZzClW+OB2JquKqxoiwdqucJ5qvXS8pM6Up3RtJfDnRQZkz3en2z5g==";
      };
    }
    {
      name = "_esbuild_darwin_arm64___darwin_arm64_0.16.12.tgz";
      path = fetchurl {
        name = "_esbuild_darwin_arm64___darwin_arm64_0.16.12.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/darwin-arm64/-/darwin-arm64-0.16.12.tgz";
        sha512 = "Dpe5hOAQiQRH20YkFAg+wOpcd4PEuXud+aGgKBQa/VriPJA8zuVlgCOSTwna1CgYl05lf6o5els4dtuyk1qJxQ==";
      };
    }
    {
      name = "_esbuild_darwin_x64___darwin_x64_0.16.12.tgz";
      path = fetchurl {
        name = "_esbuild_darwin_x64___darwin_x64_0.16.12.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/darwin-x64/-/darwin-x64-0.16.12.tgz";
        sha512 = "ApGRA6X5txIcxV0095X4e4KKv87HAEXfuDRcGTniDWUUN+qPia8sl/BqG/0IomytQWajnUn4C7TOwHduk/FXBQ==";
      };
    }
    {
      name = "_esbuild_freebsd_arm64___freebsd_arm64_0.16.12.tgz";
      path = fetchurl {
        name = "_esbuild_freebsd_arm64___freebsd_arm64_0.16.12.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/freebsd-arm64/-/freebsd-arm64-0.16.12.tgz";
        sha512 = "AMdK2gA9EU83ccXCWS1B/KcWYZCj4P3vDofZZkl/F/sBv/fphi2oUqUTox/g5GMcIxk8CF1CVYTC82+iBSyiUg==";
      };
    }
    {
      name = "_esbuild_freebsd_x64___freebsd_x64_0.16.12.tgz";
      path = fetchurl {
        name = "_esbuild_freebsd_x64___freebsd_x64_0.16.12.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/freebsd-x64/-/freebsd-x64-0.16.12.tgz";
        sha512 = "KUKB9w8G/xaAbD39t6gnRBuhQ8vIYYlxGT2I+mT6UGRnCGRr1+ePFIGBQmf5V16nxylgUuuWVW1zU2ktKkf6WQ==";
      };
    }
    {
      name = "_esbuild_linux_arm64___linux_arm64_0.16.12.tgz";
      path = fetchurl {
        name = "_esbuild_linux_arm64___linux_arm64_0.16.12.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/linux-arm64/-/linux-arm64-0.16.12.tgz";
        sha512 = "29HXMLpLklDfmw7T2buGqq3HImSUaZ1ArmrPOMaNiZZQptOSZs32SQtOHEl8xWX5vfdwZqrBfNf8Te4nArVzKQ==";
      };
    }
    {
      name = "_esbuild_linux_arm___linux_arm_0.16.12.tgz";
      path = fetchurl {
        name = "_esbuild_linux_arm___linux_arm_0.16.12.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/linux-arm/-/linux-arm-0.16.12.tgz";
        sha512 = "vhDdIv6z4eL0FJyNVfdr3C/vdd/Wc6h1683GJsFoJzfKb92dU/v88FhWdigg0i6+3TsbSDeWbsPUXb4dif2abg==";
      };
    }
    {
      name = "_esbuild_linux_ia32___linux_ia32_0.16.12.tgz";
      path = fetchurl {
        name = "_esbuild_linux_ia32___linux_ia32_0.16.12.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/linux-ia32/-/linux-ia32-0.16.12.tgz";
        sha512 = "JFDuNDTTfgD1LJg7wHA42o2uAO/9VzHYK0leAVnCQE/FdMB599YMH73ux+nS0xGr79pv/BK+hrmdRin3iLgQjg==";
      };
    }
    {
      name = "_esbuild_linux_loong64___linux_loong64_0.16.12.tgz";
      path = fetchurl {
        name = "_esbuild_linux_loong64___linux_loong64_0.16.12.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/linux-loong64/-/linux-loong64-0.16.12.tgz";
        sha512 = "xTGzVPqm6WKfCC0iuj1fryIWr1NWEM8DMhAIo+4rFgUtwy/lfHl+Obvus4oddzRDbBetLLmojfVZGmt/g/g+Rw==";
      };
    }
    {
      name = "_esbuild_linux_mips64el___linux_mips64el_0.16.12.tgz";
      path = fetchurl {
        name = "_esbuild_linux_mips64el___linux_mips64el_0.16.12.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/linux-mips64el/-/linux-mips64el-0.16.12.tgz";
        sha512 = "zI1cNgHa3Gol+vPYjIYHzKhU6qMyOQrvZ82REr5Fv7rlh5PG6SkkuCoH7IryPqR+BK2c/7oISGsvPJPGnO2bHQ==";
      };
    }
    {
      name = "_esbuild_linux_ppc64___linux_ppc64_0.16.12.tgz";
      path = fetchurl {
        name = "_esbuild_linux_ppc64___linux_ppc64_0.16.12.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/linux-ppc64/-/linux-ppc64-0.16.12.tgz";
        sha512 = "/C8OFXExoMmvTDIOAM54AhtmmuDHKoedUd0Otpfw3+AuuVGemA1nQK99oN909uZbLEU6Bi+7JheFMG3xGfZluQ==";
      };
    }
    {
      name = "_esbuild_linux_riscv64___linux_riscv64_0.16.12.tgz";
      path = fetchurl {
        name = "_esbuild_linux_riscv64___linux_riscv64_0.16.12.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/linux-riscv64/-/linux-riscv64-0.16.12.tgz";
        sha512 = "qeouyyc8kAGV6Ni6Isz8hUsKMr00EHgVwUKWNp1r4l88fHEoNTDB8mmestvykW6MrstoGI7g2EAsgr0nxmuGYg==";
      };
    }
    {
      name = "_esbuild_linux_s390x___linux_s390x_0.16.12.tgz";
      path = fetchurl {
        name = "_esbuild_linux_s390x___linux_s390x_0.16.12.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/linux-s390x/-/linux-s390x-0.16.12.tgz";
        sha512 = "s9AyI/5vz1U4NNqnacEGFElqwnHusWa81pskAf8JNDM2eb6b2E6PpBmT8RzeZv6/TxE6/TADn2g9bb0jOUmXwQ==";
      };
    }
    {
      name = "_esbuild_linux_x64___linux_x64_0.16.12.tgz";
      path = fetchurl {
        name = "_esbuild_linux_x64___linux_x64_0.16.12.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/linux-x64/-/linux-x64-0.16.12.tgz";
        sha512 = "e8YA7GQGLWhvakBecLptUiKxOk4E/EPtSckS1i0MGYctW8ouvNUoh7xnU15PGO2jz7BYl8q1R6g0gE5HFtzpqQ==";
      };
    }
    {
      name = "_esbuild_netbsd_x64___netbsd_x64_0.16.12.tgz";
      path = fetchurl {
        name = "_esbuild_netbsd_x64___netbsd_x64_0.16.12.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/netbsd-x64/-/netbsd-x64-0.16.12.tgz";
        sha512 = "z2+kUxmOqBS+6SRVd57iOLIHE8oGOoEnGVAmwjm2aENSP35HPS+5cK+FL1l+rhrsJOFIPrNHqDUNechpuG96Sg==";
      };
    }
    {
      name = "_esbuild_openbsd_x64___openbsd_x64_0.16.12.tgz";
      path = fetchurl {
        name = "_esbuild_openbsd_x64___openbsd_x64_0.16.12.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/openbsd-x64/-/openbsd-x64-0.16.12.tgz";
        sha512 = "PAonw4LqIybwn2/vJujhbg1N9W2W8lw9RtXIvvZoyzoA/4rA4CpiuahVbASmQohiytRsixbNoIOUSjRygKXpyA==";
      };
    }
    {
      name = "_esbuild_sunos_x64___sunos_x64_0.16.12.tgz";
      path = fetchurl {
        name = "_esbuild_sunos_x64___sunos_x64_0.16.12.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/sunos-x64/-/sunos-x64-0.16.12.tgz";
        sha512 = "+wr1tkt1RERi+Zi/iQtkzmMH4nS8+7UIRxjcyRz7lur84wCkAITT50Olq/HiT4JN2X2bjtlOV6vt7ptW5Gw60Q==";
      };
    }
    {
      name = "_esbuild_win32_arm64___win32_arm64_0.16.12.tgz";
      path = fetchurl {
        name = "_esbuild_win32_arm64___win32_arm64_0.16.12.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/win32-arm64/-/win32-arm64-0.16.12.tgz";
        sha512 = "XEjeUSHmjsAOJk8+pXJu9pFY2O5KKQbHXZWQylJzQuIBeiGrpMeq9sTVrHefHxMOyxUgoKQTcaTS+VK/K5SviA==";
      };
    }
    {
      name = "_esbuild_win32_ia32___win32_ia32_0.16.12.tgz";
      path = fetchurl {
        name = "_esbuild_win32_ia32___win32_ia32_0.16.12.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/win32-ia32/-/win32-ia32-0.16.12.tgz";
        sha512 = "eRKPM7e0IecUAUYr2alW7JGDejrFJXmpjt4MlfonmQ5Rz9HWpKFGCjuuIRgKO7W9C/CWVFXdJ2GjddsBXqQI4A==";
      };
    }
    {
      name = "_esbuild_win32_x64___win32_x64_0.16.12.tgz";
      path = fetchurl {
        name = "_esbuild_win32_x64___win32_x64_0.16.12.tgz";
        url  = "https://registry.yarnpkg.com/@esbuild/win32-x64/-/win32-x64-0.16.12.tgz";
        sha512 = "iPYKN78t3op2+erv2frW568j1q0RpqX6JOLZ7oPPaAV1VaF7dDstOrNw37PVOYoTWE11pV4A1XUitpdEFNIsPg==";
      };
    }
    {
      name = "_mdi_font___font_7.1.96.tgz";
      path = fetchurl {
        name = "_mdi_font___font_7.1.96.tgz";
        url  = "https://registry.yarnpkg.com/@mdi/font/-/font-7.1.96.tgz";
        sha512 = "Imag6npmfkBDi2Ze2jiZVAPTDIKLxhz2Sx82xJ2zctyAU5LYJejLI5ChnDwiD9bMkQfVuzEsI98Q8toHyC+HCg==";
      };
    }
    {
      name = "_tauri_apps_api___api_1.2.0.tgz";
      path = fetchurl {
        name = "_tauri_apps_api___api_1.2.0.tgz";
        url  = "https://registry.yarnpkg.com/@tauri-apps/api/-/api-1.2.0.tgz";
        sha512 = "lsI54KI6HGf7VImuf/T9pnoejfgkNoXveP14pVV7XarrQ46rOejIVJLFqHI9sRReJMGdh2YuCoI3cc/yCWCsrw==";
      };
    }
    {
      name = "_tauri_apps_cli_darwin_arm64___cli_darwin_arm64_1.2.2.tgz";
      path = fetchurl {
        name = "_tauri_apps_cli_darwin_arm64___cli_darwin_arm64_1.2.2.tgz";
        url  = "https://registry.yarnpkg.com/@tauri-apps/cli-darwin-arm64/-/cli-darwin-arm64-1.2.2.tgz";
        sha512 = "W+Cp2weUMlvmGkRJeUjypbz9Lpl6o98xkgKAtobZSum5SNwpsBQfawJTESakNoD+FXyVg/snIk5sRdHge+tAaA==";
      };
    }
    {
      name = "_tauri_apps_cli_darwin_x64___cli_darwin_x64_1.2.2.tgz";
      path = fetchurl {
        name = "_tauri_apps_cli_darwin_x64___cli_darwin_x64_1.2.2.tgz";
        url  = "https://registry.yarnpkg.com/@tauri-apps/cli-darwin-x64/-/cli-darwin-x64-1.2.2.tgz";
        sha512 = "vmVAqt+ECH2d6cbcGJ7ddcCAZgmKe5xmxlL5r4xoaphu7OqU4gnv4VFURYkVltOfwzIFQVOPVSqwYyIDToCYNQ==";
      };
    }
    {
      name = "_tauri_apps_cli_linux_arm_gnueabihf___cli_linux_arm_gnueabihf_1.2.2.tgz";
      path = fetchurl {
        name = "_tauri_apps_cli_linux_arm_gnueabihf___cli_linux_arm_gnueabihf_1.2.2.tgz";
        url  = "https://registry.yarnpkg.com/@tauri-apps/cli-linux-arm-gnueabihf/-/cli-linux-arm-gnueabihf-1.2.2.tgz";
        sha512 = "yYTdQurgi4QZR8z+fANjl522jdQz/VtesFpw+C/A0+zXg7tiRjicsywBDdPsvNzCqFeGKKkmTR+Lny5qxhGaeQ==";
      };
    }
    {
      name = "_tauri_apps_cli_linux_arm64_gnu___cli_linux_arm64_gnu_1.2.2.tgz";
      path = fetchurl {
        name = "_tauri_apps_cli_linux_arm64_gnu___cli_linux_arm64_gnu_1.2.2.tgz";
        url  = "https://registry.yarnpkg.com/@tauri-apps/cli-linux-arm64-gnu/-/cli-linux-arm64-gnu-1.2.2.tgz";
        sha512 = "ZSOVT6Eq1ay2+27B8KfA0MnpO7KYzONU6TjenH7DNcQki6eWGG5JoNu8QQ9Mdn3dAzY0XBP9i1ZHQOFu4iPtEg==";
      };
    }
    {
      name = "_tauri_apps_cli_linux_arm64_musl___cli_linux_arm64_musl_1.2.2.tgz";
      path = fetchurl {
        name = "_tauri_apps_cli_linux_arm64_musl___cli_linux_arm64_musl_1.2.2.tgz";
        url  = "https://registry.yarnpkg.com/@tauri-apps/cli-linux-arm64-musl/-/cli-linux-arm64-musl-1.2.2.tgz";
        sha512 = "/NHSkqNQ+Pr4PshvyD1CeNFaPCaCpe1OeuAQgVi0rboSecC9fXN96G5dQbSBoxOUcCo6f8aTVE7zkZ4WchFVog==";
      };
    }
    {
      name = "_tauri_apps_cli_linux_x64_gnu___cli_linux_x64_gnu_1.2.2.tgz";
      path = fetchurl {
        name = "_tauri_apps_cli_linux_x64_gnu___cli_linux_x64_gnu_1.2.2.tgz";
        url  = "https://registry.yarnpkg.com/@tauri-apps/cli-linux-x64-gnu/-/cli-linux-x64-gnu-1.2.2.tgz";
        sha512 = "4YTmfPuyvlHsvCkATDMwhklfuQm3HKxYXv/IOW9H0ra6pS9efVhrFYIC9Vfv6XaKN85Vnn/FYTEGMJLwCxZw2Q==";
      };
    }
    {
      name = "_tauri_apps_cli_linux_x64_musl___cli_linux_x64_musl_1.2.2.tgz";
      path = fetchurl {
        name = "_tauri_apps_cli_linux_x64_musl___cli_linux_x64_musl_1.2.2.tgz";
        url  = "https://registry.yarnpkg.com/@tauri-apps/cli-linux-x64-musl/-/cli-linux-x64-musl-1.2.2.tgz";
        sha512 = "wr46tbscwFuCcA931R+ItOiUTT0djMmgKLd1HFCmFF82V9BKE2reIjr6O9l0NCXCo2WeD4pe3jA/Pt1dxDu+JA==";
      };
    }
    {
      name = "_tauri_apps_cli_win32_ia32_msvc___cli_win32_ia32_msvc_1.2.2.tgz";
      path = fetchurl {
        name = "_tauri_apps_cli_win32_ia32_msvc___cli_win32_ia32_msvc_1.2.2.tgz";
        url  = "https://registry.yarnpkg.com/@tauri-apps/cli-win32-ia32-msvc/-/cli-win32-ia32-msvc-1.2.2.tgz";
        sha512 = "6VmbVJOWUZJK5/JKhb3mNFKrKGfq0KV7lJGumfN95WJgkHeyL61p8bZit+o6ZgUGUhrOabkAawhDkrRY+ZQhIw==";
      };
    }
    {
      name = "_tauri_apps_cli_win32_x64_msvc___cli_win32_x64_msvc_1.2.2.tgz";
      path = fetchurl {
        name = "_tauri_apps_cli_win32_x64_msvc___cli_win32_x64_msvc_1.2.2.tgz";
        url  = "https://registry.yarnpkg.com/@tauri-apps/cli-win32-x64-msvc/-/cli-win32-x64-msvc-1.2.2.tgz";
        sha512 = "YRPJguJma+zSuRZpFoSZqls6+laggG1vqG0FPQWQTi+ywATgMpai2b2RZnffDlpHKp9mt4V/s2dtqOy6bpGZHg==";
      };
    }
    {
      name = "_tauri_apps_cli___cli_1.2.2.tgz";
      path = fetchurl {
        name = "_tauri_apps_cli___cli_1.2.2.tgz";
        url  = "https://registry.yarnpkg.com/@tauri-apps/cli/-/cli-1.2.2.tgz";
        sha512 = "D8zib3A0vWCvPPSyYLxww/OdDlVcY7fpcDVBH6qUvheOjj2aCyU7H9AYMRBwpgCfz8zY5+vomee+laLeB0H13w==";
      };
    }
    {
      name = "_types_node___node_18.11.18.tgz";
      path = fetchurl {
        name = "_types_node___node_18.11.18.tgz";
        url  = "https://registry.yarnpkg.com/@types/node/-/node-18.11.18.tgz";
        sha512 = "DHQpWGjyQKSHj3ebjFI/wRKcqQcdR+MoFBygntYOZytCqNfkd2ZC4ARDJ2DQqhjH5p85Nnd3jhUJIXrszFX/JA==";
      };
    }
    {
      name = "_vitejs_plugin_vue___plugin_vue_4.0.0.tgz";
      path = fetchurl {
        name = "_vitejs_plugin_vue___plugin_vue_4.0.0.tgz";
        url  = "https://registry.yarnpkg.com/@vitejs/plugin-vue/-/plugin-vue-4.0.0.tgz";
        sha512 = "e0X4jErIxAB5oLtDqbHvHpJe/uWNkdpYV83AOG2xo2tEVSzCzewgJMtREZM30wXnM5ls90hxiOtAuVU6H5JgbA==";
      };
    }
    {
      name = "_volar_language_core___language_core_1.0.19.tgz";
      path = fetchurl {
        name = "_volar_language_core___language_core_1.0.19.tgz";
        url  = "https://registry.yarnpkg.com/@volar/language-core/-/language-core-1.0.19.tgz";
        sha512 = "BRxhwqn66VHeLIxxgV4ybY9NDtwMp2bl1w7085qlK7i1pa4jeFR5lJG2U5qd0oI3e0PIWML+PryxSrKNd3+SZw==";
      };
    }
    {
      name = "_volar_source_map___source_map_1.0.19.tgz";
      path = fetchurl {
        name = "_volar_source_map___source_map_1.0.19.tgz";
        url  = "https://registry.yarnpkg.com/@volar/source-map/-/source-map-1.0.19.tgz";
        sha512 = "5fYKsl1evR/QAZ9LADto3kzbYKfpjZLWS9reNpxGR3ODPFTpaJgYk4lqghFyq4yU7/e/ZPZ1zLXjEsnL526URw==";
      };
    }
    {
      name = "_volar_typescript___typescript_1.0.19.tgz";
      path = fetchurl {
        name = "_volar_typescript___typescript_1.0.19.tgz";
        url  = "https://registry.yarnpkg.com/@volar/typescript/-/typescript-1.0.19.tgz";
        sha512 = "S6n945uhpc5J1qCVXVV4tz4k1nyxWaoG+wqy9TYdRDazPHeq9l45WDg58g/ehblUWux85TZN8i3zdsLRLkFrdw==";
      };
    }
    {
      name = "_volar_vue_language_core___vue_language_core_1.0.19.tgz";
      path = fetchurl {
        name = "_volar_vue_language_core___vue_language_core_1.0.19.tgz";
        url  = "https://registry.yarnpkg.com/@volar/vue-language-core/-/vue-language-core-1.0.19.tgz";
        sha512 = "3mIjJvQ+0tNOp+U9+Nggy92HYIqnltf882UMG9RuNHrd0Jn/rdvjRBs0jNTzwYDV9tn3tjDHGIfQak9XrUCaRg==";
      };
    }
    {
      name = "_volar_vue_typescript___vue_typescript_1.0.19.tgz";
      path = fetchurl {
        name = "_volar_vue_typescript___vue_typescript_1.0.19.tgz";
        url  = "https://registry.yarnpkg.com/@volar/vue-typescript/-/vue-typescript-1.0.19.tgz";
        sha512 = "HKaLCz/lb5xkJ1SyaMmms0Ww/OVStQ16qWttSbHRnnyRV/IDMFrwlovA/bIAPzHUq8EVoDAznRVsCysr2QCOGA==";
      };
    }
    {
      name = "_vue_compiler_core___compiler_core_3.2.45.tgz";
      path = fetchurl {
        name = "_vue_compiler_core___compiler_core_3.2.45.tgz";
        url  = "https://registry.yarnpkg.com/@vue/compiler-core/-/compiler-core-3.2.45.tgz";
        sha512 = "rcMj7H+PYe5wBV3iYeUgbCglC+pbpN8hBLTJvRiK2eKQiWqu+fG9F+8sW99JdL4LQi7Re178UOxn09puSXvn4A==";
      };
    }
    {
      name = "_vue_compiler_dom___compiler_dom_3.2.45.tgz";
      path = fetchurl {
        name = "_vue_compiler_dom___compiler_dom_3.2.45.tgz";
        url  = "https://registry.yarnpkg.com/@vue/compiler-dom/-/compiler-dom-3.2.45.tgz";
        sha512 = "tyYeUEuKqqZO137WrZkpwfPCdiiIeXYCcJ8L4gWz9vqaxzIQRccTSwSWZ/Axx5YR2z+LvpUbmPNXxuBU45lyRw==";
      };
    }
    {
      name = "_vue_compiler_sfc___compiler_sfc_3.2.45.tgz";
      path = fetchurl {
        name = "_vue_compiler_sfc___compiler_sfc_3.2.45.tgz";
        url  = "https://registry.yarnpkg.com/@vue/compiler-sfc/-/compiler-sfc-3.2.45.tgz";
        sha512 = "1jXDuWah1ggsnSAOGsec8cFjT/K6TMZ0sPL3o3d84Ft2AYZi2jWJgRMjw4iaK0rBfA89L5gw427H4n1RZQBu6Q==";
      };
    }
    {
      name = "_vue_compiler_ssr___compiler_ssr_3.2.45.tgz";
      path = fetchurl {
        name = "_vue_compiler_ssr___compiler_ssr_3.2.45.tgz";
        url  = "https://registry.yarnpkg.com/@vue/compiler-ssr/-/compiler-ssr-3.2.45.tgz";
        sha512 = "6BRaggEGqhWht3lt24CrIbQSRD5O07MTmd+LjAn5fJj568+R9eUD2F7wMQJjX859seSlrYog7sUtrZSd7feqrQ==";
      };
    }
    {
      name = "_vue_devtools_api___devtools_api_6.4.5.tgz";
      path = fetchurl {
        name = "_vue_devtools_api___devtools_api_6.4.5.tgz";
        url  = "https://registry.yarnpkg.com/@vue/devtools-api/-/devtools-api-6.4.5.tgz";
        sha512 = "JD5fcdIuFxU4fQyXUu3w2KpAJHzTVdN+p4iOX2lMWSHMOoQdMAcpFLZzm9Z/2nmsoZ1a96QEhZ26e50xLBsgOQ==";
      };
    }
    {
      name = "_vue_reactivity_transform___reactivity_transform_3.2.45.tgz";
      path = fetchurl {
        name = "_vue_reactivity_transform___reactivity_transform_3.2.45.tgz";
        url  = "https://registry.yarnpkg.com/@vue/reactivity-transform/-/reactivity-transform-3.2.45.tgz";
        sha512 = "BHVmzYAvM7vcU5WmuYqXpwaBHjsS8T63jlKGWVtHxAHIoMIlmaMyurUSEs1Zcg46M4AYT5MtB1U274/2aNzjJQ==";
      };
    }
    {
      name = "_vue_reactivity___reactivity_3.2.45.tgz";
      path = fetchurl {
        name = "_vue_reactivity___reactivity_3.2.45.tgz";
        url  = "https://registry.yarnpkg.com/@vue/reactivity/-/reactivity-3.2.45.tgz";
        sha512 = "PRvhCcQcyEVohW0P8iQ7HDcIOXRjZfAsOds3N99X/Dzewy8TVhTCT4uXpAHfoKjVTJRA0O0K+6QNkDIZAxNi3A==";
      };
    }
    {
      name = "_vue_runtime_core___runtime_core_3.2.45.tgz";
      path = fetchurl {
        name = "_vue_runtime_core___runtime_core_3.2.45.tgz";
        url  = "https://registry.yarnpkg.com/@vue/runtime-core/-/runtime-core-3.2.45.tgz";
        sha512 = "gzJiTA3f74cgARptqzYswmoQx0fIA+gGYBfokYVhF8YSXjWTUA2SngRzZRku2HbGbjzB6LBYSbKGIaK8IW+s0A==";
      };
    }
    {
      name = "_vue_runtime_dom___runtime_dom_3.2.45.tgz";
      path = fetchurl {
        name = "_vue_runtime_dom___runtime_dom_3.2.45.tgz";
        url  = "https://registry.yarnpkg.com/@vue/runtime-dom/-/runtime-dom-3.2.45.tgz";
        sha512 = "cy88YpfP5Ue2bDBbj75Cb4bIEZUMM/mAkDMfqDTpUYVgTf/kuQ2VQ8LebuZ8k6EudgH8pYhsGWHlY0lcxlvTwA==";
      };
    }
    {
      name = "_vue_server_renderer___server_renderer_3.2.45.tgz";
      path = fetchurl {
        name = "_vue_server_renderer___server_renderer_3.2.45.tgz";
        url  = "https://registry.yarnpkg.com/@vue/server-renderer/-/server-renderer-3.2.45.tgz";
        sha512 = "ebiMq7q24WBU1D6uhPK//2OTR1iRIyxjF5iVq/1a5I1SDMDyDu4Ts6fJaMnjrvD3MqnaiFkKQj+LKAgz5WIK3g==";
      };
    }
    {
      name = "_vue_shared___shared_3.2.45.tgz";
      path = fetchurl {
        name = "_vue_shared___shared_3.2.45.tgz";
        url  = "https://registry.yarnpkg.com/@vue/shared/-/shared-3.2.45.tgz";
        sha512 = "Ewzq5Yhimg7pSztDV+RH1UDKBzmtqieXQlpTVm2AwraoRL/Rks96mvd8Vgi7Lj+h+TH8dv7mXD3FRZR3TUvbSg==";
      };
    }
    {
      name = "_vuetify_loader_shared___loader_shared_1.7.0.tgz";
      path = fetchurl {
        name = "_vuetify_loader_shared___loader_shared_1.7.0.tgz";
        url  = "https://registry.yarnpkg.com/@vuetify/loader-shared/-/loader-shared-1.7.0.tgz";
        sha512 = "Db4K67wMhduDsbvdRBYkrYuomti+j0E/1vlz1lnDng5F9LYYBcXa60qypIazVGI6GX/CuY1vshN6XGtGQI4FKg==";
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
      name = "csstype___csstype_2.6.21.tgz";
      path = fetchurl {
        name = "csstype___csstype_2.6.21.tgz";
        url  = "https://registry.yarnpkg.com/csstype/-/csstype-2.6.21.tgz";
        sha512 = "Z1PhmomIfypOpoMjRQB70jfvy/wxT50qW08YXO5lMIJkrdq4yOTR+AW7FqutScmB9NkLwxo+jU+kZLbofZZq/w==";
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
      name = "esbuild___esbuild_0.16.12.tgz";
      path = fetchurl {
        name = "esbuild___esbuild_0.16.12.tgz";
        url  = "https://registry.yarnpkg.com/esbuild/-/esbuild-0.16.12.tgz";
        sha512 = "eq5KcuXajf2OmivCl4e89AD3j8fbV+UTE9vczEzq5haA07U9oOTzBWlh3+6ZdjJR7Rz2QfWZ2uxZyhZxBgJ4+g==";
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
      name = "function_bind___function_bind_1.1.1.tgz";
      path = fetchurl {
        name = "function_bind___function_bind_1.1.1.tgz";
        url  = "https://registry.yarnpkg.com/function-bind/-/function-bind-1.1.1.tgz";
        sha512 = "yIovAzMX49sF8Yl58fSCWJ5svSLuaibPxXQJFLmBObTuCr0Mf1KiPopGM9NiFjiYBCbfaa2Fh6breQ6ANVTI0A==";
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
      name = "has___has_1.0.3.tgz";
      path = fetchurl {
        name = "has___has_1.0.3.tgz";
        url  = "https://registry.yarnpkg.com/has/-/has-1.0.3.tgz";
        sha512 = "f2dvO0VU6Oej7RkWJGrehjbzMAjFp5/VKPp5tTpWIV4JHHZK1/BxbFRtf/siA2SWTe09caDmVtYYzWEIbBS4zw==";
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
      name = "is_core_module___is_core_module_2.11.0.tgz";
      path = fetchurl {
        name = "is_core_module___is_core_module_2.11.0.tgz";
        url  = "https://registry.yarnpkg.com/is-core-module/-/is-core-module-2.11.0.tgz";
        sha512 = "RRjxlvLDkD1YJwDbroBHMb+cukurkDWNyHx7D3oNB5x9rb5ogcksMC5wHCadcXoo67gVr/+3GFySh3134zi6rw==";
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
      name = "magic_string___magic_string_0.25.9.tgz";
      path = fetchurl {
        name = "magic_string___magic_string_0.25.9.tgz";
        url  = "https://registry.yarnpkg.com/magic-string/-/magic-string-0.25.9.tgz";
        sha512 = "RmF0AsMzgt25qzqqLc1+MbHmhdx0ojF2Fvs4XnOqz2ZOBXzzkEwc/dJQZCYHAn7v1jbVOjAZfK8msRn4BxO4VQ==";
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
      name = "minimatch___minimatch_5.1.2.tgz";
      path = fetchurl {
        name = "minimatch___minimatch_5.1.2.tgz";
        url  = "https://registry.yarnpkg.com/minimatch/-/minimatch-5.1.2.tgz";
        sha512 = "bNH9mmM9qsJ2X4r2Nat1B//1dJVcn3+iBLa3IgqJ7EbGaDNepL9QSHOxN4ng33s52VMMhhIfgCYDk3C4ZmlDAg==";
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
      name = "muggle_string___muggle_string_0.1.0.tgz";
      path = fetchurl {
        name = "muggle_string___muggle_string_0.1.0.tgz";
        url  = "https://registry.yarnpkg.com/muggle-string/-/muggle-string-0.1.0.tgz";
        sha512 = "Tr1knR3d2mKvvWthlk7202rywKbiOm4rVFLsfAaSIhJ6dt9o47W4S+JMtWhd/PW9Wrdew2/S2fSvhz3E2gkfEg==";
      };
    }
    {
      name = "nanoid___nanoid_3.3.4.tgz";
      path = fetchurl {
        name = "nanoid___nanoid_3.3.4.tgz";
        url  = "https://registry.yarnpkg.com/nanoid/-/nanoid-3.3.4.tgz";
        sha512 = "MqBkQh/OHTS2egovRtLk45wEyNXwF+cokD+1YPf9u5VfJiRdAiRwB2froX5Co9Rh20xs4siNPm8naNotSD6RBw==";
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
      name = "path_parse___path_parse_1.0.7.tgz";
      path = fetchurl {
        name = "path_parse___path_parse_1.0.7.tgz";
        url  = "https://registry.yarnpkg.com/path-parse/-/path-parse-1.0.7.tgz";
        sha512 = "LDJzPVEEEPR+y48z93A0Ed0yXb8pAByGWo/k5YYdYgpY2/2EsOsksJrq7lOHxryrVOn1ejG6oAp8ahvOIQD8sw==";
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
      name = "postcss___postcss_8.4.20.tgz";
      path = fetchurl {
        name = "postcss___postcss_8.4.20.tgz";
        url  = "https://registry.yarnpkg.com/postcss/-/postcss-8.4.20.tgz";
        sha512 = "6Q04AXR1212bXr5fh03u8aAwbLxAQNGQ/Q1LNa0VfOI06ZAlhPHtQvE4OIdpj4kLThXilalPnmDSOD65DcHt+g==";
      };
    }
    {
      name = "resolve___resolve_1.22.1.tgz";
      path = fetchurl {
        name = "resolve___resolve_1.22.1.tgz";
        url  = "https://registry.yarnpkg.com/resolve/-/resolve-1.22.1.tgz";
        sha512 = "nBpuuYuY5jFsli/JIs1oldw6fOQCBioohqWZg/2hiaOybXOft4lonv85uDOKXdf8rhyK159cxU5cDcK/NKk8zw==";
      };
    }
    {
      name = "rollup___rollup_3.9.0.tgz";
      path = fetchurl {
        name = "rollup___rollup_3.9.0.tgz";
        url  = "https://registry.yarnpkg.com/rollup/-/rollup-3.9.0.tgz";
        sha512 = "nGGylpmblyjTpF4lEUPgmOw6OVxRvnI6Iuuh6Lz4O/X66cVOX1XJSsqP1YamxQ+mPuFE7qJxLFDSCk8rNv5dDw==";
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
      name = "source_map_js___source_map_js_1.0.2.tgz";
      path = fetchurl {
        name = "source_map_js___source_map_js_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/source-map-js/-/source-map-js-1.0.2.tgz";
        sha512 = "R0XvVJ9WusLiqTCEiGCmICCMplcCkIwwR11mOSD9CR5u+IXYdiseeEuXCVAjS54zqwkLcPNnmU4OeJ6tUrWhDw==";
      };
    }
    {
      name = "source_map___source_map_0.6.1.tgz";
      path = fetchurl {
        name = "source_map___source_map_0.6.1.tgz";
        url  = "https://registry.yarnpkg.com/source-map/-/source-map-0.6.1.tgz";
        sha512 = "UjgapumWlbMhkBgzT7Ykc5YXUT46F0iKu8SGXq0bcwP5dz/h0Plj6enJqjz1Zbq2l5WaqYnrVbwWOWMyF3F47g==";
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
      name = "sourcemap_codec___sourcemap_codec_1.4.8.tgz";
      path = fetchurl {
        name = "sourcemap_codec___sourcemap_codec_1.4.8.tgz";
        url  = "https://registry.yarnpkg.com/sourcemap-codec/-/sourcemap-codec-1.4.8.tgz";
        sha512 = "9NykojV5Uih4lgo5So5dtw+f0JgJX30KCNI8gwhz2J9A15wD0Ml6tjHKwf6fTSa6fAdVBdZeNOs9eJ71qCk8vA==";
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
      name = "supports_preserve_symlinks_flag___supports_preserve_symlinks_flag_1.0.0.tgz";
      path = fetchurl {
        name = "supports_preserve_symlinks_flag___supports_preserve_symlinks_flag_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/supports-preserve-symlinks-flag/-/supports-preserve-symlinks-flag-1.0.0.tgz";
        sha512 = "ot0WnXS9fgdkgIcePe6RHNk1WA8+muPa6cSjeR3V8K27q9BB1rTE3R1p7Hv0z1ZyAc8s6Vvv8DIyWf681MAt0w==";
      };
    }
    {
      name = "typescript___typescript_4.9.4.tgz";
      path = fetchurl {
        name = "typescript___typescript_4.9.4.tgz";
        url  = "https://registry.yarnpkg.com/typescript/-/typescript-4.9.4.tgz";
        sha512 = "Uz+dTXYzxXXbsFpM86Wh3dKCxrQqUcVMxwU54orwlJjOpO3ao8L7j5lH+dWfTwgCwIuM9GQ2kvVotzYJMXTBZg==";
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
      name = "vite_plugin_vuetify___vite_plugin_vuetify_1.0.1.tgz";
      path = fetchurl {
        name = "vite_plugin_vuetify___vite_plugin_vuetify_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/vite-plugin-vuetify/-/vite-plugin-vuetify-1.0.1.tgz";
        sha512 = "/xHsIDuHxq7f6fDqCBYxNascLhDi+X8dV3RzTwmo4mGPrSnGq9pHv8wJsXBIQIT3nY8s16V0lmd6sXMjm0F8wg==";
      };
    }
    {
      name = "vite___vite_4.0.3.tgz";
      path = fetchurl {
        name = "vite___vite_4.0.3.tgz";
        url  = "https://registry.yarnpkg.com/vite/-/vite-4.0.3.tgz";
        sha512 = "HvuNv1RdE7deIfQb8mPk51UKjqptO/4RXZ5yXSAvurd5xOckwS/gg8h9Tky3uSbnjYTgUm0hVCet1cyhKd73ZA==";
      };
    }
    {
      name = "vue_router___vue_router_4.1.6.tgz";
      path = fetchurl {
        name = "vue_router___vue_router_4.1.6.tgz";
        url  = "https://registry.yarnpkg.com/vue-router/-/vue-router-4.1.6.tgz";
        sha512 = "DYWYwsG6xNPmLq/FmZn8Ip+qrhFEzA14EI12MsMgVxvHFDYvlr4NXpVF5hrRH1wVcDP8fGi5F4rxuJSl8/r+EQ==";
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
      name = "vue_tsc___vue_tsc_1.0.19.tgz";
      path = fetchurl {
        name = "vue_tsc___vue_tsc_1.0.19.tgz";
        url  = "https://registry.yarnpkg.com/vue-tsc/-/vue-tsc-1.0.19.tgz";
        sha512 = "UuI4G9PwV07Q2U+xYDLP5y3aUXTfuIF0Exy0qXT8+BbLlahubQ2r2PGSodSBnHxAhm/XsrD0KleC2rSzLKXDfQ==";
      };
    }
    {
      name = "vue___vue_3.2.45.tgz";
      path = fetchurl {
        name = "vue___vue_3.2.45.tgz";
        url  = "https://registry.yarnpkg.com/vue/-/vue-3.2.45.tgz";
        sha512 = "9Nx/Mg2b2xWlXykmCwiTUCWHbWIj53bnkizBxKai1g61f2Xit700A1ljowpTIM11e3uipOeiPcSqnmBg6gyiaA==";
      };
    }
    {
      name = "vuetify___vuetify_3.0.6.tgz";
      path = fetchurl {
        name = "vuetify___vuetify_3.0.6.tgz";
        url  = "https://registry.yarnpkg.com/vuetify/-/vuetify-3.0.6.tgz";
        sha512 = "Illtc9t8PExlKqUEIivNNMpDif4/tvn+04ZEAwrxpQAG75x6V7oUFOF1kVKAFZ2ryuLnBpscXBR85GwFBmLeMQ==";
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
  ];
}
