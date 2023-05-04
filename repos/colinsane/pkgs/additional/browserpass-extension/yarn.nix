{ fetchurl, fetchgit, linkFarm, runCommand, gnutar }: rec {
  offline_cache = linkFarm "offline" packages;
  packages = [
    {
      name = "_browserpass_url___url_1.1.6.tgz";
      path = fetchurl {
        name = "_browserpass_url___url_1.1.6.tgz";
        url  = "https://registry.yarnpkg.com/@browserpass/url/-/url-1.1.6.tgz";
        sha512 = "mWgr6kco+PFn0+e1cYEmNj0r352eFau5aJRhTR8uHT2D5PYa2KH7dGqkg+uhwkR042etOrPczvaO+5Mp80b0GQ==";
      };
    }
    {
      name = "JSONStream___JSONStream_1.3.5.tgz";
      path = fetchurl {
        name = "JSONStream___JSONStream_1.3.5.tgz";
        url  = "https://registry.yarnpkg.com/JSONStream/-/JSONStream-1.3.5.tgz";
        sha512 = "E+iruNOY8VV9s4JEbe1aNEm6MiszPRr/UfcHMz0TQh1BXSxHK+ASV1R6W4HpjBhSeS+54PIsAMCBmwD06LLsqQ==";
      };
    }
    {
      name = "acorn_node___acorn_node_1.8.2.tgz";
      path = fetchurl {
        name = "acorn_node___acorn_node_1.8.2.tgz";
        url  = "https://registry.yarnpkg.com/acorn-node/-/acorn-node-1.8.2.tgz";
        sha512 = "8mt+fslDufLYntIoPAaIMUe/lrbrehIiwmR3t2k9LljIzoigEPF27eLk2hy8zSGzmR/ogr7zbRKINMo1u0yh5A==";
      };
    }
    {
      name = "acorn_walk___acorn_walk_7.2.0.tgz";
      path = fetchurl {
        name = "acorn_walk___acorn_walk_7.2.0.tgz";
        url  = "https://registry.yarnpkg.com/acorn-walk/-/acorn-walk-7.2.0.tgz";
        sha512 = "OPdCF6GsMIP+Az+aWfAAOEt2/+iVDKE7oy6lJ098aoe59oAmK76qV6Gw60SbZ8jHuG2wH058GF4pLFbYamYrVA==";
      };
    }
    {
      name = "acorn___acorn_7.4.1.tgz";
      path = fetchurl {
        name = "acorn___acorn_7.4.1.tgz";
        url  = "https://registry.yarnpkg.com/acorn/-/acorn-7.4.1.tgz";
        sha512 = "nQyp0o1/mNdbTO1PO6kHkwSrmgZ0MT/jCCpNiwbUjGoRN4dlBhqJtoQuCnEOKzgTVwg0ZWiCoQy6SxMebQVh8A==";
      };
    }
    {
      name = "asn1.js___asn1.js_5.4.1.tgz";
      path = fetchurl {
        name = "asn1.js___asn1.js_5.4.1.tgz";
        url  = "https://registry.yarnpkg.com/asn1.js/-/asn1.js-5.4.1.tgz";
        sha512 = "+I//4cYPccV8LdmBLiX8CYvf9Sp3vQsrqu2QNXRcrbiWvcx/UdlFiqUJJzxRQxgsZmvhXhn4cSKeSmoFjVdupA==";
      };
    }
    {
      name = "assert___assert_1.5.0.tgz";
      path = fetchurl {
        name = "assert___assert_1.5.0.tgz";
        url  = "https://registry.yarnpkg.com/assert/-/assert-1.5.0.tgz";
        sha512 = "EDsgawzwoun2CZkCgtxJbv392v4nbk9XDD06zI+kQYoBM/3RBWLlEyJARDOmhAAosBjWACEkKL6S+lIZtcAubA==";
      };
    }
    {
      name = "balanced_match___balanced_match_1.0.0.tgz";
      path = fetchurl {
        name = "balanced_match___balanced_match_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/balanced-match/-/balanced-match-1.0.0.tgz";
        sha1 = "ibTRmasr7kneFk6gK4nORi1xt2c=";
      };
    }
    {
      name = "base64_js___base64_js_1.5.1.tgz";
      path = fetchurl {
        name = "base64_js___base64_js_1.5.1.tgz";
        url  = "https://registry.yarnpkg.com/base64-js/-/base64-js-1.5.1.tgz";
        sha512 = "AKpaYlHn8t4SVbOHCy+b5+KKgvR4vrsD8vbvrbiQJps7fKDTkjkDry6ji0rUJjC0kzbNePLwzxq8iypo41qeWA==";
      };
    }
    {
      name = "bn.js___bn.js_4.11.9.tgz";
      path = fetchurl {
        name = "bn.js___bn.js_4.11.9.tgz";
        url  = "https://registry.yarnpkg.com/bn.js/-/bn.js-4.11.9.tgz";
        sha512 = "E6QoYqCKZfgatHTdHzs1RRKP7ip4vvm+EyRUeE2RF0NblwVvb0p6jSVeNTOFxPn26QXN2o6SMfNxKp6kU8zQaw==";
      };
    }
    {
      name = "bn.js___bn.js_5.1.3.tgz";
      path = fetchurl {
        name = "bn.js___bn.js_5.1.3.tgz";
        url  = "https://registry.yarnpkg.com/bn.js/-/bn.js-5.1.3.tgz";
        sha512 = "GkTiFpjFtUzU9CbMeJ5iazkCzGL3jrhzerzZIuqLABjbwRaFt33I9tUdSNryIptM+RxDet6OKm2WnLXzW51KsQ==";
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
      name = "brorand___brorand_1.1.0.tgz";
      path = fetchurl {
        name = "brorand___brorand_1.1.0.tgz";
        url  = "https://registry.yarnpkg.com/brorand/-/brorand-1.1.0.tgz";
        sha1 = "EsJe/kCkXjwyPrhnWgoM5XsiNx8=";
      };
    }
    {
      name = "browser_pack___browser_pack_6.1.0.tgz";
      path = fetchurl {
        name = "browser_pack___browser_pack_6.1.0.tgz";
        url  = "https://registry.yarnpkg.com/browser-pack/-/browser-pack-6.1.0.tgz";
        sha512 = "erYug8XoqzU3IfcU8fUgyHqyOXqIE4tUTTQ+7mqUjQlvnXkOO6OlT9c/ZoJVHYoAaqGxr09CN53G7XIsO4KtWA==";
      };
    }
    {
      name = "browser_resolve___browser_resolve_2.0.0.tgz";
      path = fetchurl {
        name = "browser_resolve___browser_resolve_2.0.0.tgz";
        url  = "https://registry.yarnpkg.com/browser-resolve/-/browser-resolve-2.0.0.tgz";
        sha512 = "7sWsQlYL2rGLy2IWm8WL8DCTJvYLc/qlOnsakDac87SOoCd16WLsaAMdCiAqsTNHIe+SXfaqyxyo6THoWqs8WQ==";
      };
    }
    {
      name = "browserify_aes___browserify_aes_1.2.0.tgz";
      path = fetchurl {
        name = "browserify_aes___browserify_aes_1.2.0.tgz";
        url  = "https://registry.yarnpkg.com/browserify-aes/-/browserify-aes-1.2.0.tgz";
        sha512 = "+7CHXqGuspUn/Sl5aO7Ea0xWGAtETPXNSAjHo48JfLdPWcMng33Xe4znFvQweqc/uzk5zSOI3H52CYnjCfb5hA==";
      };
    }
    {
      name = "browserify_cipher___browserify_cipher_1.0.1.tgz";
      path = fetchurl {
        name = "browserify_cipher___browserify_cipher_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/browserify-cipher/-/browserify-cipher-1.0.1.tgz";
        sha512 = "sPhkz0ARKbf4rRQt2hTpAHqn47X3llLkUGn+xEJzLjwY8LRs2p0v7ljvI5EyoRO/mexrNunNECisZs+gw2zz1w==";
      };
    }
    {
      name = "browserify_des___browserify_des_1.0.2.tgz";
      path = fetchurl {
        name = "browserify_des___browserify_des_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/browserify-des/-/browserify-des-1.0.2.tgz";
        sha512 = "BioO1xf3hFwz4kc6iBhI3ieDFompMhrMlnDFC4/0/vd5MokpuAc3R+LYbwTA9A5Yc9pq9UYPqffKpW2ObuwX5A==";
      };
    }
    {
      name = "browserify_rsa___browserify_rsa_4.1.0.tgz";
      path = fetchurl {
        name = "browserify_rsa___browserify_rsa_4.1.0.tgz";
        url  = "https://registry.yarnpkg.com/browserify-rsa/-/browserify-rsa-4.1.0.tgz";
        sha512 = "AdEER0Hkspgno2aR97SAf6vi0y0k8NuOpGnVH3O99rcA5Q6sh8QxcngtHuJ6uXwnfAXNM4Gn1Gb7/MV1+Ymbog==";
      };
    }
    {
      name = "browserify_sign___browserify_sign_4.2.1.tgz";
      path = fetchurl {
        name = "browserify_sign___browserify_sign_4.2.1.tgz";
        url  = "https://registry.yarnpkg.com/browserify-sign/-/browserify-sign-4.2.1.tgz";
        sha512 = "/vrA5fguVAKKAVTNJjgSm1tRQDHUU6DbwO9IROu/0WAzC8PKhucDSh18J0RMvVeHAn5puMd+QHC2erPRNf8lmg==";
      };
    }
    {
      name = "browserify_zlib___browserify_zlib_0.2.0.tgz";
      path = fetchurl {
        name = "browserify_zlib___browserify_zlib_0.2.0.tgz";
        url  = "https://registry.yarnpkg.com/browserify-zlib/-/browserify-zlib-0.2.0.tgz";
        sha512 = "Z942RysHXmJrhqk88FmKBVq/v5tqmSkDz7p54G/MGyjMnCFFnC79XWNbg+Vta8W6Wb2qtSZTSxIGkJrRpCFEiA==";
      };
    }
    {
      name = "browserify___browserify_16.5.2.tgz";
      path = fetchurl {
        name = "browserify___browserify_16.5.2.tgz";
        url  = "https://registry.yarnpkg.com/browserify/-/browserify-16.5.2.tgz";
        sha512 = "TkOR1cQGdmXU9zW4YukWzWVSJwrxmNdADFbqbE3HFgQWe5wqZmOawqZ7J/8MPCwk/W8yY7Y0h+7mOtcZxLP23g==";
      };
    }
    {
      name = "buffer_from___buffer_from_1.1.1.tgz";
      path = fetchurl {
        name = "buffer_from___buffer_from_1.1.1.tgz";
        url  = "https://registry.yarnpkg.com/buffer-from/-/buffer-from-1.1.1.tgz";
        sha512 = "MQcXEUbCKtEo7bhqEs6560Hyd4XaovZlO/k9V3hjVUF/zwW7KBVdSK4gIt/bzwS9MbR5qob+F5jusZsb0YQK2A==";
      };
    }
    {
      name = "buffer_xor___buffer_xor_1.0.3.tgz";
      path = fetchurl {
        name = "buffer_xor___buffer_xor_1.0.3.tgz";
        url  = "https://registry.yarnpkg.com/buffer-xor/-/buffer-xor-1.0.3.tgz";
        sha1 = "JuYe0UIvtw3ULm42cp7VHYVf6Nk=";
      };
    }
    {
      name = "buffer___buffer_5.2.1.tgz";
      path = fetchurl {
        name = "buffer___buffer_5.2.1.tgz";
        url  = "https://registry.yarnpkg.com/buffer/-/buffer-5.2.1.tgz";
        sha512 = "c+Ko0loDaFfuPWiL02ls9Xd3GO3cPVmUobQ6t3rXNUk304u6hGq+8N/kFi+QEIKhzK3uwolVhLzszmfLmMLnqg==";
      };
    }
    {
      name = "builtin_status_codes___builtin_status_codes_3.0.0.tgz";
      path = fetchurl {
        name = "builtin_status_codes___builtin_status_codes_3.0.0.tgz";
        url  = "https://registry.yarnpkg.com/builtin-status-codes/-/builtin-status-codes-3.0.0.tgz";
        sha1 = "hZgoeOIbmOHGZCXgPQF0eI9Wnug=";
      };
    }
    {
      name = "cached_path_relative___cached_path_relative_1.0.2.tgz";
      path = fetchurl {
        name = "cached_path_relative___cached_path_relative_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/cached-path-relative/-/cached-path-relative-1.0.2.tgz";
        sha512 = "5r2GqsoEb4qMTTN9J+WzXfjov+hjxT+j3u5K+kIVNIwAd99DLCJE9pBIMP1qVeybV6JiijL385Oz0DcYxfbOIg==";
      };
    }
    {
      name = "charenc___charenc_0.0.2.tgz";
      path = fetchurl {
        name = "charenc___charenc_0.0.2.tgz";
        url  = "https://registry.yarnpkg.com/charenc/-/charenc-0.0.2.tgz";
        sha1 = "wKHS86cJLgN3S/qD8UwPxXkKhmc=";
      };
    }
    {
      name = "chrome_extension_async___chrome_extension_async_3.4.1.tgz";
      path = fetchurl {
        name = "chrome_extension_async___chrome_extension_async_3.4.1.tgz";
        url  = "https://registry.yarnpkg.com/chrome-extension-async/-/chrome-extension-async-3.4.1.tgz";
        sha512 = "YBkFGFL+8MpkHvZ4nB/NU0uPkJU4LWjSlqxgXOwHcBe5sGs/YT0etEkmQXay3Op6p2c+34zf1k4Osi0ma4HtiQ==";
      };
    }
    {
      name = "cipher_base___cipher_base_1.0.4.tgz";
      path = fetchurl {
        name = "cipher_base___cipher_base_1.0.4.tgz";
        url  = "https://registry.yarnpkg.com/cipher-base/-/cipher-base-1.0.4.tgz";
        sha512 = "Kkht5ye6ZGmwv40uUDZztayT2ThLQGfnj/T71N/XzeZeo3nf8foyW7zGTsPYkEya3m5f3cAypH+qe7YOrM1U2Q==";
      };
    }
    {
      name = "combine_source_map___combine_source_map_0.8.0.tgz";
      path = fetchurl {
        name = "combine_source_map___combine_source_map_0.8.0.tgz";
        url  = "https://registry.yarnpkg.com/combine-source-map/-/combine-source-map-0.8.0.tgz";
        sha1 = "pY0N8ELBhvz4IqjoAV9UUNLXmos=";
      };
    }
    {
      name = "concat_map___concat_map_0.0.1.tgz";
      path = fetchurl {
        name = "concat_map___concat_map_0.0.1.tgz";
        url  = "https://registry.yarnpkg.com/concat-map/-/concat-map-0.0.1.tgz";
        sha1 = "2Klr13/Wjfd5OnMDajug1UBdR3s=";
      };
    }
    {
      name = "concat_stream___concat_stream_1.6.2.tgz";
      path = fetchurl {
        name = "concat_stream___concat_stream_1.6.2.tgz";
        url  = "https://registry.yarnpkg.com/concat-stream/-/concat-stream-1.6.2.tgz";
        sha512 = "27HBghJxjiZtIk3Ycvn/4kbJk/1uZuJFfuPEns6LaEvpvG1f0hTea8lilrouyo9mVc2GWdcEZ8OLoGmSADlrCw==";
      };
    }
    {
      name = "console_browserify___console_browserify_1.2.0.tgz";
      path = fetchurl {
        name = "console_browserify___console_browserify_1.2.0.tgz";
        url  = "https://registry.yarnpkg.com/console-browserify/-/console-browserify-1.2.0.tgz";
        sha512 = "ZMkYO/LkF17QvCPqM0gxw8yUzigAOZOSWSHg91FH6orS7vcEj5dVZTidN2fQ14yBSdg97RqhSNwLUXInd52OTA==";
      };
    }
    {
      name = "constants_browserify___constants_browserify_1.0.0.tgz";
      path = fetchurl {
        name = "constants_browserify___constants_browserify_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/constants-browserify/-/constants-browserify-1.0.0.tgz";
        sha1 = "wguW2MYXdIqvHBYCF2DNJ/y4y3U=";
      };
    }
    {
      name = "convert_source_map___convert_source_map_1.1.3.tgz";
      path = fetchurl {
        name = "convert_source_map___convert_source_map_1.1.3.tgz";
        url  = "https://registry.yarnpkg.com/convert-source-map/-/convert-source-map-1.1.3.tgz";
        sha1 = "SCnId+n+SbMWHzvzZziI4gRpmGA=";
      };
    }
    {
      name = "copy_anything___copy_anything_2.0.1.tgz";
      path = fetchurl {
        name = "copy_anything___copy_anything_2.0.1.tgz";
        url  = "https://registry.yarnpkg.com/copy-anything/-/copy-anything-2.0.1.tgz";
        sha512 = "lA57e7viQHOdPQcrytv5jFeudZZOXuyk47lZym279FiDQ8jeZomXiGuVf6ffMKkJ+3TIai3J1J3yi6M+/4U35g==";
      };
    }
    {
      name = "core_util_is___core_util_is_1.0.2.tgz";
      path = fetchurl {
        name = "core_util_is___core_util_is_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/core-util-is/-/core-util-is-1.0.2.tgz";
        sha1 = "tf1UIgqivFq1eqtxQMlAdUUDwac=";
      };
    }
    {
      name = "create_ecdh___create_ecdh_4.0.4.tgz";
      path = fetchurl {
        name = "create_ecdh___create_ecdh_4.0.4.tgz";
        url  = "https://registry.yarnpkg.com/create-ecdh/-/create-ecdh-4.0.4.tgz";
        sha512 = "mf+TCx8wWc9VpuxfP2ht0iSISLZnt0JgWlrOKZiNqyUZWnjIaCIVNQArMHnCZKfEYRg6IM7A+NeJoN8gf/Ws0A==";
      };
    }
    {
      name = "create_hash___create_hash_1.2.0.tgz";
      path = fetchurl {
        name = "create_hash___create_hash_1.2.0.tgz";
        url  = "https://registry.yarnpkg.com/create-hash/-/create-hash-1.2.0.tgz";
        sha512 = "z00bCGNHDG8mHAkP7CtT1qVu+bFQUPjYq/4Iv3C3kWjTFV10zIjfSoeqXo9Asws8gwSHDGj/hl2u4OGIjapeCg==";
      };
    }
    {
      name = "create_hmac___create_hmac_1.1.7.tgz";
      path = fetchurl {
        name = "create_hmac___create_hmac_1.1.7.tgz";
        url  = "https://registry.yarnpkg.com/create-hmac/-/create-hmac-1.1.7.tgz";
        sha512 = "MJG9liiZ+ogc4TzUwuvbER1JRdgvUFSB5+VR/g5h82fGaIRWMWddtKBHi7/sVhfjQZ6SehlyhvQYrcYkaUIpLg==";
      };
    }
    {
      name = "crypt___crypt_0.0.2.tgz";
      path = fetchurl {
        name = "crypt___crypt_0.0.2.tgz";
        url  = "https://registry.yarnpkg.com/crypt/-/crypt-0.0.2.tgz";
        sha1 = "iNf/fsDfuG9xPch7u0LQRNPmxBs=";
      };
    }
    {
      name = "crypto_browserify___crypto_browserify_3.12.0.tgz";
      path = fetchurl {
        name = "crypto_browserify___crypto_browserify_3.12.0.tgz";
        url  = "https://registry.yarnpkg.com/crypto-browserify/-/crypto-browserify-3.12.0.tgz";
        sha512 = "fz4spIh+znjO2VjL+IdhEpRJ3YN6sMzITSBijk6FK2UvTqruSQW+/cCZTSNsMiZNvUeq0CqurF+dAbyiGOY6Wg==";
      };
    }
    {
      name = "dash_ast___dash_ast_1.0.0.tgz";
      path = fetchurl {
        name = "dash_ast___dash_ast_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/dash-ast/-/dash-ast-1.0.0.tgz";
        sha512 = "Vy4dx7gquTeMcQR/hDkYLGUnwVil6vk4FOOct+djUnHOUWt+zJPJAaRIXaAFkPXtJjvlY7o3rfRu0/3hpnwoUA==";
      };
    }
    {
      name = "defined___defined_1.0.0.tgz";
      path = fetchurl {
        name = "defined___defined_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/defined/-/defined-1.0.0.tgz";
        sha1 = "yY2bzvdWdBiOEQlpFRGZ45sfppM=";
      };
    }
    {
      name = "deps_sort___deps_sort_2.0.1.tgz";
      path = fetchurl {
        name = "deps_sort___deps_sort_2.0.1.tgz";
        url  = "https://registry.yarnpkg.com/deps-sort/-/deps-sort-2.0.1.tgz";
        sha512 = "1orqXQr5po+3KI6kQb9A4jnXT1PBwggGl2d7Sq2xsnOeI9GPcE/tGcF9UiSZtZBM7MukY4cAh7MemS6tZYipfw==";
      };
    }
    {
      name = "des.js___des.js_1.0.1.tgz";
      path = fetchurl {
        name = "des.js___des.js_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/des.js/-/des.js-1.0.1.tgz";
        sha512 = "Q0I4pfFrv2VPd34/vfLrFOoRmlYj3OV50i7fskps1jZWK1kApMWWT9G6RRUeYedLcBDIhnSDaUvJMb3AhUlaEA==";
      };
    }
    {
      name = "detective___detective_5.2.0.tgz";
      path = fetchurl {
        name = "detective___detective_5.2.0.tgz";
        url  = "https://registry.yarnpkg.com/detective/-/detective-5.2.0.tgz";
        sha512 = "6SsIx+nUUbuK0EthKjv0zrdnajCCXVYGmbYYiYjFVpzcjwEs/JMDZ8tPRG29J/HhN56t3GJp2cGSWDRjjot8Pg==";
      };
    }
    {
      name = "diffie_hellman___diffie_hellman_5.0.3.tgz";
      path = fetchurl {
        name = "diffie_hellman___diffie_hellman_5.0.3.tgz";
        url  = "https://registry.yarnpkg.com/diffie-hellman/-/diffie-hellman-5.0.3.tgz";
        sha512 = "kqag/Nl+f3GwyK25fhUMYj81BUOrZ9IuJsjIcDE5icNM9FJHAVm3VcUDxdLPoQtTuUylWm6ZIknYJwwaPxsUzg==";
      };
    }
    {
      name = "domain_browser___domain_browser_1.2.0.tgz";
      path = fetchurl {
        name = "domain_browser___domain_browser_1.2.0.tgz";
        url  = "https://registry.yarnpkg.com/domain-browser/-/domain-browser-1.2.0.tgz";
        sha512 = "jnjyiM6eRyZl2H+W8Q/zLMA481hzi0eszAaBUzIVnmYVDBbnLxVNnfu1HgEBvCbL+71FrxMl3E6lpKH7Ge3OXA==";
      };
    }
    {
      name = "duplexer2___duplexer2_0.1.4.tgz";
      path = fetchurl {
        name = "duplexer2___duplexer2_0.1.4.tgz";
        url  = "https://registry.yarnpkg.com/duplexer2/-/duplexer2-0.1.4.tgz";
        sha1 = "ixLauHjA1p4+eJEFFmKjL8a93ME=";
      };
    }
    {
      name = "elliptic___elliptic_6.5.3.tgz";
      path = fetchurl {
        name = "elliptic___elliptic_6.5.3.tgz";
        url  = "https://registry.yarnpkg.com/elliptic/-/elliptic-6.5.3.tgz";
        sha512 = "IMqzv5wNQf+E6aHeIqATs0tOLeOTwj1QKbRcS3jBbYkl5oLAserA8yJTT7/VyHUYG91PRmPyeQDObKLPpeS4dw==";
      };
    }
    {
      name = "errno___errno_0.1.8.tgz";
      path = fetchurl {
        name = "errno___errno_0.1.8.tgz";
        url  = "https://registry.yarnpkg.com/errno/-/errno-0.1.8.tgz";
        sha512 = "dJ6oBr5SQ1VSd9qkk7ByRgb/1SH4JZjCHSW/mr63/QcXO9zLVxvJ6Oy13nio03rxpSnVDDjFor75SjVeZWPW/A==";
      };
    }
    {
      name = "events___events_2.1.0.tgz";
      path = fetchurl {
        name = "events___events_2.1.0.tgz";
        url  = "https://registry.yarnpkg.com/events/-/events-2.1.0.tgz";
        sha512 = "3Zmiobend8P9DjmKAty0Era4jV8oJ0yGYe2nJJAxgymF9+N8F2m0hhZiMoWtcfepExzNKZumFU3ksdQbInGWCg==";
      };
    }
    {
      name = "evp_bytestokey___evp_bytestokey_1.0.3.tgz";
      path = fetchurl {
        name = "evp_bytestokey___evp_bytestokey_1.0.3.tgz";
        url  = "https://registry.yarnpkg.com/evp_bytestokey/-/evp_bytestokey-1.0.3.tgz";
        sha512 = "/f2Go4TognH/KvCISP7OUsHn85hT9nUkxxA9BEWxFn+Oj9o8ZNLm/40hdlgSLyuOimsrTKLUMEorQexp/aPQeA==";
      };
    }
    {
      name = "fast_safe_stringify___fast_safe_stringify_2.0.7.tgz";
      path = fetchurl {
        name = "fast_safe_stringify___fast_safe_stringify_2.0.7.tgz";
        url  = "https://registry.yarnpkg.com/fast-safe-stringify/-/fast-safe-stringify-2.0.7.tgz";
        sha512 = "Utm6CdzT+6xsDk2m8S6uL8VHxNwI6Jub+e9NYTcAms28T84pTa25GJQV9j0CY0N1rM8hK4x6grpF2BQf+2qwVA==";
      };
    }
    {
      name = "fs.realpath___fs.realpath_1.0.0.tgz";
      path = fetchurl {
        name = "fs.realpath___fs.realpath_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/fs.realpath/-/fs.realpath-1.0.0.tgz";
        sha1 = "FQStJSMVjKpA20onh8sBQRmU6k8=";
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
      name = "fuzzysort___fuzzysort_1.1.4.tgz";
      path = fetchurl {
        name = "fuzzysort___fuzzysort_1.1.4.tgz";
        url  = "https://registry.yarnpkg.com/fuzzysort/-/fuzzysort-1.1.4.tgz";
        sha512 = "JzK/lHjVZ6joAg3OnCjylwYXYVjRiwTY6Yb25LvfpJHK8bjisfnZJ5bY8aVWwTwCXgxPNgLAtmHL+Hs5q1ddLQ==";
      };
    }
    {
      name = "get_assigned_identifiers___get_assigned_identifiers_1.2.0.tgz";
      path = fetchurl {
        name = "get_assigned_identifiers___get_assigned_identifiers_1.2.0.tgz";
        url  = "https://registry.yarnpkg.com/get-assigned-identifiers/-/get-assigned-identifiers-1.2.0.tgz";
        sha512 = "mBBwmeGTrxEMO4pMaaf/uUEFHnYtwr8FTe8Y/mer4rcV/bye0qGm6pw1bGZFGStxC5O76c5ZAVBGnqHmOaJpdQ==";
      };
    }
    {
      name = "glob___glob_7.1.6.tgz";
      path = fetchurl {
        name = "glob___glob_7.1.6.tgz";
        url  = "https://registry.yarnpkg.com/glob/-/glob-7.1.6.tgz";
        sha512 = "LwaxwyZ72Lk7vZINtNNrywX0ZuLyStrdDtabefZKAY5ZGJhVtgdznluResxNmPitE0SAO+O26sWTHeKSI2wMBA==";
      };
    }
    {
      name = "graceful_fs___graceful_fs_4.2.4.tgz";
      path = fetchurl {
        name = "graceful_fs___graceful_fs_4.2.4.tgz";
        url  = "https://registry.yarnpkg.com/graceful-fs/-/graceful-fs-4.2.4.tgz";
        sha512 = "WjKPNJF79dtJAVniUlGGWHYGz2jWxT6VhN/4m1NdkbZ2nOsEF+cI1Edgql5zCRhs/VsQYRvrXctxktVXZUkixw==";
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
      name = "hash_base___hash_base_3.1.0.tgz";
      path = fetchurl {
        name = "hash_base___hash_base_3.1.0.tgz";
        url  = "https://registry.yarnpkg.com/hash-base/-/hash-base-3.1.0.tgz";
        sha512 = "1nmYp/rhMDiE7AYkDw+lLwlAzz0AntGIe51F3RfFfEqyQ3feY2eI/NcwC6umIQVOASPMsWJLJScWKSSvzL9IVA==";
      };
    }
    {
      name = "hash.js___hash.js_1.1.7.tgz";
      path = fetchurl {
        name = "hash.js___hash.js_1.1.7.tgz";
        url  = "https://registry.yarnpkg.com/hash.js/-/hash.js-1.1.7.tgz";
        sha512 = "taOaskGt4z4SOANNseOviYDvjEJinIkRgmp7LbKP2YTTmVxWBl87s/uzK9r+44BclBSp2X7K1hqeNfz9JbBeXA==";
      };
    }
    {
      name = "hmac_drbg___hmac_drbg_1.0.1.tgz";
      path = fetchurl {
        name = "hmac_drbg___hmac_drbg_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/hmac-drbg/-/hmac-drbg-1.0.1.tgz";
        sha1 = "0nRXAQJabHdabFRXk+1QL8DGSaE=";
      };
    }
    {
      name = "htmlescape___htmlescape_1.1.1.tgz";
      path = fetchurl {
        name = "htmlescape___htmlescape_1.1.1.tgz";
        url  = "https://registry.yarnpkg.com/htmlescape/-/htmlescape-1.1.1.tgz";
        sha1 = "OgPtwiFLyjtmQko+eVk0lQnLA1E=";
      };
    }
    {
      name = "https_browserify___https_browserify_1.0.0.tgz";
      path = fetchurl {
        name = "https_browserify___https_browserify_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/https-browserify/-/https-browserify-1.0.0.tgz";
        sha1 = "7AbBDgo0wPL68Zn3/X/Hj//QPHM=";
      };
    }
    {
      name = "idb___idb_4.0.5.tgz";
      path = fetchurl {
        name = "idb___idb_4.0.5.tgz";
        url  = "https://registry.yarnpkg.com/idb/-/idb-4.0.5.tgz";
        sha512 = "P+Fk9HT2h1DhXoE1YNK183SY+CRh2GHNh28de94sGwhe0bUA75JJeVJWt3SenE5p0BXK7maflIq29dl6UZHrFw==";
      };
    }
    {
      name = "ieee754___ieee754_1.2.1.tgz";
      path = fetchurl {
        name = "ieee754___ieee754_1.2.1.tgz";
        url  = "https://registry.yarnpkg.com/ieee754/-/ieee754-1.2.1.tgz";
        sha512 = "dcyqhDvX1C46lXZcVqCpK+FtMRQVdIMN6/Df5js2zouUsqG7I6sFxitIC+7KYK29KdXOLHdu9zL4sFnoVQnqaA==";
      };
    }
    {
      name = "ignore___ignore_5.1.8.tgz";
      path = fetchurl {
        name = "ignore___ignore_5.1.8.tgz";
        url  = "https://registry.yarnpkg.com/ignore/-/ignore-5.1.8.tgz";
        sha512 = "BMpfD7PpiETpBl/A6S498BaIJ6Y/ABT93ETbby2fP00v4EbvPBXWEoaR1UBPKs3iR53pJY7EtZk5KACI57i1Uw==";
      };
    }
    {
      name = "image_size___image_size_0.5.5.tgz";
      path = fetchurl {
        name = "image_size___image_size_0.5.5.tgz";
        url  = "https://registry.yarnpkg.com/image-size/-/image-size-0.5.5.tgz";
        sha1 = "Cd/Uq50g4p6xw+gLiZA3jfnjy5w=";
      };
    }
    {
      name = "inflight___inflight_1.0.6.tgz";
      path = fetchurl {
        name = "inflight___inflight_1.0.6.tgz";
        url  = "https://registry.yarnpkg.com/inflight/-/inflight-1.0.6.tgz";
        sha1 = "Sb1jMdfQLQwJvJEKEHW6gWW1bfk=";
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
      name = "inherits___inherits_2.0.1.tgz";
      path = fetchurl {
        name = "inherits___inherits_2.0.1.tgz";
        url  = "https://registry.yarnpkg.com/inherits/-/inherits-2.0.1.tgz";
        sha1 = "sX0I0ya0Qj5Wjv9xn5GwscvfafE=";
      };
    }
    {
      name = "inherits___inherits_2.0.3.tgz";
      path = fetchurl {
        name = "inherits___inherits_2.0.3.tgz";
        url  = "https://registry.yarnpkg.com/inherits/-/inherits-2.0.3.tgz";
        sha1 = "Yzwsg+PaQqUC9SRmAiSA9CCCYd4=";
      };
    }
    {
      name = "inline_source_map___inline_source_map_0.6.2.tgz";
      path = fetchurl {
        name = "inline_source_map___inline_source_map_0.6.2.tgz";
        url  = "https://registry.yarnpkg.com/inline-source-map/-/inline-source-map-0.6.2.tgz";
        sha1 = "+Tk0ccGKedFyT4Y/o4tYY3Ct4qU=";
      };
    }
    {
      name = "insert_module_globals___insert_module_globals_7.2.1.tgz";
      path = fetchurl {
        name = "insert_module_globals___insert_module_globals_7.2.1.tgz";
        url  = "https://registry.yarnpkg.com/insert-module-globals/-/insert-module-globals-7.2.1.tgz";
        sha512 = "ufS5Qq9RZN+Bu899eA9QCAYThY+gGW7oRkmb0vC93Vlyu/CFGcH0OYPEjVkDXA5FEbTt1+VWzdoOD3Ny9N+8tg==";
      };
    }
    {
      name = "is_buffer___is_buffer_1.1.6.tgz";
      path = fetchurl {
        name = "is_buffer___is_buffer_1.1.6.tgz";
        url  = "https://registry.yarnpkg.com/is-buffer/-/is-buffer-1.1.6.tgz";
        sha512 = "NcdALwpXkTm5Zvvbk7owOUSvVvBKDgKP5/ewfXEznmQFfs4ZRmanOeKBTjRVjka3QFoN6XJ+9F3USqfHqTaU5w==";
      };
    }
    {
      name = "is_core_module___is_core_module_2.2.0.tgz";
      path = fetchurl {
        name = "is_core_module___is_core_module_2.2.0.tgz";
        url  = "https://registry.yarnpkg.com/is-core-module/-/is-core-module-2.2.0.tgz";
        sha512 = "XRAfAdyyY5F5cOXn7hYQDqh2Xmii+DEfIcQGxK/uNwMHhIkPWO0g8msXcbzLe+MpGoR951MlqM/2iIlU4vKDdQ==";
      };
    }
    {
      name = "is_what___is_what_3.12.0.tgz";
      path = fetchurl {
        name = "is_what___is_what_3.12.0.tgz";
        url  = "https://registry.yarnpkg.com/is-what/-/is-what-3.12.0.tgz";
        sha512 = "2ilQz5/f/o9V7WRWJQmpFYNmQFZ9iM+OXRonZKcYgTkCzjb949Vi4h282PD1UfmgHk666rcWonbRJ++KI41VGw==";
      };
    }
    {
      name = "isarray___isarray_1.0.0.tgz";
      path = fetchurl {
        name = "isarray___isarray_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/isarray/-/isarray-1.0.0.tgz";
        sha1 = "u5NdSFgsuhaMBoNJV6VKPgcSTxE=";
      };
    }
    {
      name = "json_stable_stringify___json_stable_stringify_0.0.1.tgz";
      path = fetchurl {
        name = "json_stable_stringify___json_stable_stringify_0.0.1.tgz";
        url  = "https://registry.yarnpkg.com/json-stable-stringify/-/json-stable-stringify-0.0.1.tgz";
        sha1 = "YRwj6BTbN1Un34URk9tZ3Sryf0U=";
      };
    }
    {
      name = "jsonify___jsonify_0.0.0.tgz";
      path = fetchurl {
        name = "jsonify___jsonify_0.0.0.tgz";
        url  = "https://registry.yarnpkg.com/jsonify/-/jsonify-0.0.0.tgz";
        sha1 = "LHS27kHZPKUbe1qu6PUDYx0lKnM=";
      };
    }
    {
      name = "jsonparse___jsonparse_1.3.1.tgz";
      path = fetchurl {
        name = "jsonparse___jsonparse_1.3.1.tgz";
        url  = "https://registry.yarnpkg.com/jsonparse/-/jsonparse-1.3.1.tgz";
        sha1 = "P02uSpH6wxX3EGL4UhzCOfE2YoA=";
      };
    }
    {
      name = "labeled_stream_splicer___labeled_stream_splicer_2.0.2.tgz";
      path = fetchurl {
        name = "labeled_stream_splicer___labeled_stream_splicer_2.0.2.tgz";
        url  = "https://registry.yarnpkg.com/labeled-stream-splicer/-/labeled-stream-splicer-2.0.2.tgz";
        sha512 = "Ca4LSXFFZUjPScRaqOcFxneA0VpKZr4MMYCljyQr4LIewTLb3Y0IUTIsnBBsVubIeEfxeSZpSjSsRM8APEQaAw==";
      };
    }
    {
      name = "less___less_3.13.1.tgz";
      path = fetchurl {
        name = "less___less_3.13.1.tgz";
        url  = "https://registry.yarnpkg.com/less/-/less-3.13.1.tgz";
        sha512 = "SwA1aQXGUvp+P5XdZslUOhhLnClSLIjWvJhmd+Vgib5BFIr9lMNlQwmwUNOjXThF/A0x+MCYYPeWEfeWiLRnTw==";
      };
    }
    {
      name = "lodash.memoize___lodash.memoize_3.0.4.tgz";
      path = fetchurl {
        name = "lodash.memoize___lodash.memoize_3.0.4.tgz";
        url  = "https://registry.yarnpkg.com/lodash.memoize/-/lodash.memoize-3.0.4.tgz";
        sha1 = "LcvSwofLwKVcxCMovQxzYVDVPj8=";
      };
    }
    {
      name = "make_dir___make_dir_2.1.0.tgz";
      path = fetchurl {
        name = "make_dir___make_dir_2.1.0.tgz";
        url  = "https://registry.yarnpkg.com/make-dir/-/make-dir-2.1.0.tgz";
        sha512 = "LS9X+dc8KLxXCb8dni79fLIIUA5VyZoyjSMCwTluaXA0o27cCK0bhXkpgw+sTXVpPy/lSO57ilRixqk0vDmtRA==";
      };
    }
    {
      name = "md5.js___md5.js_1.3.5.tgz";
      path = fetchurl {
        name = "md5.js___md5.js_1.3.5.tgz";
        url  = "https://registry.yarnpkg.com/md5.js/-/md5.js-1.3.5.tgz";
        sha512 = "xitP+WxNPcTTOgnTJcrhM0xvdPepipPSf3I8EIpGKeFLjt3PlJLIDG3u8EX53ZIubkb+5U2+3rELYpEhHhzdkg==";
      };
    }
    {
      name = "miller_rabin___miller_rabin_4.0.1.tgz";
      path = fetchurl {
        name = "miller_rabin___miller_rabin_4.0.1.tgz";
        url  = "https://registry.yarnpkg.com/miller-rabin/-/miller-rabin-4.0.1.tgz";
        sha512 = "115fLhvZVqWwHPbClyntxEVfVDfl9DLLTuJvq3g2O/Oxi8AiNouAHvDSzHS0viUJc+V5vm3eq91Xwqn9dp4jRA==";
      };
    }
    {
      name = "mime___mime_1.6.0.tgz";
      path = fetchurl {
        name = "mime___mime_1.6.0.tgz";
        url  = "https://registry.yarnpkg.com/mime/-/mime-1.6.0.tgz";
        sha512 = "x0Vn8spI+wuJ1O6S7gnbaQg8Pxh4NNHb7KSINmEWKiPE4RKOplvijn+NkmYmmRgP68mc70j2EbeTFRsrswaQeg==";
      };
    }
    {
      name = "minimalistic_assert___minimalistic_assert_1.0.1.tgz";
      path = fetchurl {
        name = "minimalistic_assert___minimalistic_assert_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/minimalistic-assert/-/minimalistic-assert-1.0.1.tgz";
        sha512 = "UtJcAD4yEaGtjPezWuO9wC4nwUnVH/8/Im3yEHQP4b67cXlD/Qr9hdITCU1xDbSEXg2XKNaP8jsReV7vQd00/A==";
      };
    }
    {
      name = "minimalistic_crypto_utils___minimalistic_crypto_utils_1.0.1.tgz";
      path = fetchurl {
        name = "minimalistic_crypto_utils___minimalistic_crypto_utils_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/minimalistic-crypto-utils/-/minimalistic-crypto-utils-1.0.1.tgz";
        sha1 = "9sAMHAsIIkblxNmd+4x8CDsrWCo=";
      };
    }
    {
      name = "minimatch___minimatch_3.0.4.tgz";
      path = fetchurl {
        name = "minimatch___minimatch_3.0.4.tgz";
        url  = "https://registry.yarnpkg.com/minimatch/-/minimatch-3.0.4.tgz";
        sha512 = "yJHVQEhyqPLUTgt9B83PXu6W3rx4MvvHvSUvToogpwoGDOUQ+yDrR0HRot+yOCdCO7u4hX3pWft6kWBBcqh0UA==";
      };
    }
    {
      name = "minimist___minimist_1.2.5.tgz";
      path = fetchurl {
        name = "minimist___minimist_1.2.5.tgz";
        url  = "https://registry.yarnpkg.com/minimist/-/minimist-1.2.5.tgz";
        sha512 = "FM9nNUYrRBAELZQT3xeZQ7fmMOBg6nWNmJKTcgsJeaLstP/UODVpGsr5OhXhhXg6f+qtJ8uiZ+PUxkDWcgIXLw==";
      };
    }
    {
      name = "mithril___mithril_1.1.7.tgz";
      path = fetchurl {
        name = "mithril___mithril_1.1.7.tgz";
        url  = "https://registry.yarnpkg.com/mithril/-/mithril-1.1.7.tgz";
        sha512 = "1SAkGeVrIVvkUHlPHvR3pXdWzNfTzmS/fBAe+rC2ApEBfZFFc+idi8Qg/M5JoW/sZkIDXSfQYVgvENMIhBIVAg==";
      };
    }
    {
      name = "mkdirp_classic___mkdirp_classic_0.5.3.tgz";
      path = fetchurl {
        name = "mkdirp_classic___mkdirp_classic_0.5.3.tgz";
        url  = "https://registry.yarnpkg.com/mkdirp-classic/-/mkdirp-classic-0.5.3.tgz";
        sha512 = "gKLcREMhtuZRwRAfqP3RFW+TK4JqApVBtOIftVgjuABpAtpxhPGaDcfvbhNvD0B8iD1oUr/txX35NjcaY6Ns/A==";
      };
    }
    {
      name = "module_deps___module_deps_6.2.3.tgz";
      path = fetchurl {
        name = "module_deps___module_deps_6.2.3.tgz";
        url  = "https://registry.yarnpkg.com/module-deps/-/module-deps-6.2.3.tgz";
        sha512 = "fg7OZaQBcL4/L+AK5f4iVqf9OMbCclXfy/znXRxTVhJSeW5AIlS9AwheYwDaXM3lVW7OBeaeUEY3gbaC6cLlSA==";
      };
    }
    {
      name = "moment___moment_2.29.1.tgz";
      path = fetchurl {
        name = "moment___moment_2.29.1.tgz";
        url  = "https://registry.yarnpkg.com/moment/-/moment-2.29.1.tgz";
        sha512 = "kHmoybcPV8Sqy59DwNDY3Jefr64lK/by/da0ViFcuA4DH0vQg5Q6Ze5VimxkfQNSC+Mls/Kx53s7TjP1RhFEDQ==";
      };
    }
    {
      name = "native_request___native_request_1.0.8.tgz";
      path = fetchurl {
        name = "native_request___native_request_1.0.8.tgz";
        url  = "https://registry.yarnpkg.com/native-request/-/native-request-1.0.8.tgz";
        sha512 = "vU2JojJVelUGp6jRcLwToPoWGxSx23z/0iX+I77J3Ht17rf2INGjrhOoQnjVo60nQd8wVsgzKkPfRXBiVdD2ag==";
      };
    }
    {
      name = "object_assign___object_assign_4.1.1.tgz";
      path = fetchurl {
        name = "object_assign___object_assign_4.1.1.tgz";
        url  = "https://registry.yarnpkg.com/object-assign/-/object-assign-4.1.1.tgz";
        sha1 = "IQmtx5ZYh8/AXLvUQsrIv7s2CGM=";
      };
    }
    {
      name = "once___once_1.4.0.tgz";
      path = fetchurl {
        name = "once___once_1.4.0.tgz";
        url  = "https://registry.yarnpkg.com/once/-/once-1.4.0.tgz";
        sha1 = "WDsap3WWHUsROsF9nFC6753Xa9E=";
      };
    }
    {
      name = "os_browserify___os_browserify_0.3.0.tgz";
      path = fetchurl {
        name = "os_browserify___os_browserify_0.3.0.tgz";
        url  = "https://registry.yarnpkg.com/os-browserify/-/os-browserify-0.3.0.tgz";
        sha1 = "hUNzx/XCMVkU/Jv8a9gjj92h7Cc=";
      };
    }
    {
      name = "otplib___otplib_11.0.1.tgz";
      path = fetchurl {
        name = "otplib___otplib_11.0.1.tgz";
        url  = "https://registry.yarnpkg.com/otplib/-/otplib-11.0.1.tgz";
        sha512 = "oi57teljNyWTC/JqJztHOtSGeFNDiDh5C1myd+faocUtFAX27Sm1mbx69kpEJ8/JqrblI3kAm4Pqd6tZJoOIBQ==";
      };
    }
    {
      name = "pako___pako_1.0.11.tgz";
      path = fetchurl {
        name = "pako___pako_1.0.11.tgz";
        url  = "https://registry.yarnpkg.com/pako/-/pako-1.0.11.tgz";
        sha512 = "4hLB8Py4zZce5s4yd9XzopqwVv/yGNhV1Bl8NTmCq1763HeK2+EwVTv+leGeL13Dnh2wfbqowVPXCIO0z4taYw==";
      };
    }
    {
      name = "parents___parents_1.0.1.tgz";
      path = fetchurl {
        name = "parents___parents_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/parents/-/parents-1.0.1.tgz";
        sha1 = "/t1NK/GTp3dF/nHjcdc8MwfZx1E=";
      };
    }
    {
      name = "parse_asn1___parse_asn1_5.1.6.tgz";
      path = fetchurl {
        name = "parse_asn1___parse_asn1_5.1.6.tgz";
        url  = "https://registry.yarnpkg.com/parse-asn1/-/parse-asn1-5.1.6.tgz";
        sha512 = "RnZRo1EPU6JBnra2vGHj0yhp6ebyjBZpmUCLHWiFhxlzvBCCpAuZ7elsBp1PVAbQN0/04VD/19rfzlBSwLstMw==";
      };
    }
    {
      name = "path_browserify___path_browserify_0.0.1.tgz";
      path = fetchurl {
        name = "path_browserify___path_browserify_0.0.1.tgz";
        url  = "https://registry.yarnpkg.com/path-browserify/-/path-browserify-0.0.1.tgz";
        sha512 = "BapA40NHICOS+USX9SN4tyhq+A2RrN/Ws5F0Z5aMHDp98Fl86lX8Oti8B7uN93L4Ifv4fHOEA+pQw87gmMO/lQ==";
      };
    }
    {
      name = "path_is_absolute___path_is_absolute_1.0.1.tgz";
      path = fetchurl {
        name = "path_is_absolute___path_is_absolute_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/path-is-absolute/-/path-is-absolute-1.0.1.tgz";
        sha1 = "F0uSaHNVNP+8es5r9TpanhtcX18=";
      };
    }
    {
      name = "path_parse___path_parse_1.0.6.tgz";
      path = fetchurl {
        name = "path_parse___path_parse_1.0.6.tgz";
        url  = "https://registry.yarnpkg.com/path-parse/-/path-parse-1.0.6.tgz";
        sha512 = "GSmOT2EbHrINBf9SR7CDELwlJ8AENk3Qn7OikK4nFYAu3Ote2+JYNVvkpAEQm3/TLNEJFD/xZJjzyxg3KBWOzw==";
      };
    }
    {
      name = "path_platform___path_platform_0.11.15.tgz";
      path = fetchurl {
        name = "path_platform___path_platform_0.11.15.tgz";
        url  = "https://registry.yarnpkg.com/path-platform/-/path-platform-0.11.15.tgz";
        sha1 = "6GQhf3TDaFDwhSt43Hv31KVyG/I=";
      };
    }
    {
      name = "pbkdf2___pbkdf2_3.1.1.tgz";
      path = fetchurl {
        name = "pbkdf2___pbkdf2_3.1.1.tgz";
        url  = "https://registry.yarnpkg.com/pbkdf2/-/pbkdf2-3.1.1.tgz";
        sha512 = "4Ejy1OPxi9f2tt1rRV7Go7zmfDQ+ZectEQz3VGUQhgq62HtIRPDyG/JtnwIxs6x3uNMwo2V7q1fMvKjb+Tnpqg==";
      };
    }
    {
      name = "pify___pify_4.0.1.tgz";
      path = fetchurl {
        name = "pify___pify_4.0.1.tgz";
        url  = "https://registry.yarnpkg.com/pify/-/pify-4.0.1.tgz";
        sha512 = "uB80kBFb/tfd68bVleG9T5GGsGPjJrLAUpR5PZIrhBnIaRTQRjqdJSsIKkOP6OAIFbj7GOrcudc5pNjZ+geV2g==";
      };
    }
    {
      name = "prettier___prettier_2.2.1.tgz";
      path = fetchurl {
        name = "prettier___prettier_2.2.1.tgz";
        url  = "https://registry.yarnpkg.com/prettier/-/prettier-2.2.1.tgz";
        sha512 = "PqyhM2yCjg/oKkFPtTGUojv7gnZAoG80ttl45O6x2Ug/rMJw4wcc9k6aaf2hibP7BGVCCM33gZoGjyvt9mm16Q==";
      };
    }
    {
      name = "process_nextick_args___process_nextick_args_2.0.1.tgz";
      path = fetchurl {
        name = "process_nextick_args___process_nextick_args_2.0.1.tgz";
        url  = "https://registry.yarnpkg.com/process-nextick-args/-/process-nextick-args-2.0.1.tgz";
        sha512 = "3ouUOpQhtgrbOa17J7+uxOTpITYWaGP7/AhoR3+A+/1e9skrzelGi/dXzEYyvbxubEF6Wn2ypscTKiKJFFn1ag==";
      };
    }
    {
      name = "process___process_0.11.10.tgz";
      path = fetchurl {
        name = "process___process_0.11.10.tgz";
        url  = "https://registry.yarnpkg.com/process/-/process-0.11.10.tgz";
        sha1 = "czIwDoQBYb2j5podHZGn1LwW8YI=";
      };
    }
    {
      name = "prr___prr_1.0.1.tgz";
      path = fetchurl {
        name = "prr___prr_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/prr/-/prr-1.0.1.tgz";
        sha1 = "0/wRS6BplaRexok/SEzrHXj19HY=";
      };
    }
    {
      name = "public_encrypt___public_encrypt_4.0.3.tgz";
      path = fetchurl {
        name = "public_encrypt___public_encrypt_4.0.3.tgz";
        url  = "https://registry.yarnpkg.com/public-encrypt/-/public-encrypt-4.0.3.tgz";
        sha512 = "zVpa8oKZSz5bTMTFClc1fQOnyyEzpl5ozpi1B5YcvBrdohMjH2rfsBtyXcuNuwjsDIXmBYlF2N5FlJYhR29t8Q==";
      };
    }
    {
      name = "punycode___punycode_1.3.2.tgz";
      path = fetchurl {
        name = "punycode___punycode_1.3.2.tgz";
        url  = "https://registry.yarnpkg.com/punycode/-/punycode-1.3.2.tgz";
        sha1 = "llOgNvt8HuQjQvIyXM7v6jkmxI0=";
      };
    }
    {
      name = "punycode___punycode_1.4.1.tgz";
      path = fetchurl {
        name = "punycode___punycode_1.4.1.tgz";
        url  = "https://registry.yarnpkg.com/punycode/-/punycode-1.4.1.tgz";
        sha1 = "wNWmOycYgArY4esPpSachN1BhF4=";
      };
    }
    {
      name = "punycode___punycode_2.1.1.tgz";
      path = fetchurl {
        name = "punycode___punycode_2.1.1.tgz";
        url  = "https://registry.yarnpkg.com/punycode/-/punycode-2.1.1.tgz";
        sha512 = "XRsRjdf+j5ml+y/6GKHPZbrF/8p2Yga0JPtdqTIY2Xe5ohJPD9saDJJLPvp9+NSBprVvevdXZybnj2cv8OEd0A==";
      };
    }
    {
      name = "querystring_es3___querystring_es3_0.2.1.tgz";
      path = fetchurl {
        name = "querystring_es3___querystring_es3_0.2.1.tgz";
        url  = "https://registry.yarnpkg.com/querystring-es3/-/querystring-es3-0.2.1.tgz";
        sha1 = "nsYfeQSYdXB9aUFFlv2Qek1xHnM=";
      };
    }
    {
      name = "querystring___querystring_0.2.0.tgz";
      path = fetchurl {
        name = "querystring___querystring_0.2.0.tgz";
        url  = "https://registry.yarnpkg.com/querystring/-/querystring-0.2.0.tgz";
        sha1 = "sgmEkgO7Jd+CDadW50cAWHhSFiA=";
      };
    }
    {
      name = "randombytes___randombytes_2.1.0.tgz";
      path = fetchurl {
        name = "randombytes___randombytes_2.1.0.tgz";
        url  = "https://registry.yarnpkg.com/randombytes/-/randombytes-2.1.0.tgz";
        sha512 = "vYl3iOX+4CKUWuxGi9Ukhie6fsqXqS9FE2Zaic4tNFD2N2QQaXOMFbuKK4QmDHC0JO6B1Zp41J0LpT0oR68amQ==";
      };
    }
    {
      name = "randomfill___randomfill_1.0.4.tgz";
      path = fetchurl {
        name = "randomfill___randomfill_1.0.4.tgz";
        url  = "https://registry.yarnpkg.com/randomfill/-/randomfill-1.0.4.tgz";
        sha512 = "87lcbR8+MhcWcUiQ+9e+Rwx8MyR2P7qnt15ynUlbm3TU/fjbgz4GsvfSUDTemtCCtVCqb4ZcEFlyPNTh9bBTLw==";
      };
    }
    {
      name = "read_only_stream___read_only_stream_2.0.0.tgz";
      path = fetchurl {
        name = "read_only_stream___read_only_stream_2.0.0.tgz";
        url  = "https://registry.yarnpkg.com/read-only-stream/-/read-only-stream-2.0.0.tgz";
        sha1 = "JyT9aoET1zdkrCiNQ4YnDB2/F/A=";
      };
    }
    {
      name = "readable_stream___readable_stream_2.3.7.tgz";
      path = fetchurl {
        name = "readable_stream___readable_stream_2.3.7.tgz";
        url  = "https://registry.yarnpkg.com/readable-stream/-/readable-stream-2.3.7.tgz";
        sha512 = "Ebho8K4jIbHAxnuxi7o42OrZgF/ZTNcsZj6nRKyUmkhLFq8CHItp/fy6hQZuZmP/n3yZ9VBUbp4zz/mX8hmYPw==";
      };
    }
    {
      name = "readable_stream___readable_stream_3.6.0.tgz";
      path = fetchurl {
        name = "readable_stream___readable_stream_3.6.0.tgz";
        url  = "https://registry.yarnpkg.com/readable-stream/-/readable-stream-3.6.0.tgz";
        sha512 = "BViHy7LKeTz4oNnkcLJ+lVSL6vpiFeX6/d3oSH8zCW7UxP2onchk+vTGB143xuFjHS3deTgkKoXXymXqymiIdA==";
      };
    }
    {
      name = "resolve___resolve_1.19.0.tgz";
      path = fetchurl {
        name = "resolve___resolve_1.19.0.tgz";
        url  = "https://registry.yarnpkg.com/resolve/-/resolve-1.19.0.tgz";
        sha512 = "rArEXAgsBG4UgRGcynxWIWKFvh/XZCcS8UJdHhwy91zwAvCZIbcs+vAbflgBnNjYMs/i/i+/Ux6IZhML1yPvxg==";
      };
    }
    {
      name = "ripemd160___ripemd160_2.0.2.tgz";
      path = fetchurl {
        name = "ripemd160___ripemd160_2.0.2.tgz";
        url  = "https://registry.yarnpkg.com/ripemd160/-/ripemd160-2.0.2.tgz";
        sha512 = "ii4iagi25WusVoiC4B4lq7pbXfAp3D9v5CwfkY33vffw2+pkDjY1D8GaN7spsxvCSx8dkPqOZCEZyfxcmJG2IA==";
      };
    }
    {
      name = "safe_buffer___safe_buffer_5.2.1.tgz";
      path = fetchurl {
        name = "safe_buffer___safe_buffer_5.2.1.tgz";
        url  = "https://registry.yarnpkg.com/safe-buffer/-/safe-buffer-5.2.1.tgz";
        sha512 = "rp3So07KcdmmKbGvgaNxQSJr7bGVSVk5S9Eq1F+ppbRo70+YeaDxkw5Dd8NPN+GD6bjnYm2VuPuCXmpuYvmCXQ==";
      };
    }
    {
      name = "safe_buffer___safe_buffer_5.1.2.tgz";
      path = fetchurl {
        name = "safe_buffer___safe_buffer_5.1.2.tgz";
        url  = "https://registry.yarnpkg.com/safe-buffer/-/safe-buffer-5.1.2.tgz";
        sha512 = "Gd2UZBJDkXlY7GbJxfsE8/nvKkUEU1G38c1siN6QP6a9PT9MmHB8GnpscSmMJSoF8LOIrt8ud/wPtojys4G6+g==";
      };
    }
    {
      name = "safer_buffer___safer_buffer_2.1.2.tgz";
      path = fetchurl {
        name = "safer_buffer___safer_buffer_2.1.2.tgz";
        url  = "https://registry.yarnpkg.com/safer-buffer/-/safer-buffer-2.1.2.tgz";
        sha512 = "YZo3K82SD7Riyi0E1EQPojLz7kpepnSQI9IyPbHHg1XXXevb5dJI7tpyN2ADxGcQbHG7vcyRHk0cbwqcQriUtg==";
      };
    }
    {
      name = "semver___semver_5.7.1.tgz";
      path = fetchurl {
        name = "semver___semver_5.7.1.tgz";
        url  = "https://registry.yarnpkg.com/semver/-/semver-5.7.1.tgz";
        sha512 = "sauaDf/PZdVgrLTNYHRtpXa1iRiKcaebiKQ1BJdpQlWH2lCvexQdX55snPFyK7QzpudqbCI0qXFfOasHdyNDGQ==";
      };
    }
    {
      name = "sha.js___sha.js_2.4.11.tgz";
      path = fetchurl {
        name = "sha.js___sha.js_2.4.11.tgz";
        url  = "https://registry.yarnpkg.com/sha.js/-/sha.js-2.4.11.tgz";
        sha512 = "QMEp5B7cftE7APOjk5Y6xgrbWu+WkLVQwk8JNjZ8nKRciZaByEW6MubieAiToS7+dwvrjGhH8jRXz3MVd0AYqQ==";
      };
    }
    {
      name = "sha1___sha1_1.1.1.tgz";
      path = fetchurl {
        name = "sha1___sha1_1.1.1.tgz";
        url  = "https://registry.yarnpkg.com/sha1/-/sha1-1.1.1.tgz";
        sha1 = "rdqnqTFo85PxnrKxUJFhjicA+Eg=";
      };
    }
    {
      name = "shasum_object___shasum_object_1.0.0.tgz";
      path = fetchurl {
        name = "shasum_object___shasum_object_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/shasum-object/-/shasum-object-1.0.0.tgz";
        sha512 = "Iqo5rp/3xVi6M4YheapzZhhGPVs0yZwHj7wvwQ1B9z8H6zk+FEnI7y3Teq7qwnekfEhu8WmG2z0z4iWZaxLWVg==";
      };
    }
    {
      name = "shasum___shasum_1.0.2.tgz";
      path = fetchurl {
        name = "shasum___shasum_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/shasum/-/shasum-1.0.2.tgz";
        sha1 = "5wEjENj0F/TetXEhUOVni4euVl8=";
      };
    }
    {
      name = "shell_quote___shell_quote_1.7.2.tgz";
      path = fetchurl {
        name = "shell_quote___shell_quote_1.7.2.tgz";
        url  = "https://registry.yarnpkg.com/shell-quote/-/shell-quote-1.7.2.tgz";
        sha512 = "mRz/m/JVscCrkMyPqHc/bczi3OQHkLTqXHEFu0zDhK/qfv3UcOA4SVmRCLmos4bhjr9ekVQubj/R7waKapmiQg==";
      };
    }
    {
      name = "simple_concat___simple_concat_1.0.1.tgz";
      path = fetchurl {
        name = "simple_concat___simple_concat_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/simple-concat/-/simple-concat-1.0.1.tgz";
        sha512 = "cSFtAPtRhljv69IK0hTVZQ+OfE9nePi/rtJmw5UjHeVyVroEqJXP1sFztKUy1qU+xvz3u/sfYJLa947b7nAN2Q==";
      };
    }
    {
      name = "source_map___source_map_0.5.7.tgz";
      path = fetchurl {
        name = "source_map___source_map_0.5.7.tgz";
        url  = "https://registry.yarnpkg.com/source-map/-/source-map-0.5.7.tgz";
        sha1 = "igOdLRAh0i0eoUyA2OpGi6LvP8w=";
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
      name = "stream_browserify___stream_browserify_2.0.2.tgz";
      path = fetchurl {
        name = "stream_browserify___stream_browserify_2.0.2.tgz";
        url  = "https://registry.yarnpkg.com/stream-browserify/-/stream-browserify-2.0.2.tgz";
        sha512 = "nX6hmklHs/gr2FuxYDltq8fJA1GDlxKQCz8O/IM4atRqBH8OORmBNgfvW5gG10GT/qQ9u0CzIvr2X5Pkt6ntqg==";
      };
    }
    {
      name = "stream_combiner2___stream_combiner2_1.1.1.tgz";
      path = fetchurl {
        name = "stream_combiner2___stream_combiner2_1.1.1.tgz";
        url  = "https://registry.yarnpkg.com/stream-combiner2/-/stream-combiner2-1.1.1.tgz";
        sha1 = "+02KFCDqNidk4hrUeAOXvry0HL4=";
      };
    }
    {
      name = "stream_http___stream_http_3.1.1.tgz";
      path = fetchurl {
        name = "stream_http___stream_http_3.1.1.tgz";
        url  = "https://registry.yarnpkg.com/stream-http/-/stream-http-3.1.1.tgz";
        sha512 = "S7OqaYu0EkFpgeGFb/NPOoPLxFko7TPqtEeFg5DXPB4v/KETHG0Ln6fRFrNezoelpaDKmycEmmZ81cC9DAwgYg==";
      };
    }
    {
      name = "stream_splicer___stream_splicer_2.0.1.tgz";
      path = fetchurl {
        name = "stream_splicer___stream_splicer_2.0.1.tgz";
        url  = "https://registry.yarnpkg.com/stream-splicer/-/stream-splicer-2.0.1.tgz";
        sha512 = "Xizh4/NPuYSyAXyT7g8IvdJ9HJpxIGL9PjyhtywCZvvP0OPIdqyrr4dMikeuvY8xahpdKEBlBTySe583totajg==";
      };
    }
    {
      name = "string_decoder___string_decoder_1.3.0.tgz";
      path = fetchurl {
        name = "string_decoder___string_decoder_1.3.0.tgz";
        url  = "https://registry.yarnpkg.com/string_decoder/-/string_decoder-1.3.0.tgz";
        sha512 = "hkRX8U1WjJFd8LsDJ2yQ/wWWxaopEsABU1XfkM8A+j0+85JAGppt16cr1Whg6KIbb4okU6Mql6BOj+uup/wKeA==";
      };
    }
    {
      name = "string_decoder___string_decoder_1.1.1.tgz";
      path = fetchurl {
        name = "string_decoder___string_decoder_1.1.1.tgz";
        url  = "https://registry.yarnpkg.com/string_decoder/-/string_decoder-1.1.1.tgz";
        sha512 = "n/ShnvDi6FHbbVfviro+WojiFzv+s8MPMHBczVePfUpDJLwoLT0ht1l4YwBCbi8pJAveEEdnkHyPyTP/mzRfwg==";
      };
    }
    {
      name = "subarg___subarg_1.0.0.tgz";
      path = fetchurl {
        name = "subarg___subarg_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/subarg/-/subarg-1.0.0.tgz";
        sha1 = "9izxdYHplrSPyWVpn1TAauJouNI=";
      };
    }
    {
      name = "syntax_error___syntax_error_1.4.0.tgz";
      path = fetchurl {
        name = "syntax_error___syntax_error_1.4.0.tgz";
        url  = "https://registry.yarnpkg.com/syntax-error/-/syntax-error-1.4.0.tgz";
        sha512 = "YPPlu67mdnHGTup2A8ff7BC2Pjq0e0Yp/IyTFN03zWO0RcK07uLcbi7C2KpGR2FvWbaB0+bfE27a+sBKebSo7w==";
      };
    }
    {
      name = "thirty_two___thirty_two_1.0.2.tgz";
      path = fetchurl {
        name = "thirty_two___thirty_two_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/thirty-two/-/thirty-two-1.0.2.tgz";
        sha1 = "TKL//AKlEpDSdEueP1V2k8prYno=";
      };
    }
    {
      name = "through2___through2_2.0.5.tgz";
      path = fetchurl {
        name = "through2___through2_2.0.5.tgz";
        url  = "https://registry.yarnpkg.com/through2/-/through2-2.0.5.tgz";
        sha512 = "/mrRod8xqpA+IHSLyGCQ2s8SPHiCDEeQJSep1jqLYeEUClOFG2Qsh+4FU6G9VeqpZnGW/Su8LQGc4YKni5rYSQ==";
      };
    }
    {
      name = "through___through_2.3.8.tgz";
      path = fetchurl {
        name = "through___through_2.3.8.tgz";
        url  = "https://registry.yarnpkg.com/through/-/through-2.3.8.tgz";
        sha1 = "DdTJ/6q8NXlgsbckEV1+Doai4fU=";
      };
    }
    {
      name = "timers_browserify___timers_browserify_1.4.2.tgz";
      path = fetchurl {
        name = "timers_browserify___timers_browserify_1.4.2.tgz";
        url  = "https://registry.yarnpkg.com/timers-browserify/-/timers-browserify-1.4.2.tgz";
        sha1 = "ycWLV1voQHN1y14kYtrO50NZ9B0=";
      };
    }
    {
      name = "tslib___tslib_1.14.1.tgz";
      path = fetchurl {
        name = "tslib___tslib_1.14.1.tgz";
        url  = "https://registry.yarnpkg.com/tslib/-/tslib-1.14.1.tgz";
        sha512 = "Xni35NKzjgMrwevysHTCArtLDpPvye8zV/0E4EyYn43P7/7qvQwPh9BGkHewbMulVntbigmcT7rdX3BNo9wRJg==";
      };
    }
    {
      name = "tty_browserify___tty_browserify_0.0.1.tgz";
      path = fetchurl {
        name = "tty_browserify___tty_browserify_0.0.1.tgz";
        url  = "https://registry.yarnpkg.com/tty-browserify/-/tty-browserify-0.0.1.tgz";
        sha512 = "C3TaO7K81YvjCgQH9Q1S3R3P3BtN3RIM8n+OvX4il1K1zgE8ZhI0op7kClgkxtutIE8hQrcrHBXvIheqKUUCxw==";
      };
    }
    {
      name = "typedarray___typedarray_0.0.6.tgz";
      path = fetchurl {
        name = "typedarray___typedarray_0.0.6.tgz";
        url  = "https://registry.yarnpkg.com/typedarray/-/typedarray-0.0.6.tgz";
        sha1 = "hnrHTjhkGHsdPUfZlqeOxciDB3c=";
      };
    }
    {
      name = "umd___umd_3.0.3.tgz";
      path = fetchurl {
        name = "umd___umd_3.0.3.tgz";
        url  = "https://registry.yarnpkg.com/umd/-/umd-3.0.3.tgz";
        sha512 = "4IcGSufhFshvLNcMCV80UnQVlZ5pMOC8mvNPForqwA4+lzYQuetTESLDQkeLmihq8bRcnpbQa48Wb8Lh16/xow==";
      };
    }
    {
      name = "undeclared_identifiers___undeclared_identifiers_1.1.3.tgz";
      path = fetchurl {
        name = "undeclared_identifiers___undeclared_identifiers_1.1.3.tgz";
        url  = "https://registry.yarnpkg.com/undeclared-identifiers/-/undeclared-identifiers-1.1.3.tgz";
        sha512 = "pJOW4nxjlmfwKApE4zvxLScM/njmwj/DiUBv7EabwE4O8kRUy+HIwxQtZLBPll/jx1LJyBcqNfB3/cpv9EZwOw==";
      };
    }
    {
      name = "url___url_0.11.0.tgz";
      path = fetchurl {
        name = "url___url_0.11.0.tgz";
        url  = "https://registry.yarnpkg.com/url/-/url-0.11.0.tgz";
        sha1 = "ODjpfPxgUh63PFJajlW/3Z4uKPE=";
      };
    }
    {
      name = "util_deprecate___util_deprecate_1.0.2.tgz";
      path = fetchurl {
        name = "util_deprecate___util_deprecate_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/util-deprecate/-/util-deprecate-1.0.2.tgz";
        sha1 = "RQ1Nyfpw3nMnYvvS1KKJgUGaDM8=";
      };
    }
    {
      name = "util___util_0.10.3.tgz";
      path = fetchurl {
        name = "util___util_0.10.3.tgz";
        url  = "https://registry.yarnpkg.com/util/-/util-0.10.3.tgz";
        sha1 = "evsa/lCAUkZInj23/g7TeTNqwPk=";
      };
    }
    {
      name = "util___util_0.10.4.tgz";
      path = fetchurl {
        name = "util___util_0.10.4.tgz";
        url  = "https://registry.yarnpkg.com/util/-/util-0.10.4.tgz";
        sha512 = "0Pm9hTQ3se5ll1XihRic3FDIku70C+iHUdT/W926rSgHV5QgXsYbKZN8MSC3tJtSkhuROzvsQjAaFENRXr+19A==";
      };
    }
    {
      name = "vm_browserify___vm_browserify_1.1.2.tgz";
      path = fetchurl {
        name = "vm_browserify___vm_browserify_1.1.2.tgz";
        url  = "https://registry.yarnpkg.com/vm-browserify/-/vm-browserify-1.1.2.tgz";
        sha512 = "2ham8XPWTONajOR0ohOKOHXkm3+gaBmGut3SRuu75xLd/RRaY6vqgh8NBYYk7+RW3u5AtzPQZG8F10LHkl0lAQ==";
      };
    }
    {
      name = "wrappy___wrappy_1.0.2.tgz";
      path = fetchurl {
        name = "wrappy___wrappy_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/wrappy/-/wrappy-1.0.2.tgz";
        sha1 = "tSQ9jz7BqjXxNkYFvA0QNuMKtp8=";
      };
    }
    {
      name = "xtend___xtend_4.0.2.tgz";
      path = fetchurl {
        name = "xtend___xtend_4.0.2.tgz";
        url  = "https://registry.yarnpkg.com/xtend/-/xtend-4.0.2.tgz";
        sha512 = "LKYU1iAXJXUgAXn9URjiu+MWhyUXHsvfp7mcuYm9dSUKK0/CjtrUwFAxD82/mCWbtLsGjFIad0wIsod4zrTAEQ==";
      };
    }
  ];
}
