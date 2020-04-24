# Generated with composer2nix and adapted to return only the list of
# packages
{ composerEnv, fetchurl }:
{
  packages = {
    "doctrine/inflector" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "doctrine-inflector-ec3a55242203ffa6a4b27c58176da97ff0a7aec1";
        src = fetchurl {
          url = https://api.github.com/repos/doctrine/inflector/zipball/ec3a55242203ffa6a4b27c58176da97ff0a7aec1;
          sha256 = "18i6zyd5bh5zazgqr3c9bwi7s5vhm9wpnn2hd8vp8vgdp9x7f4hb";
        };
      };
    };
    "eluceo/ical" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "eluceo-ical-97da0d94c9716e65c141066a2d96aa098379721b";
        src = fetchurl {
          url = https://api.github.com/repos/markuspoerschke/iCal/zipball/97da0d94c9716e65c141066a2d96aa098379721b;
          sha256 = "195ajn30fdqxvvj03m4aa20yxf3li7w4zyl54r2f9rbwbibljia6";
        };
      };
    };
    "erusev/parsedown" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "erusev-parsedown-cb17b6477dfff935958ba01325f2e8a2bfa6dab3";
        src = fetchurl {
          url = https://api.github.com/repos/erusev/parsedown/zipball/cb17b6477dfff935958ba01325f2e8a2bfa6dab3;
          sha256 = "1iil9v8g03m5vpxxg3a5qb2sxd1cs5c4p5i0k00cqjnjsxfrazxd";
        };
      };
    };
    "fig/http-message-util" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "fig-http-message-util-3242caa9da7221a304b8f84eb9eaddae0a7cf422";
        src = fetchurl {
          url = https://api.github.com/repos/php-fig/http-message-util/zipball/3242caa9da7221a304b8f84eb9eaddae0a7cf422;
          sha256 = "1cjbbsb8z4g340aqg8wrrc4vd9b7dksclqb7sh0xlmigjihn4shk";
        };
      };
    };
    "gettext/gettext" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "gettext-gettext-e474f872f2c8636cf53fd283ec4ce1218f3d236a";
        src = fetchurl {
          url = https://api.github.com/repos/php-gettext/Gettext/zipball/e474f872f2c8636cf53fd283ec4ce1218f3d236a;
          sha256 = "0plr9jzmhk2aw51qwhql2f2clak667qqlbxwx0q2g419w1ki1aky";
        };
      };
    };
    "gettext/languages" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "gettext-languages-38ea0482f649e0802e475f0ed19fa993bcb7a618";
        src = fetchurl {
          url = https://api.github.com/repos/php-gettext/Languages/zipball/38ea0482f649e0802e475f0ed19fa993bcb7a618;
          sha256 = "1f81ynhlki5h99crp6c1myyhsqhc74rjlxmmxkbmi986pbxr16m0";
        };
      };
    };
    "gumlet/php-image-resize" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "gumlet-php-image-resize-06339a9c1b167acd58173db226f57957a6617547";
        src = fetchurl {
          url = https://api.github.com/repos/gumlet/php-image-resize/zipball/06339a9c1b167acd58173db226f57957a6617547;
          sha256 = "1nn66n85n9cm8brdvw3lq6g36jl0ylv60dkzpjm8nsn83nqn9ns0";
        };
      };
    };
    "illuminate/container" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-container-b42e5ef939144b77f78130918da0ce2d9ee16574";
        src = fetchurl {
          url = https://api.github.com/repos/illuminate/container/zipball/b42e5ef939144b77f78130918da0ce2d9ee16574;
          sha256 = "1szb8l69ap7agc8pqm3apqjspdgnhhb7xbrf6g77w9nwj4bdc9ix";
        };
      };
    };
    "illuminate/contracts" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-contracts-00fc6afee788fa07c311b0650ad276585f8aef96";
        src = fetchurl {
          url = https://api.github.com/repos/illuminate/contracts/zipball/00fc6afee788fa07c311b0650ad276585f8aef96;
          sha256 = "1g7dlcjbgypfiag9sn3jaxhfd4qivsjgfh2kivazcg62n3sz8zca";
        };
      };
    };
    "illuminate/events" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-events-a85d7c273bc4e3357000c5fc4812374598515de3";
        src = fetchurl {
          url = https://api.github.com/repos/illuminate/events/zipball/a85d7c273bc4e3357000c5fc4812374598515de3;
          sha256 = "1fdcabsqh43kzhi2n5703jiagmggchzdsjvi0ckc377nv6qkk5ym";
        };
      };
    };
    "illuminate/filesystem" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-filesystem-494ba903402d64ec49c8d869ab61791db34b2288";
        src = fetchurl {
          url = https://api.github.com/repos/illuminate/filesystem/zipball/494ba903402d64ec49c8d869ab61791db34b2288;
          sha256 = "1ajj58125pzb746ad5pdkb4vn2ckg382x0c939r3jwv45913js3f";
        };
      };
    };
    "illuminate/support" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-support-df4af6a32908f1d89d74348624b57e3233eea247";
        src = fetchurl {
          url = https://api.github.com/repos/illuminate/support/zipball/df4af6a32908f1d89d74348624b57e3233eea247;
          sha256 = "0n5kj0vbbakhzhkh0dfmpn4iqakkh783h0f2kl20wb9j6i6ywgjm";
        };
      };
    };
    "illuminate/view" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "illuminate-view-c859919bc3be97a3f114377d5d812f047b8ea90d";
        src = fetchurl {
          url = https://api.github.com/repos/illuminate/view/zipball/c859919bc3be97a3f114377d5d812f047b8ea90d;
          sha256 = "02l5wwbn6vhxl3af9avjdqwhj0wacigr6iwn9370pzw7cknlrvfm";
        };
      };
    };
    "jeremeamia/superclosure" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "jeremeamia-superclosure-5707d5821b30b9a07acfb4d76949784aaa0e9ce9";
        src = fetchurl {
          url = https://api.github.com/repos/jeremeamia/super_closure/zipball/5707d5821b30b9a07acfb4d76949784aaa0e9ce9;
          sha256 = "0jhj9s4fkv5lqpjs0r80czq2s8wv4i2ilaav9pkbwrpk17q9dh0c";
        };
      };
    };
    "morris/lessql" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "morris-lessql-f4150517f6492a761ed1ccb8dd180769e1f89e54";
        src = fetchurl {
          url = https://api.github.com/repos/morris/lessql/zipball/f4150517f6492a761ed1ccb8dd180769e1f89e54;
          sha256 = "1fcznaf0lijq3nd56iwjwkwc4j2v1li9vxp9hpghkc84ic0pf6c4";
        };
      };
    };
    "neomerx/cors-psr7" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "neomerx-cors-psr7-2556e2013f16a55532c95928455257d5b6bbc6e2";
        src = fetchurl {
          url = https://api.github.com/repos/neomerx/cors-psr7/zipball/2556e2013f16a55532c95928455257d5b6bbc6e2;
          sha256 = "0x64zvqjwaz2hkjl9vw29y29sny0z35c77yy8676scqlabwr98py";
        };
      };
    };
    "nesbot/carbon" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "nesbot-carbon-bbc0ab53f41a4c6f223c18efcdbd9bc725eb5d2d";
        src = fetchurl {
          url = https://api.github.com/repos/briannesbitt/Carbon/zipball/bbc0ab53f41a4c6f223c18efcdbd9bc725eb5d2d;
          sha256 = "0acyfvnsqy082390ijhi4mrlllgsskax3yj7bjrf97l6jlnci3g0";
        };
      };
    };
    "nikic/fast-route" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "nikic-fast-route-181d480e08d9476e61381e04a71b34dc0432e812";
        src = fetchurl {
          url = https://api.github.com/repos/nikic/FastRoute/zipball/181d480e08d9476e61381e04a71b34dc0432e812;
          sha256 = "0sjqivm0gp6d6nal58n4r5wzyi21r4hdzn4v31ydgjgni7877p4i";
        };
      };
    };
    "nikic/php-parser" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "nikic-php-parser-9a9981c347c5c49d6dfe5cf826bb882b824080dc";
        src = fetchurl {
          url = https://api.github.com/repos/nikic/PHP-Parser/zipball/9a9981c347c5c49d6dfe5cf826bb882b824080dc;
          sha256 = "1qk8g51sxh8vm9b2w98383045ig20g71p67izw7vrsazqljmxxyb";
        };
      };
    };
    "philo/laravel-blade" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "philo-laravel-blade-3f0ce2ee198604c53c25188110e6d7b5e887527a";
        src = fetchurl {
          url = https://api.github.com/repos/PhiloNL/Laravel-Blade/zipball/3f0ce2ee198604c53c25188110e6d7b5e887527a;
          sha256 = "03gpyga86qlc9770vsvymh3qbj22sy52k0f3r4lwgy0h2sbd3664";
        };
      };
    };
    "php-di/invoker" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "php-di-invoker-540c27c86f663e20fe39a24cd72fa76cdb21d41a";
        src = fetchurl {
          url = https://api.github.com/repos/PHP-DI/Invoker/zipball/540c27c86f663e20fe39a24cd72fa76cdb21d41a;
          sha256 = "0gchfy3ail4bps0hdwjj9ncgq354kfdk32y4wcrm61vnl71j59v6";
        };
      };
    };
    "php-di/php-di" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "php-di-php-di-9bdcc2f41f5fb700ddd01bc4fa8d5bd7b3f94620";
        src = fetchurl {
          url = https://api.github.com/repos/PHP-DI/PHP-DI/zipball/9bdcc2f41f5fb700ddd01bc4fa8d5bd7b3f94620;
          sha256 = "0ykzw0kx9f3f0qjqlvzmdds1cfnn7g5m3kns2k4p13gdrjn1pdnx";
        };
      };
    };
    "php-di/phpdoc-reader" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "php-di-phpdoc-reader-15678f7451c020226807f520efb867ad26fbbfcf";
        src = fetchurl {
          url = https://api.github.com/repos/PHP-DI/PhpDocReader/zipball/15678f7451c020226807f520efb867ad26fbbfcf;
          sha256 = "09yi52spm0a7ccl40smnkw23wg3xj1r06nqxcslbya2axw9ziyh9";
        };
      };
    };
    "psr/container" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-container-b7ce3b176482dbbc1245ebf52b181af44c2cf55f";
        src = fetchurl {
          url = https://api.github.com/repos/php-fig/container/zipball/b7ce3b176482dbbc1245ebf52b181af44c2cf55f;
          sha256 = "0rkz64vgwb0gfi09klvgay4qnw993l1dc03vyip7d7m2zxi6cy4j";
        };
      };
    };
    "psr/http-factory" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-http-factory-12ac7fcd07e5b077433f5f2bee95b3a771bf61be";
        src = fetchurl {
          url = https://api.github.com/repos/php-fig/http-factory/zipball/12ac7fcd07e5b077433f5f2bee95b3a771bf61be;
          sha256 = "0inbnqpc5bfhbbda9dwazsrw9xscfnc8rdx82q1qm3r446mc1vds";
        };
      };
    };
    "psr/http-message" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-http-message-f6561bf28d520154e4b0ec72be95418abe6d9363";
        src = fetchurl {
          url = https://api.github.com/repos/php-fig/http-message/zipball/f6561bf28d520154e4b0ec72be95418abe6d9363;
          sha256 = "195dd67hva9bmr52iadr4kyp2gw2f5l51lplfiay2pv6l9y4cf45";
        };
      };
    };
    "psr/http-server-handler" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-http-server-handler-aff2f80e33b7f026ec96bb42f63242dc50ffcae7";
        src = fetchurl {
          url = https://api.github.com/repos/php-fig/http-server-handler/zipball/aff2f80e33b7f026ec96bb42f63242dc50ffcae7;
          sha256 = "0sfz1j9lxirsld0zm0bqqmxf52krjn982w3fq9n27q7mpjd33y4x";
        };
      };
    };
    "psr/http-server-middleware" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-http-server-middleware-2296f45510945530b9dceb8bcedb5cb84d40c5f5";
        src = fetchurl {
          url = https://api.github.com/repos/php-fig/http-server-middleware/zipball/2296f45510945530b9dceb8bcedb5cb84d40c5f5;
          sha256 = "1r92xj2hybnxcnamxqklk5kivkgy0bi34hhsh00dnwn9wmf3s0gj";
        };
      };
    };
    "psr/log" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-log-446d54b4cb6bf489fc9d75f55843658e6f25d801";
        src = fetchurl {
          url = https://api.github.com/repos/php-fig/log/zipball/446d54b4cb6bf489fc9d75f55843658e6f25d801;
          sha256 = "04baykaig5nmxsrwmzmcwbs60ixilcx1n0r9wdcnvxnnj64cf2kr";
        };
      };
    };
    "psr/simple-cache" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "psr-simple-cache-408d5eafb83c57f6365a3ca330ff23aa4a5fa39b";
        src = fetchurl {
          url = https://api.github.com/repos/php-fig/simple-cache/zipball/408d5eafb83c57f6365a3ca330ff23aa4a5fa39b;
          sha256 = "1djgzclkamjxi9jy4m9ggfzgq1vqxaga2ip7l3cj88p7rwkzjxgw";
        };
      };
    };
    "ralouphie/getallheaders" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "ralouphie-getallheaders-120b605dfeb996808c31b6477290a714d356e822";
        src = fetchurl {
          url = https://api.github.com/repos/ralouphie/getallheaders/zipball/120b605dfeb996808c31b6477290a714d356e822;
          sha256 = "1bv7ndkkankrqlr2b4kw7qp3fl0dxi6bp26bnim6dnlhavd6a0gg";
        };
      };
    };
    "rubellum/slim-blade-view" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "rubellum-slim-blade-view-9cdea69285acbf712463b38a9bb0b5ce23c4c98c";
        src = fetchurl {
          url = https://api.github.com/repos/rubellum/Slim-Blade-View/zipball/9cdea69285acbf712463b38a9bb0b5ce23c4c98c;
          sha256 = "1774l8hiy7q9xjpfpps60xiphnlghna9qz9cszw9iqbkz90dl405";
        };
      };
    };
    "slim/http" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "slim-http-c2e67ac1680207aa7863fd4721530b01f3436b2e";
        src = fetchurl {
          url = https://api.github.com/repos/slimphp/Slim-Http/zipball/c2e67ac1680207aa7863fd4721530b01f3436b2e;
          sha256 = "1sp48gapv19kal2i2j1w335qk171h254ihy3ivp7js9b1ybyy4rz";
        };
      };
    };
    "slim/psr7" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "slim-psr7-7ca5b5d96687b7c563238715cc80b12675d8b895";
        src = fetchurl {
          url = https://api.github.com/repos/slimphp/Slim-Psr7/zipball/7ca5b5d96687b7c563238715cc80b12675d8b895;
          sha256 = "1r2krm85li2zkdh4w4kii5cpwpca169i0i66pylzyjbz6rg32zsf";
        };
      };
    };
    "slim/slim" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "slim-slim-207acac048652a35d4762a737d59e317aedc02df";
        src = fetchurl {
          url = https://api.github.com/repos/slimphp/Slim/zipball/207acac048652a35d4762a737d59e317aedc02df;
          sha256 = "0q7rxrmyilz0i90nkwbf64j5a892ky35l1f9a6l09xyrda1hbhdc";
        };
      };
    };
    "symfony/debug" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-debug-a980d87a659648980d89193fd8b7a7ca89d97d21";
        src = fetchurl {
          url = https://api.github.com/repos/symfony/debug/zipball/a980d87a659648980d89193fd8b7a7ca89d97d21;
          sha256 = "1qlmb4pvrapyhcxz4lk0jswhk1ki0634k3vgn2vs6vsf70fd4sqd";
        };
      };
    };
    "symfony/finder" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-finder-ea69c129aed9fdeca781d4b77eb20b62cf5d5357";
        src = fetchurl {
          url = https://api.github.com/repos/symfony/finder/zipball/ea69c129aed9fdeca781d4b77eb20b62cf5d5357;
          sha256 = "1k57fzn92pxvbcvvb9z2j7iibi2y4pg1gn8fcqrn678hdnpg9vl7";
        };
      };
    };
    "symfony/polyfill-mbstring" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-mbstring-34094cfa9abe1f0f14f48f490772db7a775559f2";
        src = fetchurl {
          url = https://api.github.com/repos/symfony/polyfill-mbstring/zipball/34094cfa9abe1f0f14f48f490772db7a775559f2;
          sha256 = "1lnrmk1yrv9cbs7kb2cwfgqzq1hwl135bhbkr6yyayfk67zs3rqa";
        };
      };
    };
    "symfony/polyfill-php56" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-php56-16ec91cb06998b609501b55b7177b7d7c02badb3";
        src = fetchurl {
          url = https://api.github.com/repos/symfony/polyfill-php56/zipball/16ec91cb06998b609501b55b7177b7d7c02badb3;
          sha256 = "0j0fi8lwqncvvwm132c88d87csx2cyblxvj7bcrdivjvkv1ymqky";
        };
      };
    };
    "symfony/polyfill-util" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-util-ba3cfcea6d0192cae46c62041f61cbb704b526d3";
        src = fetchurl {
          url = https://api.github.com/repos/symfony/polyfill-util/zipball/ba3cfcea6d0192cae46c62041f61cbb704b526d3;
          sha256 = "0q18h0920jp3js9lnvzw7gnyi1nsi8035ddzz8nh7wvl6frwr703";
        };
      };
    };
    "symfony/translation" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-translation-e9b93f42a1fd6aec6a0872d59ee5c8219a7d584b";
        src = fetchurl {
          url = https://api.github.com/repos/symfony/translation/zipball/e9b93f42a1fd6aec6a0872d59ee5c8219a7d584b;
          sha256 = "1r83h9061pgakkgqxqn4j65bimgbx854pipangb15cg1ssgc83dl";
        };
      };
    };
    "symfony/translation-contracts" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-translation-contracts-8cc682ac458d75557203b2f2f14b0b92e1c744ed";
        src = fetchurl {
          url = https://api.github.com/repos/symfony/translation-contracts/zipball/8cc682ac458d75557203b2f2f14b0b92e1c744ed;
          sha256 = "10ra2n1qgzkb31sbn0cv1y425i80qk9v59yhh7x2ipjxw1lpv714";
        };
      };
    };
    "tuupola/callable-handler" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "tuupola-callable-handler-8b9d87f88056d4234af317d65612d7b6307a747a";
        src = fetchurl {
          url = https://api.github.com/repos/tuupola/callable-handler/zipball/8b9d87f88056d4234af317d65612d7b6307a747a;
          sha256 = "0ahp4yvyr31spvwd00fk991cnsdzgbw6kgvfqf89b4nb49adjwza";
        };
      };
    };
    "tuupola/cors-middleware" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "tuupola-cors-middleware-a043f4f52b902ee8902f95d28aae05013a7180fc";
        src = fetchurl {
          url = https://api.github.com/repos/tuupola/cors-middleware/zipball/a043f4f52b902ee8902f95d28aae05013a7180fc;
          sha256 = "0zw4xg4c165x0xkdqyxqw9q2ic2d8y235kk3mwijdxhv6f9f2m3g";
        };
      };
    };
    "tuupola/http-factory" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "tuupola-http-factory-5fbde4c65a10d09a85652684a6e569542265a749";
        src = fetchurl {
          url = https://api.github.com/repos/tuupola/http-factory/zipball/5fbde4c65a10d09a85652684a6e569542265a749;
          sha256 = "0r0skw1ywy17l1km6jrx46gd981i685y3rb45v0rrlgpljnm8i1n";
        };
      };
    };
  };
}
