# map of hostname to services or other information for said hostname
{
  router = {
    ip = "10.1.0.1";
    # Ethernet
    mac = "7c:2b:e1:13:0e:1d";
    # other ethernet ports
    # mac = "7c:2b:e1:13:0e:1e";
    # mac = "7c:2b:e1:13:0e:1f";
    # mac = "7c:2b:e1:13:0e:20";
    services.adguard = {
      port = 3000;
      displayName = "AdGuard Home";
      description = "DNS Adblocker";
      category = "Networking";
      icon = "sh-adguard-home";
      widget = {
        type = "adguard";
        url = "https://adguard.diekvoss.net";
        username = "{{HOMEPAGE_VAR_ADGUARD_USERNAME}}";
        password = "{{HOMEPAGE_VAR_ADGUARD_PASSWORD}}";
      };
    };
  };
  omada = {
    ip = "10.1.0.2";
    # Ethernet
    mac = "10:27:f5:bd:04:97";
    # port not configured through nix
    services.omada = {
      port = 443;
      selfSigned = true;
      displayName = "Omada";
      description = "Omada Controller UI";
      category = "Networking";
      icon = "sh-omada";
      widget = {
        type = "omada";
        url = "https://omada.diekvoss.net";
        username = "{{HOMEPAGE_VAR_OMADA_USERNAME}}";
        password = "{{HOMEPAGE_VAR_OMADA_PASSWORD}}";
        site = "Diekvoss Home";
      };
    };
  };
  nas = {
    ip = "10.1.0.3";
    # Ethernet
    mac = "30:9c:23:ad:79:43";
    services = {
      homepage = {
        port = 8082;
        subdomain = "@";
        description = "Hosted Services UI";
        category = "Sites";
        icon = "sh-homepage";
      };
      ollama = {
        port = 11434;
        # TODO: load balance with the mac mini, though this is much slower due to the gpu in the machine
        subdomain = "slollama";
        category = "APIs";
        displayName = "Ollama";
        description = "Ollama API (Slower)";
        icon = "sh-ollama";
      };
      open-webui = {
        port = 11435;
        subdomain = "chat";
        category = "AI";
        displayName = "Open WebUI";
        description = "Chat with LLMs";
        icon = "sh-open-webui";
      };
      discord_bot = {
        port = 8080;
        subdomain = "@";
        domain = "toyvo.dev";
        description = "Discord Bot";
        category = "APIs";
        displayName = "Discord Bot UI";
      };
      # port not configured through nix
      jellyfin = {
        port = 8096;
        displayName = "Jellyfin";
        description = "Media Server";
        category = "Media";
        icon = "sh-jellyfin";
        widget = {
          type = "jellyfin";
          url = "https://jellyfin.diekvoss.net";
          key = "{{HOMEPAGE_VAR_JELLYFIN_API_KEY}}";
        };
      };
      portainer = {
        port = 9443;
        selfSigned = true;
        displayName = "Portainer";
        description = "Adhoc Container Management";
        category = "DevOps";
        icon = "sh-portainer";
        widget = {
          type = "portainer";
          url = "https://portainer.diekvoss.net";
          key = "{{HOMEPAGE_VAR_PORTAINER_API_KEY}}";
          env = "2";
        };
      };
      coder = {
        port = 7080;
        displayName = "Coder";
        description = "Dev Container Environments";
        category = "DevOps";
        icon = "sh-coder";
      };
      cockpit = {
        port = 9090;
        selfSigned = true;
        displayName = "Cockpit";
        description = "Server Management";
        category = "DevOps";
        icon = "sh-cockpit";
      };
      qbittorrent = {
        port = 4080;
        displayName = "qBittorrent";
        description = "Torrent Client";
        category = "Media";
        icon = "sh-qbittorrent";
        widget = {
          type = "qbittorrent";
          url = "https://qbittorrent.diekvoss.net";
          username = "{{HOMEPAGE_VAR_QBITTORRENT_USERNAME}}";
          password = "{{HOMEPAGE_VAR_QBITTORRENT_PASSWORD}}";
        };
      };
      immich = {
        port = 2283;
        displayName = "Immich";
        description = "Photo Management";
        category = "Media";
        icon = "sh-immich";
        widget = {
          type = "immich";
          url = "https://immich.diekvoss.net";
          key = "{{HOMEPAGE_VAR_IMMICH_API_KEY}}";
          version = "2";
        };
      };
      home-assistant = {
        port = 8123;
        displayName = "Home Assistant";
        description = "Home Automation";
        category = "DevOps";
        icon = "sh-home-assistant";
        widget = {
          type = "homeassistant";
          url = "https://home-assistant.diekvoss.net";
          key = "{{HOMEPAGE_VAR_HOMEASSISTANT_API_KEY}}";
        };
      };
      # port not configured through nix
      nextcloud = {
        port = 80;
        displayName = "Nextcloud";
        description = "Cloud Storage";
        category = "DevOps";
        icon = "sh-nextcloud";
        widget = {
          type = "nextcloud";
          url = "https://nextcloud.diekvoss.net";
          username = "{{HOMEPAGE_VAR_NEXTCLOUD_USERNAME}}";
          password = "{{HOMEPAGE_VAR_NEXTCLOUD_PASSWORD}}";
        };
      };
      bazarr = {
        port = 6767;
        displayName = "Bazarr";
        description = "Subtitle Manager";
        category = "Starr";
        icon = "sh-bazarr";
        widget = {
          type = "bazarr";
          url = "https://bazarr.diekvoss.net";
          key = "{{HOMEPAGE_VAR_BAZARR_API_KEY}}";
        };
      };
      radarr = {
        port = 7878;
        displayName = "Radarr";
        description = "Movie Manager";
        category = "Starr";
        icon = "sh-radarr";
        widget = {
          type = "radarr";
          url = "https://radarr.diekvoss.net";
          key = "{{HOMEPAGE_VAR_RADARR_API_KEY}}";
        };
      };
      lidarr = {
        port = 8686;
        displayName = "Lidarr";
        description = "Music Manager";
        category = "Starr";
        icon = "sh-lidarr";
        widget = {
          type = "lidarr";
          url = "https://lidarr.diekvoss.net";
          key = "{{HOMEPAGE_VAR_LIDARR_API_KEY}}";
        };
      };
      sonarr = {
        port = 8989;
        displayName = "Sonarr";
        description = "TV Show Manager";
        category = "Starr";
        icon = "sh-sonarr";
        widget = {
          type = "sonarr";
          url = "https://sonarr.diekvoss.net";
          key = "{{HOMEPAGE_VAR_SONARR_API_KEY}}";
        };
      };
      prowlarr = {
        port = 9696;
        displayName = "Prowlarr";
        description = "Indexer Manager";
        category = "Starr";
        icon = "sh-prowlarr";
        widget = {
          type = "prowlarr";
          url = "https://prowlarr.diekvoss.net";
          key = "{{HOMEPAGE_VAR_PROWLARR_API_KEY}}";
        };
      };
      readarr = {
        port = 8787;
        displayName = "Readarr";
        description = "EBook/Audiobook Manager";
        category = "Starr";
        icon = "sh-readarr";
        widget = {
          type = "readarr";
          url = "https://readarr.diekvoss.net";
          key = "{{HOMEPAGE_VAR_READARR_API_KEY}}";
        };
      };
      flaresolverr = {
        port = 8191;
        displayName = "FlareSolverr";
        description = "Cloudflare Bypass";
        category = "APIs";
        icon = "sh-flaresolverr";
      };
      nix-serve = {
        port = 5000;
        subdomain = "cache";
        domain = "toyvo.dev";
        displayName = "Nix Cache";
        description = "Binary Cache";
        category = "Utilities";
        icon = "sh-nixos";
      };
      collabora = {
        port = 9980;
        displayName = "Collabora";
        description = "Office Suite for Nextcloud";
        category = "APIs";
        icon = "sh-docs-collaboration";
      };
    };
  };
  canon-printer = {
    ip = "10.1.0.4";
    # Wifi
    mac = "c4:ac:59:a6:63:33";
    services.canon-printer = {
      # port not configured through nix
      port = 443;
      selfSigned = true;
      category = "Printers";
      displayName = "Canon";
      description = "Canon Printer Management UI";
    };
  };
  hp-printer = {
    ip = "10.1.0.5";
    # Wifi
    mac = "7c:4d:8f:91:d3:9f";
    services.hp-printer = {
      # port not configured through nix
      port = 443;
      selfSigned = true;
      category = "Printers";
      displayName = "HP";
      description = "HP Printer Management UI";
    };
  };
  protectli = {
    ip = "10.1.0.6";
    # Ethernet
    mac = "00:e0:67:2c:15:f0";
    # other ethernet ports
    # mac = "00:e0:67:2c:15:f1";
    # mac = "00:e0:67:2c:15:f2";
    # mac = "00:e0:67:2c:15:f3";
  };
  rpi4b8a = {
    ip = "10.1.0.7";
    # Ethernet
    # mac = "e4:5f:01:ad:81:3b";
    # Wifi
    mac = "e4:5f:01:ad:81:3d";
  };
  rpi4b8b = {
    ip = "10.1.0.8";
    # Ethernet
    # mac = "e4:5f:01:ad:a0:da";
    # Wifi
    mac = "e4:5f:01:ad:a0:db";
  };
  rpi4b8c = {
    ip = "10.1.0.9";
    # Ethernet
    # mac = "e4:5f:01:ad:9f:27";
    # Wifi
    mac = "e4:5f:01:ad:9f:28";
  };
  rpi4b4a = {
    ip = "10.1.0.10";
    # Ethernet
    # mac = "dc:a6:32:09:ce:24";
    # Wifi
    mac = "dc:a6:32:09:ce:25";
  };
  MacMini-M1 = {
    ip = "10.1.0.11";
    # Ethernet
    mac = "4c:20:b8:de:e4:01";
    # Wifi
    # mac = "4c:20:b8:df:d1:5b";
    services.ollama = {
      port = 11434;
      category = "APIs";
      displayName = "Ollama";
      description = "Ollama API";
      icon = "sh-ollama";
    };
  };
  MacMini-Intel = {
    ip = "10.1.0.12";
    # Ethernet
    mac = "14:c2:13:ed:e6:ed";
    # Wifi
    # mac = "f0:18:98:8a:6d:ee";
  };
  windows-desktop = {
    ip = "10.1.0.13";
    # Ethernet
    mac = "70:85:c2:8a:53:5b";
    # Wifi
    # mac = "b4:6b:fc:6c:b5:4c";
  };
  steamdeck-nixos = {
    ip = "10.1.0.14";
    mac = "b4:8c:9d:b9:5d:fb";
  };
  oracle = {
    ip = "149.130.210.149";
    services.minecraft = {
      port = 7878;
      subdomain = "mc";
      domain = "toyvo.dev";
      category = "Games";
      displayName = "Minecraft";
      description = "Minecraft Server";
      icon = "sh-minecraft";
    };
  };
  github.services = {
    schedule1 = {
      domain = "toyvo.dev";
      category = "Games";
      displayName = "Schedule I Calculator";
      description = "Schedule I Calculator";
    };
    LackLuster = {
      subdomain = "lackluster";
      domain = "toyvo.dev";
      category = "Games";
      displayName = "Lack Luster";
      description = "University Game Project";
    };
    minecraft_modpack = {
      subdomain = "packwiz";
      domain = "toyvo.dev";
      category = "Games";
      displayName = "Minecraft Modpack";
      description = "Minecraft Packwiz Modpack Definition";
    };
    pdf_margins = {
      subdomain = "pdf";
      domain = "toyvo.dev";
      category = "Utilities";
      displayName = "PDF Margins";
      description = "Center PDFs within a physical page for printing";
    };
    "ToyVo.github.io" = {
      subdomain = "collin";
      domain = "diekvoss.com";
      displayName = "Portfolio";
      description = "Portfolio Website";
      category = "Sites";
    };
  };
  publicKeys = {
    "git_toyvo_sign_ed25519.pub" =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAiHxhZFUQIrOII6q1A5rOB3ZIzPy5mExKoKoMiRwxsC";
    "github_toyvo_auth_ed25519.pub" =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFt+KZ8CWXZjeejGWUcatiJFUAkLJtiMyH/wSNMxxuj1 Collin@Diekvoss.com";
    "ssh_toyvo_auth_ed25519.pub" =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEBGYGku1g/rV12/PJp4rLKeutPU/tZ5scl3ZA5t9iqG";
    "yubikey_usba_ed25519_sk.pub" =
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMo+j+J7WLG7LqFajWl6hcDTt0YTxLgw67PsaukKCO6gAAAABHNzaDo=";
    "yubikey_usbc_ed25519_sk.pub" =
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIIHvhka5cKA2RRK4z1JKcP/ZN0hVNAAetspdJyQ4PExDAAAABHNzaDo=";
  };
}
