{fetchurl, linkFarm}: rec {
  offline_cache = linkFarm "offline" packages;
  packages = [

    {
      name = "https___github.com_berrnd_bootstrap_combobox_archive_fcf0110146f4daab94888234c57d198b4ca5f129.tar.gz";
      path = fetchurl {
        name = "https___github.com_berrnd_bootstrap_combobox_archive_fcf0110146f4daab94888234c57d198b4ca5f129.tar.g";
        url  = "https://github.com/berrnd/bootstrap-combobox/archive/fcf0110146f4daab94888234c57d198b4ca5f129.tar.gz";
        sha1 = "0nvnkr1w9nnn7r2h63zmkjpphawwmfca";
      };
    }

    {
      name = "_fortawesome_fontawesome_free___fontawesome_free_5.12.1.tgz";
      path = fetchurl {
        name = "_fortawesome_fontawesome_free___fontawesome_free_5.12.1.tgz";
        url  = "https://registry.yarnpkg.com/@fortawesome/fontawesome-free/-/fontawesome-free-5.12.1.tgz";
        sha1 = "2a98fea9fbb8a606ddc79a4680034e9d5591c550";
      };
    }

    {
      name = "https___github.com_max_favilli_tagmanager_archive_b43646ef2f2373facaf21c7acc5e3eea61188d76.tar.gz";
      path = fetchurl {
        name = "https___github.com_max_favilli_tagmanager_archive_b43646ef2f2373facaf21c7acc5e3eea61188d76.tar.gz";
        url  = "https://github.com/max-favilli/tagmanager/archive/b43646ef2f2373facaf21c7acc5e3eea61188d76.tar.gz";
        sha1 = "1p7d96k4gnn2jm0fj15y9f62a1z9cn7p";
      };
    }

    {
      name = "ajv___ajv_6.11.0.tgz";
      path = fetchurl {
        name = "ajv___ajv_6.11.0.tgz";
        url  = "https://registry.yarnpkg.com/ajv/-/ajv-6.11.0.tgz";
        sha1 = "c3607cbc8ae392d8a5a536f25b21f8e5f3f87fe9";
      };
    }

    {
      name = "animate.css___animate.css_3.7.2.tgz";
      path = fetchurl {
        name = "animate.css___animate.css_3.7.2.tgz";
        url  = "https://registry.yarnpkg.com/animate.css/-/animate.css-3.7.2.tgz";
        sha1 = "e73e0d50e92cb1cfef1597d9b38a9481020e08ea";
      };
    }

    {
      name = "asn1___asn1_0.2.4.tgz";
      path = fetchurl {
        name = "asn1___asn1_0.2.4.tgz";
        url  = "https://registry.yarnpkg.com/asn1/-/asn1-0.2.4.tgz";
        sha1 = "8d2475dfab553bb33e77b54e59e880bb8ce23136";
      };
    }

    {
      name = "assert_plus___assert_plus_1.0.0.tgz";
      path = fetchurl {
        name = "assert_plus___assert_plus_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/assert-plus/-/assert-plus-1.0.0.tgz";
        sha1 = "f12e0f3c5d77b0b1cdd9146942e4e96c1e4dd525";
      };
    }

    {
      name = "asynckit___asynckit_0.4.0.tgz";
      path = fetchurl {
        name = "asynckit___asynckit_0.4.0.tgz";
        url  = "https://registry.yarnpkg.com/asynckit/-/asynckit-0.4.0.tgz";
        sha1 = "c79ed97f7f34cb8f2ba1bc9790bcc366474b4b79";
      };
    }

    {
      name = "aws_sign2___aws_sign2_0.7.0.tgz";
      path = fetchurl {
        name = "aws_sign2___aws_sign2_0.7.0.tgz";
        url  = "https://registry.yarnpkg.com/aws-sign2/-/aws-sign2-0.7.0.tgz";
        sha1 = "b46e890934a9591f2d2f6f86d7e6a9f1b3fe76a8";
      };
    }

    {
      name = "aws4___aws4_1.9.1.tgz";
      path = fetchurl {
        name = "aws4___aws4_1.9.1.tgz";
        url  = "https://registry.yarnpkg.com/aws4/-/aws4-1.9.1.tgz";
        sha1 = "7e33d8f7d449b3f673cd72deb9abdc552dbe528e";
      };
    }

    {
      name = "bcrypt_pbkdf___bcrypt_pbkdf_1.0.2.tgz";
      path = fetchurl {
        name = "bcrypt_pbkdf___bcrypt_pbkdf_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/bcrypt-pbkdf/-/bcrypt-pbkdf-1.0.2.tgz";
        sha1 = "a4301d389b6a43f9b67ff3ca11a3f6637e360e9e";
      };
    }

    {
      name = "bootbox___bootbox_5.4.0.tgz";
      path = fetchurl {
        name = "bootbox___bootbox_5.4.0.tgz";
        url  = "https://registry.yarnpkg.com/bootbox/-/bootbox-5.4.0.tgz";
        sha1 = "2857a63c270b1b797d62e4c5597e74b497267655";
      };
    }

    {
      name = "bootstrap_select___bootstrap_select_1.13.12.tgz";
      path = fetchurl {
        name = "bootstrap_select___bootstrap_select_1.13.12.tgz";
        url  = "https://registry.yarnpkg.com/bootstrap-select/-/bootstrap-select-1.13.12.tgz";
        sha1 = "81b9f1394cb8d7151aea16fb9030c112330dbf98";
      };
    }

    {
      name = "bootstrap___bootstrap_4.0.0.tgz";
      path = fetchurl {
        name = "bootstrap___bootstrap_4.0.0.tgz";
        url  = "https://registry.yarnpkg.com/bootstrap/-/bootstrap-4.0.0.tgz";
        sha1 = "ceb03842c145fcc1b9b4e15da2a05656ba68469a";
      };
    }

    {
      name = "bootstrap___bootstrap_4.4.1.tgz";
      path = fetchurl {
        name = "bootstrap___bootstrap_4.4.1.tgz";
        url  = "https://registry.yarnpkg.com/bootstrap/-/bootstrap-4.4.1.tgz";
        sha1 = "8582960eea0c5cd2bede84d8b0baf3789c3e8b01";
      };
    }

    {
      name = "caseless___caseless_0.12.0.tgz";
      path = fetchurl {
        name = "caseless___caseless_0.12.0.tgz";
        url  = "https://registry.yarnpkg.com/caseless/-/caseless-0.12.0.tgz";
        sha1 = "1b681c21ff84033c826543090689420d187151dc";
      };
    }

    {
      name = "chart.js___chart.js_2.7.1.tgz";
      path = fetchurl {
        name = "chart.js___chart.js_2.7.1.tgz";
        url  = "https://registry.yarnpkg.com/chart.js/-/chart.js-2.7.1.tgz";
        sha1 = "ae90b4aa4ff1f02decd6b1a2a8dabfd73c9f9886";
      };
    }

    {
      name = "chart.js___chart.js_2.9.3.tgz";
      path = fetchurl {
        name = "chart.js___chart.js_2.9.3.tgz";
        url  = "https://registry.yarnpkg.com/chart.js/-/chart.js-2.9.3.tgz";
        sha1 = "ae3884114dafd381bc600f5b35a189138aac1ef7";
      };
    }

    {
      name = "chartjs_color_string___chartjs_color_string_0.5.0.tgz";
      path = fetchurl {
        name = "chartjs_color_string___chartjs_color_string_0.5.0.tgz";
        url  = "https://registry.yarnpkg.com/chartjs-color-string/-/chartjs-color-string-0.5.0.tgz";
        sha1 = "8d3752d8581d86687c35bfe2cb80ac5213ceb8c1";
      };
    }

    {
      name = "chartjs_color_string___chartjs_color_string_0.6.0.tgz";
      path = fetchurl {
        name = "chartjs_color_string___chartjs_color_string_0.6.0.tgz";
        url  = "https://registry.yarnpkg.com/chartjs-color-string/-/chartjs-color-string-0.6.0.tgz";
        sha1 = "1df096621c0e70720a64f4135ea171d051402f71";
      };
    }

    {
      name = "chartjs_color___chartjs_color_2.4.1.tgz";
      path = fetchurl {
        name = "chartjs_color___chartjs_color_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/chartjs-color/-/chartjs-color-2.4.1.tgz";
        sha1 = "6118bba202fe1ea79dd7f7c0f9da93467296c3b0";
      };
    }

    {
      name = "chartjs_color___chartjs_color_2.2.0.tgz";
      path = fetchurl {
        name = "chartjs_color___chartjs_color_2.2.0.tgz";
        url  = "https://registry.yarnpkg.com/chartjs-color/-/chartjs-color-2.2.0.tgz";
        sha1 = "84a2fb755787ed85c39dd6dd8c7b1d88429baeae";
      };
    }

    {
      name = "color_convert___color_convert_0.5.3.tgz";
      path = fetchurl {
        name = "color_convert___color_convert_0.5.3.tgz";
        url  = "https://registry.yarnpkg.com/color-convert/-/color-convert-0.5.3.tgz";
        sha1 = "bdb6c69ce660fadffe0b0007cc447e1b9f7282bd";
      };
    }

    {
      name = "color_convert___color_convert_1.9.3.tgz";
      path = fetchurl {
        name = "color_convert___color_convert_1.9.3.tgz";
        url  = "https://registry.yarnpkg.com/color-convert/-/color-convert-1.9.3.tgz";
        sha1 = "bb71850690e1f136567de629d2d5471deda4c1e8";
      };
    }

    {
      name = "color_name___color_name_1.1.3.tgz";
      path = fetchurl {
        name = "color_name___color_name_1.1.3.tgz";
        url  = "https://registry.yarnpkg.com/color-name/-/color-name-1.1.3.tgz";
        sha1 = "a7d0558bd89c42f795dd42328f740831ca53bc25";
      };
    }

    {
      name = "color_name___color_name_1.1.4.tgz";
      path = fetchurl {
        name = "color_name___color_name_1.1.4.tgz";
        url  = "https://registry.yarnpkg.com/color-name/-/color-name-1.1.4.tgz";
        sha1 = "c2a09a87acbde69543de6f63fa3995c826c536a2";
      };
    }

    {
      name = "combined_stream___combined_stream_1.0.8.tgz";
      path = fetchurl {
        name = "combined_stream___combined_stream_1.0.8.tgz";
        url  = "https://registry.yarnpkg.com/combined-stream/-/combined-stream-1.0.8.tgz";
        sha1 = "c3d45a8b34fd730631a110a8a2520682b31d5a7f";
      };
    }

    {
      name = "core_util_is___core_util_is_1.0.2.tgz";
      path = fetchurl {
        name = "core_util_is___core_util_is_1.0.2.tgz";
        url  = "https://registry.yarnpkg.com/core-util-is/-/core-util-is-1.0.2.tgz";
        sha1 = "b5fd54220aa2bc5ab57aab7140c940754503c1a7";
      };
    }

    {
      name = "cwise_compiler___cwise_compiler_1.1.3.tgz";
      path = fetchurl {
        name = "cwise_compiler___cwise_compiler_1.1.3.tgz";
        url  = "https://registry.yarnpkg.com/cwise-compiler/-/cwise-compiler-1.1.3.tgz";
        sha1 = "f4d667410e850d3a313a7d2db7b1e505bb034cc5";
      };
    }

    {
      name = "dashdash___dashdash_1.14.1.tgz";
      path = fetchurl {
        name = "dashdash___dashdash_1.14.1.tgz";
        url  = "https://registry.yarnpkg.com/dashdash/-/dashdash-1.14.1.tgz";
        sha1 = "853cfa0f7cbe2fed5de20326b8dd581035f6e2f0";
      };
    }

    {
      name = "data_uri_to_buffer___data_uri_to_buffer_0.0.3.tgz";
      path = fetchurl {
        name = "data_uri_to_buffer___data_uri_to_buffer_0.0.3.tgz";
        url  = "https://registry.yarnpkg.com/data-uri-to-buffer/-/data-uri-to-buffer-0.0.3.tgz";
        sha1 = "18ae979a6a0ca994b0625853916d2662bbae0b1a";
      };
    }

    {
      name = "datatables.net_bs4___datatables.net_bs4_1.10.16.tgz";
      path = fetchurl {
        name = "datatables.net_bs4___datatables.net_bs4_1.10.16.tgz";
        url  = "https://registry.yarnpkg.com/datatables.net-bs4/-/datatables.net-bs4-1.10.16.tgz";
        sha1 = "9eee67cfa8565bd3807a603a188305f7d0e20e32";
      };
    }

    {
      name = "datatables.net_bs4___datatables.net_bs4_1.10.20.tgz";
      path = fetchurl {
        name = "datatables.net_bs4___datatables.net_bs4_1.10.20.tgz";
        url  = "https://registry.yarnpkg.com/datatables.net-bs4/-/datatables.net-bs4-1.10.20.tgz";
        sha1 = "beff1c8d3510826c0678eaa055270607c0e53882";
      };
    }

    {
      name = "datatables.net_colreorder_bs4___datatables.net_colreorder_bs4_1.5.2.tgz";
      path = fetchurl {
        name = "datatables.net_colreorder_bs4___datatables.net_colreorder_bs4_1.5.2.tgz";
        url  = "https://registry.yarnpkg.com/datatables.net-colreorder-bs4/-/datatables.net-colreorder-bs4-1.5.2.tgz";
        sha1 = "4fe1a9ffe679e7e84f3ccb58c9c4d31ac0d49a1b";
      };
    }

    {
      name = "datatables.net_colreorder___datatables.net_colreorder_1.5.2.tgz";
      path = fetchurl {
        name = "datatables.net_colreorder___datatables.net_colreorder_1.5.2.tgz";
        url  = "https://registry.yarnpkg.com/datatables.net-colreorder/-/datatables.net-colreorder-1.5.2.tgz";
        sha1 = "c425cee1f88b3246be0363c67a152be743ca6bce";
      };
    }

    {
      name = "datatables.net_responsive_bs4___datatables.net_responsive_bs4_2.2.3.tgz";
      path = fetchurl {
        name = "datatables.net_responsive_bs4___datatables.net_responsive_bs4_2.2.3.tgz";
        url  = "https://registry.yarnpkg.com/datatables.net-responsive-bs4/-/datatables.net-responsive-bs4-2.2.3.tgz";
        sha1 = "639de17c1d31210ebf2b3c25f1c774c13f729e94";
      };
    }

    {
      name = "datatables.net_responsive___datatables.net_responsive_2.2.3.tgz";
      path = fetchurl {
        name = "datatables.net_responsive___datatables.net_responsive_2.2.3.tgz";
        url  = "https://registry.yarnpkg.com/datatables.net-responsive/-/datatables.net-responsive-2.2.3.tgz";
        sha1 = "50a2b1b4955b16b32f573a3f00f473b0bfbee913";
      };
    }

    {
      name = "datatables.net_rowgroup_bs4___datatables.net_rowgroup_bs4_1.1.1.tgz";
      path = fetchurl {
        name = "datatables.net_rowgroup_bs4___datatables.net_rowgroup_bs4_1.1.1.tgz";
        url  = "https://registry.yarnpkg.com/datatables.net-rowgroup-bs4/-/datatables.net-rowgroup-bs4-1.1.1.tgz";
        sha1 = "57c17e611f8f8ec0aa456fd325bbf466545c230d";
      };
    }

    {
      name = "datatables.net_rowgroup___datatables.net_rowgroup_1.1.1.tgz";
      path = fetchurl {
        name = "datatables.net_rowgroup___datatables.net_rowgroup_1.1.1.tgz";
        url  = "https://registry.yarnpkg.com/datatables.net-rowgroup/-/datatables.net-rowgroup-1.1.1.tgz";
        sha1 = "616531e5fb3c8642f6a51fb14801f8aff50cf90e";
      };
    }

    {
      name = "datatables.net_select_bs4___datatables.net_select_bs4_1.3.1.tgz";
      path = fetchurl {
        name = "datatables.net_select_bs4___datatables.net_select_bs4_1.3.1.tgz";
        url  = "https://registry.yarnpkg.com/datatables.net-select-bs4/-/datatables.net-select-bs4-1.3.1.tgz";
        sha1 = "1c39c7fd5bfb66b5c8402611c2c64fc47e3cfca4";
      };
    }

    {
      name = "datatables.net_select___datatables.net_select_1.3.1.tgz";
      path = fetchurl {
        name = "datatables.net_select___datatables.net_select_1.3.1.tgz";
        url  = "https://registry.yarnpkg.com/datatables.net-select/-/datatables.net-select-1.3.1.tgz";
        sha1 = "ec2c3ad7df2bc9c13c09587d0bfd0ceba52a8bff";
      };
    }

    {
      name = "datatables.net___datatables.net_1.10.16.tgz";
      path = fetchurl {
        name = "datatables.net___datatables.net_1.10.16.tgz";
        url  = "https://registry.yarnpkg.com/datatables.net/-/datatables.net-1.10.16.tgz";
        sha1 = "4b052d1082824261b68eed9d22741b711d3d2469";
      };
    }

    {
      name = "datatables.net___datatables.net_1.10.20.tgz";
      path = fetchurl {
        name = "datatables.net___datatables.net_1.10.20.tgz";
        url  = "https://registry.yarnpkg.com/datatables.net/-/datatables.net-1.10.20.tgz";
        sha1 = "9d65ecc3c83cbe7baa4fa5a053405c8fe42c1350";
      };
    }

    {
      name = "delayed_stream___delayed_stream_1.0.0.tgz";
      path = fetchurl {
        name = "delayed_stream___delayed_stream_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/delayed-stream/-/delayed-stream-1.0.0.tgz";
        sha1 = "df3ae199acadfb7d440aaae0b29e2272b24ec619";
      };
    }

    {
      name = "ecc_jsbn___ecc_jsbn_0.1.2.tgz";
      path = fetchurl {
        name = "ecc_jsbn___ecc_jsbn_0.1.2.tgz";
        url  = "https://registry.yarnpkg.com/ecc-jsbn/-/ecc-jsbn-0.1.2.tgz";
        sha1 = "3a83a904e54353287874c564b7549386849a98c9";
      };
    }

    {
      name = "extend___extend_3.0.2.tgz";
      path = fetchurl {
        name = "extend___extend_3.0.2.tgz";
        url  = "https://registry.yarnpkg.com/extend/-/extend-3.0.2.tgz";
        sha1 = "f8b1136b4071fbd8eb140aff858b1019ec2915fa";
      };
    }

    {
      name = "extsprintf___extsprintf_1.3.0.tgz";
      path = fetchurl {
        name = "extsprintf___extsprintf_1.3.0.tgz";
        url  = "https://registry.yarnpkg.com/extsprintf/-/extsprintf-1.3.0.tgz";
        sha1 = "96918440e3041a7a414f8c52e3c574eb3c3e1e05";
      };
    }

    {
      name = "extsprintf___extsprintf_1.4.0.tgz";
      path = fetchurl {
        name = "extsprintf___extsprintf_1.4.0.tgz";
        url  = "https://registry.yarnpkg.com/extsprintf/-/extsprintf-1.4.0.tgz";
        sha1 = "e2689f8f356fad62cca65a3a91c5df5f9551692f";
      };
    }

    {
      name = "fast_deep_equal___fast_deep_equal_3.1.1.tgz";
      path = fetchurl {
        name = "fast_deep_equal___fast_deep_equal_3.1.1.tgz";
        url  = "https://registry.yarnpkg.com/fast-deep-equal/-/fast-deep-equal-3.1.1.tgz";
        sha1 = "545145077c501491e33b15ec408c294376e94ae4";
      };
    }

    {
      name = "fast_json_stable_stringify___fast_json_stable_stringify_2.1.0.tgz";
      path = fetchurl {
        name = "fast_json_stable_stringify___fast_json_stable_stringify_2.1.0.tgz";
        url  = "https://registry.yarnpkg.com/fast-json-stable-stringify/-/fast-json-stable-stringify-2.1.0.tgz";
        sha1 = "874bf69c6f404c2b5d99c481341399fd55892633";
      };
    }

    {
      name = "font_awesome___font_awesome_4.7.0.tgz";
      path = fetchurl {
        name = "font_awesome___font_awesome_4.7.0.tgz";
        url  = "https://registry.yarnpkg.com/font-awesome/-/font-awesome-4.7.0.tgz";
        sha1 = "8fa8cf0411a1a31afd07b06d2902bb9fc815a133";
      };
    }

    {
      name = "forever_agent___forever_agent_0.6.1.tgz";
      path = fetchurl {
        name = "forever_agent___forever_agent_0.6.1.tgz";
        url  = "https://registry.yarnpkg.com/forever-agent/-/forever-agent-0.6.1.tgz";
        sha1 = "fbc71f0c41adeb37f96c577ad1ed42d8fdacca91";
      };
    }

    {
      name = "form_data___form_data_2.3.3.tgz";
      path = fetchurl {
        name = "form_data___form_data_2.3.3.tgz";
        url  = "https://registry.yarnpkg.com/form-data/-/form-data-2.3.3.tgz";
        sha1 = "dcce52c05f644f298c6a7ab936bd724ceffbf3a6";
      };
    }

    {
      name = "fullcalendar___fullcalendar_3.10.1.tgz";
      path = fetchurl {
        name = "fullcalendar___fullcalendar_3.10.1.tgz";
        url  = "https://registry.yarnpkg.com/fullcalendar/-/fullcalendar-3.10.1.tgz";
        sha1 = "cca3f9a2656a7e978a3f3facb7f35934a91185db";
      };
    }

    {
      name = "get_pixels___get_pixels_3.3.2.tgz";
      path = fetchurl {
        name = "get_pixels___get_pixels_3.3.2.tgz";
        url  = "https://registry.yarnpkg.com/get-pixels/-/get-pixels-3.3.2.tgz";
        sha1 = "3f62fb8811932c69f262bba07cba72b692b4ff03";
      };
    }

    {
      name = "getpass___getpass_0.1.7.tgz";
      path = fetchurl {
        name = "getpass___getpass_0.1.7.tgz";
        url  = "https://registry.yarnpkg.com/getpass/-/getpass-0.1.7.tgz";
        sha1 = "5eff8e3e684d569ae4cb2b1282604e8ba62149fa";
      };
    }

    {
      name = "gettext_translator___gettext_translator_2.1.0.tgz";
      path = fetchurl {
        name = "gettext_translator___gettext_translator_2.1.0.tgz";
        url  = "https://registry.yarnpkg.com/gettext-translator/-/gettext-translator-2.1.0.tgz";
        sha1 = "946047649b7df4ef00522787bb78792667e4de2f";
      };
    }

    {
      name = "gl_mat2___gl_mat2_1.0.1.tgz";
      path = fetchurl {
        name = "gl_mat2___gl_mat2_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/gl-mat2/-/gl-mat2-1.0.1.tgz";
        sha1 = "142505730a5c2fe1e9f25d9ece3d0d6cc2710a30";
      };
    }

    {
      name = "gl_vec2___gl_vec2_1.3.0.tgz";
      path = fetchurl {
        name = "gl_vec2___gl_vec2_1.3.0.tgz";
        url  = "https://registry.yarnpkg.com/gl-vec2/-/gl-vec2-1.3.0.tgz";
        sha1 = "83d472ed46034de8e09cbc857123fb6c81c51199";
      };
    }

    {
      name = "gl_vec3___gl_vec3_1.1.3.tgz";
      path = fetchurl {
        name = "gl_vec3___gl_vec3_1.1.3.tgz";
        url  = "https://registry.yarnpkg.com/gl-vec3/-/gl-vec3-1.1.3.tgz";
        sha1 = "a47c62f918774a06cbed1b65bcd0288ecbb03826";
      };
    }

    {
      name = "har_schema___har_schema_2.0.0.tgz";
      path = fetchurl {
        name = "har_schema___har_schema_2.0.0.tgz";
        url  = "https://registry.yarnpkg.com/har-schema/-/har-schema-2.0.0.tgz";
        sha1 = "a94c2224ebcac04782a0d9035521f24735b7ec92";
      };
    }

    {
      name = "har_validator___har_validator_5.1.3.tgz";
      path = fetchurl {
        name = "har_validator___har_validator_5.1.3.tgz";
        url  = "https://registry.yarnpkg.com/har-validator/-/har-validator-5.1.3.tgz";
        sha1 = "1ef89ebd3e4996557675eed9893110dc350fa080";
      };
    }

    {
      name = "http_signature___http_signature_1.2.0.tgz";
      path = fetchurl {
        name = "http_signature___http_signature_1.2.0.tgz";
        url  = "https://registry.yarnpkg.com/http-signature/-/http-signature-1.2.0.tgz";
        sha1 = "9aecd925114772f3d95b65a60abb8f7c18fbace1";
      };
    }

    {
      name = "iota_array___iota_array_1.0.0.tgz";
      path = fetchurl {
        name = "iota_array___iota_array_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/iota-array/-/iota-array-1.0.0.tgz";
        sha1 = "81ef57fe5d05814cd58c2483632a99c30a0e8087";
      };
    }

    {
      name = "is_buffer___is_buffer_1.1.6.tgz";
      path = fetchurl {
        name = "is_buffer___is_buffer_1.1.6.tgz";
        url  = "https://registry.yarnpkg.com/is-buffer/-/is-buffer-1.1.6.tgz";
        sha1 = "efaa2ea9daa0d7ab2ea13a97b2b8ad51fefbe8be";
      };
    }

    {
      name = "is_typedarray___is_typedarray_1.0.0.tgz";
      path = fetchurl {
        name = "is_typedarray___is_typedarray_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/is-typedarray/-/is-typedarray-1.0.0.tgz";
        sha1 = "e479c80858df0c1b11ddda6940f96011fcda4a9a";
      };
    }

    {
      name = "isstream___isstream_0.1.2.tgz";
      path = fetchurl {
        name = "isstream___isstream_0.1.2.tgz";
        url  = "https://registry.yarnpkg.com/isstream/-/isstream-0.1.2.tgz";
        sha1 = "47e63f7af55afa6f92e1500e690eb8b8529c099a";
      };
    }

    {
      name = "jpeg_js___jpeg_js_0.3.6.tgz";
      path = fetchurl {
        name = "jpeg_js___jpeg_js_0.3.6.tgz";
        url  = "https://registry.yarnpkg.com/jpeg-js/-/jpeg-js-0.3.6.tgz";
        sha1 = "c40382aac9506e7d1f2d856eb02f6c7b2a98b37c";
      };
    }

    {
      name = "jquery_lazy___jquery_lazy_1.7.10.tgz";
      path = fetchurl {
        name = "jquery_lazy___jquery_lazy_1.7.10.tgz";
        url  = "https://registry.yarnpkg.com/jquery-lazy/-/jquery-lazy-1.7.10.tgz";
        sha1 = "aa3d43d058bf1ea89284214f4521f6d9a162d051";
      };
    }

    {
      name = "jquery_serializejson___jquery_serializejson_2.9.0.tgz";
      path = fetchurl {
        name = "jquery_serializejson___jquery_serializejson_2.9.0.tgz";
        url  = "https://registry.yarnpkg.com/jquery-serializejson/-/jquery-serializejson-2.9.0.tgz";
        sha1 = "03e3764e3a4b42c1c5aae9f93d7f19320c5f35a6";
      };
    }

    {
      name = "jquery.easing___jquery.easing_1.4.1.tgz";
      path = fetchurl {
        name = "jquery.easing___jquery.easing_1.4.1.tgz";
        url  = "https://registry.yarnpkg.com/jquery.easing/-/jquery.easing-1.4.1.tgz";
        sha1 = "47982c5836bd758fd48494923c4a101ef6e93e3b";
      };
    }

    {
      name = "jquery___jquery_1.12.4.tgz";
      path = fetchurl {
        name = "jquery___jquery_1.12.4.tgz";
        url  = "https://registry.yarnpkg.com/jquery/-/jquery-1.12.4.tgz";
        sha1 = "01e1dfba290fe73deba77ceeacb0f9ba2fec9e0c";
      };
    }

    {
      name = "jquery___jquery_3.3.1.tgz";
      path = fetchurl {
        name = "jquery___jquery_3.3.1.tgz";
        url  = "https://registry.yarnpkg.com/jquery/-/jquery-3.3.1.tgz";
        sha1 = "958ce29e81c9790f31be7792df5d4d95fc57fbca";
      };
    }

    {
      name = "jquery___jquery_3.4.1.tgz";
      path = fetchurl {
        name = "jquery___jquery_3.4.1.tgz";
        url  = "https://registry.yarnpkg.com/jquery/-/jquery-3.4.1.tgz";
        sha1 = "714f1f8d9dde4bdfa55764ba37ef214630d80ef2";
      };
    }

    {
      name = "jsbn___jsbn_0.1.1.tgz";
      path = fetchurl {
        name = "jsbn___jsbn_0.1.1.tgz";
        url  = "https://registry.yarnpkg.com/jsbn/-/jsbn-0.1.1.tgz";
        sha1 = "a5e654c2e5a2deb5f201d96cefbca80c0ef2f513";
      };
    }

    {
      name = "json_schema_traverse___json_schema_traverse_0.4.1.tgz";
      path = fetchurl {
        name = "json_schema_traverse___json_schema_traverse_0.4.1.tgz";
        url  = "https://registry.yarnpkg.com/json-schema-traverse/-/json-schema-traverse-0.4.1.tgz";
        sha1 = "69f6a87d9513ab8bb8fe63bdb0979c448e684660";
      };
    }

    {
      name = "json_schema___json_schema_0.2.3.tgz";
      path = fetchurl {
        name = "json_schema___json_schema_0.2.3.tgz";
        url  = "https://registry.yarnpkg.com/json-schema/-/json-schema-0.2.3.tgz";
        sha1 = "b480c892e59a2f05954ce727bd3f2a4e882f9e13";
      };
    }

    {
      name = "json_stringify_safe___json_stringify_safe_5.0.1.tgz";
      path = fetchurl {
        name = "json_stringify_safe___json_stringify_safe_5.0.1.tgz";
        url  = "https://registry.yarnpkg.com/json-stringify-safe/-/json-stringify-safe-5.0.1.tgz";
        sha1 = "1296a2d58fd45f19a0f6ce01d65701e2c735b6eb";
      };
    }

    {
      name = "jsprim___jsprim_1.4.1.tgz";
      path = fetchurl {
        name = "jsprim___jsprim_1.4.1.tgz";
        url  = "https://registry.yarnpkg.com/jsprim/-/jsprim-1.4.1.tgz";
        sha1 = "313e66bc1e5cc06e438bc1b7499c2e5c56acb6a2";
      };
    }

    {
      name = "lodash___lodash_4.17.15.tgz";
      path = fetchurl {
        name = "lodash___lodash_4.17.15.tgz";
        url  = "https://registry.yarnpkg.com/lodash/-/lodash-4.17.15.tgz";
        sha1 = "b447f6670a0455bbfeedd11392eff330ea097548";
      };
    }

    {
      name = "mime_db___mime_db_1.43.0.tgz";
      path = fetchurl {
        name = "mime_db___mime_db_1.43.0.tgz";
        url  = "https://registry.yarnpkg.com/mime-db/-/mime-db-1.43.0.tgz";
        sha1 = "0a12e0502650e473d735535050e7c8f4eb4fae58";
      };
    }

    {
      name = "mime_types___mime_types_2.1.26.tgz";
      path = fetchurl {
        name = "mime_types___mime_types_2.1.26.tgz";
        url  = "https://registry.yarnpkg.com/mime-types/-/mime-types-2.1.26.tgz";
        sha1 = "9c921fc09b7e149a65dfdc0da4d20997200b0a06";
      };
    }

    {
      name = "moment_timezone___moment_timezone_0.5.27.tgz";
      path = fetchurl {
        name = "moment_timezone___moment_timezone_0.5.27.tgz";
        url  = "https://registry.yarnpkg.com/moment-timezone/-/moment-timezone-0.5.27.tgz";
        sha1 = "73adec8139b6fe30452e78f210f27b1f346b8877";
      };
    }

    {
      name = "moment___moment_2.24.0.tgz";
      path = fetchurl {
        name = "moment___moment_2.24.0.tgz";
        url  = "https://registry.yarnpkg.com/moment/-/moment-2.24.0.tgz";
        sha1 = "0d055d53f5052aa653c9f6eb68bb5d12bf5c2b5b";
      };
    }

    {
      name = "moment___moment_2.18.1.tgz";
      path = fetchurl {
        name = "moment___moment_2.18.1.tgz";
        url  = "https://registry.yarnpkg.com/moment/-/moment-2.18.1.tgz";
        sha1 = "c36193dd3ce1c2eed2adb7c802dbbc77a81b1c0f";
      };
    }

    {
      name = "ndarray_linear_interpolate___ndarray_linear_interpolate_1.0.0.tgz";
      path = fetchurl {
        name = "ndarray_linear_interpolate___ndarray_linear_interpolate_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/ndarray-linear-interpolate/-/ndarray-linear-interpolate-1.0.0.tgz";
        sha1 = "78bc92b85b9abc15b6e67ee65828f9e2137ae72b";
      };
    }

    {
      name = "ndarray_pack___ndarray_pack_1.2.1.tgz";
      path = fetchurl {
        name = "ndarray_pack___ndarray_pack_1.2.1.tgz";
        url  = "https://registry.yarnpkg.com/ndarray-pack/-/ndarray-pack-1.2.1.tgz";
        sha1 = "8caebeaaa24d5ecf70ff86020637977da8ee585a";
      };
    }

    {
      name = "ndarray___ndarray_1.0.19.tgz";
      path = fetchurl {
        name = "ndarray___ndarray_1.0.19.tgz";
        url  = "https://registry.yarnpkg.com/ndarray/-/ndarray-1.0.19.tgz";
        sha1 = "6785b5f5dfa58b83e31ae5b2a058cfd1ab3f694e";
      };
    }

    {
      name = "node_bitmap___node_bitmap_0.0.1.tgz";
      path = fetchurl {
        name = "node_bitmap___node_bitmap_0.0.1.tgz";
        url  = "https://registry.yarnpkg.com/node-bitmap/-/node-bitmap-0.0.1.tgz";
        sha1 = "180eac7003e0c707618ef31368f62f84b2a69091";
      };
    }

    {
      name = "nosleep.js___nosleep.js_0.9.0.tgz";
      path = fetchurl {
        name = "nosleep.js___nosleep.js_0.9.0.tgz";
        url  = "https://registry.yarnpkg.com/nosleep.js/-/nosleep.js-0.9.0.tgz";
        sha1 = "0f1371b81dc182e3b6bbdb837e880f16db9d7163";
      };
    }

    {
      name = "oauth_sign___oauth_sign_0.9.0.tgz";
      path = fetchurl {
        name = "oauth_sign___oauth_sign_0.9.0.tgz";
        url  = "https://registry.yarnpkg.com/oauth-sign/-/oauth-sign-0.9.0.tgz";
        sha1 = "47a7b016baa68b5fa0ecf3dee08a85c679ac6455";
      };
    }

    {
      name = "omggif___omggif_1.0.10.tgz";
      path = fetchurl {
        name = "omggif___omggif_1.0.10.tgz";
        url  = "https://registry.yarnpkg.com/omggif/-/omggif-1.0.10.tgz";
        sha1 = "ddaaf90d4a42f532e9e7cb3a95ecdd47f17c7b19";
      };
    }

    {
      name = "parse_data_uri___parse_data_uri_0.2.0.tgz";
      path = fetchurl {
        name = "parse_data_uri___parse_data_uri_0.2.0.tgz";
        url  = "https://registry.yarnpkg.com/parse-data-uri/-/parse-data-uri-0.2.0.tgz";
        sha1 = "bf04d851dd5c87b0ab238e5d01ace494b604b4c9";
      };
    }

    {
      name = "performance_now___performance_now_2.1.0.tgz";
      path = fetchurl {
        name = "performance_now___performance_now_2.1.0.tgz";
        url  = "https://registry.yarnpkg.com/performance-now/-/performance-now-2.1.0.tgz";
        sha1 = "6309f4e0e5fa913ec1c69307ae364b4b377c9e7b";
      };
    }

    {
      name = "pngjs___pngjs_3.4.0.tgz";
      path = fetchurl {
        name = "pngjs___pngjs_3.4.0.tgz";
        url  = "https://registry.yarnpkg.com/pngjs/-/pngjs-3.4.0.tgz";
        sha1 = "99ca7d725965fb655814eaf65f38f12bbdbf555f";
      };
    }

    {
      name = "popper.js___popper.js_1.16.1.tgz";
      path = fetchurl {
        name = "popper.js___popper.js_1.16.1.tgz";
        url  = "https://registry.yarnpkg.com/popper.js/-/popper.js-1.16.1.tgz";
        sha1 = "2a223cb3dc7b6213d740e40372be40de43e65b1b";
      };
    }

    {
      name = "psl___psl_1.7.0.tgz";
      path = fetchurl {
        name = "psl___psl_1.7.0.tgz";
        url  = "https://registry.yarnpkg.com/psl/-/psl-1.7.0.tgz";
        sha1 = "f1c4c47a8ef97167dea5d6bbf4816d736e884a3c";
      };
    }

    {
      name = "punycode___punycode_1.4.1.tgz";
      path = fetchurl {
        name = "punycode___punycode_1.4.1.tgz";
        url  = "https://registry.yarnpkg.com/punycode/-/punycode-1.4.1.tgz";
        sha1 = "c0d5a63b2718800ad8e1eb0fa5269c84dd41845e";
      };
    }

    {
      name = "punycode___punycode_2.1.1.tgz";
      path = fetchurl {
        name = "punycode___punycode_2.1.1.tgz";
        url  = "https://registry.yarnpkg.com/punycode/-/punycode-2.1.1.tgz";
        sha1 = "b58b010ac40c22c5657616c8d2c2c02c7bf479ec";
      };
    }

    {
      name = "qs___qs_6.5.2.tgz";
      path = fetchurl {
        name = "qs___qs_6.5.2.tgz";
        url  = "https://registry.yarnpkg.com/qs/-/qs-6.5.2.tgz";
        sha1 = "cb3ae806e8740444584ef154ce8ee98d403f3e36";
      };
    }

    {
      name = "quagga___quagga_0.12.1.tgz";
      path = fetchurl {
        name = "quagga___quagga_0.12.1.tgz";
        url  = "https://registry.yarnpkg.com/quagga/-/quagga-0.12.1.tgz";
        sha1 = "6f48c56ed992dc5fdeb90dbee7069c2e1cdde8b7";
      };
    }

    {
      name = "request___request_2.88.0.tgz";
      path = fetchurl {
        name = "request___request_2.88.0.tgz";
        url  = "https://registry.yarnpkg.com/request/-/request-2.88.0.tgz";
        sha1 = "9c2fca4f7d35b592efe57c7f0a55e81052124fef";
      };
    }

    {
      name = "safe_buffer___safe_buffer_5.2.0.tgz";
      path = fetchurl {
        name = "safe_buffer___safe_buffer_5.2.0.tgz";
        url  = "https://registry.yarnpkg.com/safe-buffer/-/safe-buffer-5.2.0.tgz";
        sha1 = "b74daec49b1148f88c64b68d49b1e815c1f2f519";
      };
    }

    {
      name = "safer_buffer___safer_buffer_2.1.2.tgz";
      path = fetchurl {
        name = "safer_buffer___safer_buffer_2.1.2.tgz";
        url  = "https://registry.yarnpkg.com/safer-buffer/-/safer-buffer-2.1.2.tgz";
        sha1 = "44fa161b0187b9549dd84bb91802f9bd8385cd6a";
      };
    }

    {
      name = "sprintf_js___sprintf_js_1.1.2.tgz";
      path = fetchurl {
        name = "sprintf_js___sprintf_js_1.1.2.tgz";
        url  = "https://registry.yarnpkg.com/sprintf-js/-/sprintf-js-1.1.2.tgz";
        sha1 = "da1765262bf8c0f571749f2ad6c26300207ae673";
      };
    }

    {
      name = "sshpk___sshpk_1.16.1.tgz";
      path = fetchurl {
        name = "sshpk___sshpk_1.16.1.tgz";
        url  = "https://registry.yarnpkg.com/sshpk/-/sshpk-1.16.1.tgz";
        sha1 = "fb661c0bef29b39db40769ee39fa70093d6f6877";
      };
    }

    {
      name = "startbootstrap_sb_admin___startbootstrap_sb_admin_4.0.0.tgz";
      path = fetchurl {
        name = "startbootstrap_sb_admin___startbootstrap_sb_admin_4.0.0.tgz";
        url  = "https://registry.yarnpkg.com/startbootstrap-sb-admin/-/startbootstrap-sb-admin-4.0.0.tgz";
        sha1 = "cf141a260d031b36bdc013c68200a1c1ea6c9881";
      };
    }

    {
      name = "summernote___summernote_0.8.15.tgz";
      path = fetchurl {
        name = "summernote___summernote_0.8.15.tgz";
        url  = "https://registry.yarnpkg.com/summernote/-/summernote-0.8.15.tgz";
        sha1 = "f783f23b2c1f85c1609855ad37205595147a3c39";
      };
    }

    {
      name = "swagger_ui_dist___swagger_ui_dist_3.25.0.tgz";
      path = fetchurl {
        name = "swagger_ui_dist___swagger_ui_dist_3.25.0.tgz";
        url  = "https://registry.yarnpkg.com/swagger-ui-dist/-/swagger-ui-dist-3.25.0.tgz";
        sha1 = "90279cdcc56e591fcfbe7b5240a9d653b989336d";
      };
    }

    {
      name = "https___github.com_berrnd_tempusdominus_bootstrap_4_archive_2cf725fed9216cb77a298e5ce46762bfe979eaa0.tar.gz";
      path = fetchurl {
        name = "https___github.com_berrnd_tempusdominus_bootstrap_4_archive_2cf725fed9216cb77a298e5ce46762bfe979eaa0.tar.gz";
        url  = "https://github.com/berrnd/tempusdominus-bootstrap-4/archive/2cf725fed9216cb77a298e5ce46762bfe979eaa0.tar.gz";
        sha1 = "q9z5vwgs4p8ijf7asxxrfyb7rpis3hqm";
      };
    }

    {
      name = "through___through_2.3.8.tgz";
      path = fetchurl {
        name = "through___through_2.3.8.tgz";
        url  = "https://registry.yarnpkg.com/through/-/through-2.3.8.tgz";
        sha1 = "0dd4c9ffaabc357960b1b724115d7e0e86a2e1f5";
      };
    }

    {
      name = "timeago___timeago_1.6.7.tgz";
      path = fetchurl {
        name = "timeago___timeago_1.6.7.tgz";
        url  = "https://registry.yarnpkg.com/timeago/-/timeago-1.6.7.tgz";
        sha1 = "afd467c29a911e697fc22a81888c7c3022783cb5";
      };
    }

    {
      name = "toastr___toastr_2.1.4.tgz";
      path = fetchurl {
        name = "toastr___toastr_2.1.4.tgz";
        url  = "https://registry.yarnpkg.com/toastr/-/toastr-2.1.4.tgz";
        sha1 = "8b43be64fb9d0c414871446f2db8e8ca4e95f181";
      };
    }

    {
      name = "tough_cookie___tough_cookie_2.4.3.tgz";
      path = fetchurl {
        name = "tough_cookie___tough_cookie_2.4.3.tgz";
        url  = "https://registry.yarnpkg.com/tough-cookie/-/tough-cookie-2.4.3.tgz";
        sha1 = "53f36da3f47783b0925afa06ff9f3b165280f781";
      };
    }

    {
      name = "tunnel_agent___tunnel_agent_0.6.0.tgz";
      path = fetchurl {
        name = "tunnel_agent___tunnel_agent_0.6.0.tgz";
        url  = "https://registry.yarnpkg.com/tunnel-agent/-/tunnel-agent-0.6.0.tgz";
        sha1 = "27a5dea06b36b04a0a9966774b290868f0fc40fd";
      };
    }

    {
      name = "tweetnacl___tweetnacl_0.14.5.tgz";
      path = fetchurl {
        name = "tweetnacl___tweetnacl_0.14.5.tgz";
        url  = "https://registry.yarnpkg.com/tweetnacl/-/tweetnacl-0.14.5.tgz";
        sha1 = "5ae68177f192d4456269d108afa93ff8743f4f64";
      };
    }

    {
      name = "uniq___uniq_1.0.1.tgz";
      path = fetchurl {
        name = "uniq___uniq_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/uniq/-/uniq-1.0.1.tgz";
        sha1 = "b31c5ae8254844a3a8281541ce2b04b865a734ff";
      };
    }

    {
      name = "uri_js___uri_js_4.2.2.tgz";
      path = fetchurl {
        name = "uri_js___uri_js_4.2.2.tgz";
        url  = "https://registry.yarnpkg.com/uri-js/-/uri-js-4.2.2.tgz";
        sha1 = "94c540e1ff772956e2299507c010aea6c8838eb0";
      };
    }

    {
      name = "uuid___uuid_3.4.0.tgz";
      path = fetchurl {
        name = "uuid___uuid_3.4.0.tgz";
        url  = "https://registry.yarnpkg.com/uuid/-/uuid-3.4.0.tgz";
        sha1 = "b23e4358afa8a202fe7a100af1f5f883f02007ee";
      };
    }

    {
      name = "verror___verror_1.10.0.tgz";
      path = fetchurl {
        name = "verror___verror_1.10.0.tgz";
        url  = "https://registry.yarnpkg.com/verror/-/verror-1.10.0.tgz";
        sha1 = "3a105ca17053af55d6e270c1f8288682e18da400";
      };
    }
  ];
}
