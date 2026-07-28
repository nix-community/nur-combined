{ config, pkgs, inputs, vaculib, lib, ... }:
let
  inherit (pkgs) fetchurl linkFarmFromDrvs;
  cfg = config.services.minecraft-servers;
in
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
  environment.persistence."/persistent".directories = [
    {
      directory = cfg.dataDir;
      user = cfg.user;
      group = cfg.group;
      mode = vaculib.accessModeStr { user = "all"; };
    }
  ];
  systemd.services.minecraft-server-vanilla-perf = {
    unitConfig = {
      StartLimitBurst = lib.mkForce "";
      StartLimitIntervalSec = lib.mkForce 0;
    };
    serviceConfig.Restart = lib.mkForce "no";
  };
  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;

    servers.vanilla-perf = {
      enable = true;
      # Fabric server jar for your MC version
      package = inputs.nix-minecraft.legacyPackages.${pkgs.stdenv.hostPlatform.system}.fabricServers.fabric-26_2.override {
        jre_headless = pkgs.openjdk25_headless;
      };
      jvmOpts = "-Xms4G -Xmx4G";

      serverProperties = {
        server-port = 25565;
        motd = "what jibberish do i put here";
        max-players = 20;
        white-list = true;
        enforce-whitelist = true;
      };
      whitelist = {
        shelvacu = "9aeca820-51de-432d-9b51-e9c0b05c91e6";
        java_coffee = "3371c03a-d29b-480a-a669-6c0e1d49af94";
      };

      symlinks = {
        mods = linkFarmFromDrvs "mods" (
          builtins.attrValues {
            # Each mod: fetchurl from Modrinth CDN with a sha512.
            # Get the URL + hash via the helper:
            #   nix run github:Infinidoge/nix-minecraft#nix-modrinth-prefetch -- <version-id>
            # for id in "${ids[@]}";do printf '%s ' "$id"; declare version_id=""; version_id="$(curl --no-progress-meter 'https://api.modrinth.com/v2/project/'"$id"'/version?include_changelog=false' | jq '. | map(select( [(.game_versions | any(. == "26.2")), (.loaders | any(. == "fabric"))] | all )) | .[0].id' -r)"; declare nix_code=""; nix_code="$(nix run github:Infinidoge/nix-minecraft#nix-modrinth-prefetch -- "$version_id")"; echo "$id = $nix_code;"; done
            # ferrite-core
            # lithium
            # modernfix
            # krypton
            # clumps
            # c2me-fabric
            # debugify
            # packet-fixer
            # chunky
            # vmp-fabric
            # servercore
            # scalablelux
            # alternate-current
            # carpet
            # neruina
            # structure-layout-optimizer
            # modernfix-mvus
            # zfastnoise
            # carpet-tis-addition
            # quick-pack
            # carpet-extra
            # async
            # smooth-boot
            # disable-portal-checks
            # async-locator-refined
            # adaptiveview
            # pyre
            ferrite-core = fetchurl {
              url = "https://cdn.modrinth.com/data/uXXizFIs/versions/d5ddUdiB/ferritecore-9.0.0-fabric.jar";
              sha512 = "d81fa97e11784c19d42f89c2f433831d007603dd7193cee45fa177e4a6a9c52b384b198586e04a0f7f63cd996fed713322578bde9a8db57e1188854ae5cbe584";
            };
            lithium = fetchurl {
              url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/UPNexAfy/lithium-fabric-0.25.2%2Bmc26.2.jar";
              sha512 = "db676376c05b7e912cdae5aad9e51f125adc1554ae2b204599ccb598751921aedbac98e97b9cba0333b6b52488c6b75c915a7dbd50436f97800387fe1aad1c50";
            };
            krypton = fetchurl {
              url = "https://cdn.modrinth.com/data/fQEb0iXm/versions/5WeL0Nkz/krypton-0.3.1.jar";
              sha512 = "b8d9af34cd0050493afb8a6232cb8f785daa9d8887b7045f6e6a53c6bb9b5ffc4318fd9b0347a940eacfeba4773f10cb80ae0be1e79ce4c1888f96eda21e564e";
            };
            clumps = fetchurl {
              url = "https://cdn.modrinth.com/data/Wnxd13zP/versions/dEMopoOJ/Clumps-fabric-26.2-26.2.1.jar";
              sha512 = "a57044f0c9a07b19cd38b85528fd6b3958600c3ed1568d8a7ce32a7a473570362861ef433be4f23b02a43c05d658e9a5a71f9218fbdb963ae76a1714a0439fbe";
            };
            c2me-fabric = fetchurl {
              url = "https://cdn.modrinth.com/data/VSNURh3q/versions/Pk9KKjAm/c2me-fabric-mc26.2-0.4.2-alpha.0.23.jar";
              sha512 = "88ce275d5b2bc5aff451d199184b8d1a693aaf0a6ac4e6202d0b12d6d92e99e476892ee2bbec09f629119fa36aa7d888214d8a13e6ee12d2016661e7c7a379d2";
            };
            debugify = fetchurl {
              url = "https://cdn.modrinth.com/data/QwxR6Gcd/versions/V2I3yC58/debugify-26.2.0.0.jar";
              sha512 = "41999eeff94c6a69810d65571bb09cb49a6c29a1e134f49fe31fe826e41f7a6cf7997350fb0d175270fe10c81e5e6433738562f8a22a57725a6f76544414e396";
            };
            packet-fixer = fetchurl {
              url = "https://cdn.modrinth.com/data/c7m1mi73/versions/V1pYl7hL/PacketFixer-fabric-3.3.6.jar";
              sha512 = "4d518d2c9f36a890caca55cc201b871b8f1b356064116e3e812c7d179f9554e9f2017f6bbd2db2e0fb61e3c1d410ab643f9e3ceecc0831ed171c67830795067a";
            };
            chunky = fetchurl {
              url = "https://cdn.modrinth.com/data/fALzjamp/versions/4Eotm6ov/Chunky-Fabric-1.5.3.jar";
              sha512 = "b83bfe7b218d0aa6232af977ae741dc1f82b10e50cd12bb759f65cf416b8b62beccb543e587ef0b9670abe03815660f8e091bc6823624d65cf07300571573516";
            };
            vmp-fabric = fetchurl {
              url = "https://cdn.modrinth.com/data/wnEe9KBa/versions/d6FfpWFI/vmp-fabric-mc26.2-0.2.0%2Bbeta.7.236-all.jar";
              sha512 = "2e0fd87e66f35f00f634176d4072a6c6d1eee965d1817833709ad3ea73e4f2719fa152d5e95b5ab8216b064c7db124b7f13838ebea87d92f7a72df82839e9bd5";
            };
            servercore = fetchurl {
              url = "https://cdn.modrinth.com/data/4WWQxlQP/versions/edrtnY9v/servercore-fabric-1.5.19%2B26.2.jar";
              sha512 = "aa4cfc93f8e02172910302444330e37713dfcf2047d28e55eb7323a3cd5d51493374a0959aa3e626ec2bf43fc707a755508b83454bb34b6d57d65c069929074b";
            };
            scalablelux = fetchurl {
              url = "https://cdn.modrinth.com/data/Ps1zyz6x/versions/EKLUURiy/ScalableLux-fabric-0.3.0-alpha.0.3-all.jar";
              sha512 = "ea1551c8728a726f6ee82fed3040af52791943ef99f6b63428ed770797f60677e0160975ad59ad0f51bcd4a4ec2b5da39c6913ab2379f2e25d2397132d469a94";
            };
            alternate-current = fetchurl {
              url = "https://cdn.modrinth.com/data/r0v8vy1s/versions/blSBYnpw/alternate-current-mc26.2-1.9.0.jar";
              sha512 = "319e99db7650ef315ba5b5aa7d1a0bafdaeb07b1d72bd4c14489f4eb450c76c648fe53e3f8a2643ef7e59a8291b3314ded8da7fc4c2468b4c762b8554414b14f";
            };
            carpet = fetchurl {
              url = "https://cdn.modrinth.com/data/TQTTVgYE/versions/bGrLxJ8v/fabric-carpet-26.2%2Bv260616.jar";
              sha512 = "8b8fac6979bd3153f5cfb4faa6bab52e1357eab814492a6658f3c0e1ac2856ad37a626c0a03a0839c39abb7bf56661f77b09d05d10ac01173bcdd373a33c6265";
            };
            neruina = fetchurl {
              url = "https://cdn.modrinth.com/data/1s5x833P/versions/ptPJYIjL/neruina-3.3.3%2B26.2-fabric.jar";
              sha512 = "cfc7876a8ac03ffe3598b78dc52978a6b045d0093bd00ece85b7336287ce9efe47d3c2ccfd1f83cbf181ce74da97b8f09bca1f8163711526bb845d23401994d3";
            };
            structure-layout-optimizer = fetchurl {
              url = "https://cdn.modrinth.com/data/ayPU0OHc/versions/JwbecFqq/structure_layout_optimizer-1.1.4%2B26.1-fabric.jar";
              sha512 = "d0a443e5a71dc6a40f6345b49b73aee5290d5726f68a5b05d3b31b9ff71262dd2986518df8a560f2097e7584b944ff462d621499f5dede10afa624a34359e8cc";
            };
            modernfix-mvus = fetchurl {
              url = "https://cdn.modrinth.com/data/TjSm1wrD/versions/TUWH6NZu/modernfix-5.27.19-build.1.jar";
              sha512 = "10588c52d75af917c06e26d81cd39f89be8b523925cea0a80588077b177aa8b2461aeaa102c390c9a3dca414b624ccc9adc87c3ab92360ab3af6e1430571d141";
            };
            zfastnoise = fetchurl {
              url = "https://cdn.modrinth.com/data/OnlVIpq5/versions/XKhAvLL2/zfastnoise-1.1.0-beta.2%2B26.2.jar";
              sha512 = "659775f310215e4fabedc94e265fc07a5bd26294798339b8310020624e640154376a2b070f6b8c2bdebf0efb290dab48a1547a34749e5fd3acfb600d662767c8";
            };
            carpet-tis-addition = fetchurl {
              url = "https://cdn.modrinth.com/data/jE0SjGuf/versions/daCrSdc6/carpet-tis-addition-v1.82.3-mc26.2.jar";
              sha512 = "49f63b989e157d3d0bf465d8923418c66789a75c10d8b2574c125656f70a75433600ce7eba913e5c643c1a76d3a6039e3d759fecc7af3da7340339e9cef0d3f5";
            };
            quick-pack = fetchurl {
              url = "https://cdn.modrinth.com/data/pSISfJ4O/versions/p0gWitI4/quick-pack-fabric-1.3.2%2B26.2.jar";
              sha512 = "728c4edce745007269d288c2ebda3b1c6f31397639eb973a76a7f17d177a3a5afa0c71f57856d5e81965a2aa612d875637fe4e12dc6c991f196935b10635fa18";
            };
            carpet-extra = fetchurl {
              url = "https://cdn.modrinth.com/data/VX3TgwQh/versions/Z5BJRYil/carpet-extra-26.2-26.2.jar";
              sha512 = "39bcfd81340cee04c2e9b9e61d628c297a13af2f96464d0081040ffa9e6336a64d36d95b76371aa00f343cef334bff3d0c6773cfb96994a9441e62ff7632da8d";
            };
            async = fetchurl {
              url = "https://cdn.modrinth.com/data/vEC2jm6I/versions/DqR432Bq/async-fabric-0.2.4%2Balpha-26.2.jar";
              sha512 = "8a341d00e10c6e0be69758948d9c92102f6248cba7711df162828c3aa978fc26b5954a54940efd8ad4373ec72d3c25030b12b3f2c473d8b1eb09a4214c96d70d";
            };
            disable-portal-checks = fetchurl {
              url = "https://cdn.modrinth.com/data/uOzKOGGt/versions/zW17oIr0/disableportalchecks-1.0.0.jar";
              sha512 = "ee92ad1d229081643bace5a043b9b33111daeb92bb06642e0c2a680a436961102a58f1606a82b2910461a4711c56bf7753abc1737c986a868899387d5357249e";
            };
            adaptiveview = fetchurl {
              url = "https://cdn.modrinth.com/data/xZvyOrQr/versions/3QGoy50k/adaptiveview-2.4.4%2B26.2.jar";
              sha512 = "b54a730f6542882eaf02177e2083e937a0b7474ced0904913f90eca495d05430d3f883aa88011e3f08436b4b659f39736d7d2ef1e5af80bec5bcfd8d4c1139dd";
            };
            fabric-api = fetchurl {
              url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/lVXlbH4w/fabric-api-0.155.2%2B26.2.jar";
              sha512 = "cc56984378a27c5bcd56374d6ffbb27a45c6bf3355add2ac6be9817ccac5854362249bf9d0147eb271a70fda2716129204e240d53c9aa876a2a7861f4c7f880f";
            };
            configurable = fetchurl {
              url = "https://cdn.modrinth.com/data/lGffrQ3O/versions/4QYDnMIc/configurable-3.5.2%2B26.2-fabric.jar";
              sha512 = "d7ffd0b33703c5b697f321090f5b22dc5fcee3b02330bf94551cb97d0f310853909a72d8355648aab02623878e6c81d132db19b95d87657cc309fa537cdb95b2";
            };
            resourceful-config = fetchurl {
              url = "https://cdn.modrinth.com/data/M1953qlQ/versions/RqoPv70U/ResourcefulConfig-5.0.0.jar";
              sha512 = "c9834fbcb557d6f96b99ccafc69346f8da3887cdc4e26f780f9f4fe1c712071bab2e97362ecf69cd308aaafa76ea3cb98e7bee35b61d94addae2797788156457";
            };
          }
        );
      };
    };
  };
}
