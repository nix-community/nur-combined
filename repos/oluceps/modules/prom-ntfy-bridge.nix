{ pkgs
, config
, lib
, ...
}:
with lib;
let
  cfg = config.services.prom-ntfy-bridge;
in
{
  options.services.prom-ntfy-bridge = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    script = mkOption {
      type = types.str;
      default = ''
        import { Application, Router, RouterContext } from "https://deno.land/x/oak/mod.ts";

        const router = new Router();

        router
          .post("/api/v2/alerts", async (ctx: RouterContext) => {
            let body = await ctx.request.body;;
            let alerts = await (await body).json();
            for (const alert of alerts) {
              if ((new Date() - new Date(alert.startsAt)) / 1000 > 300) {
                continue;
              }
              await fetch(Deno.env.get("TOPIC"), {
                method: "POST",
                headers: {
                  "tags": "red_circle",
                  "prio": "high",
                },
                body: '\n' + Array
                  .from(Object.entries(alert.labels), ([k, v]) => `$\{k}: $\{v}`)
                  .join("\n"),
              });

            }
            ctx.response.status = 200;
          });

        await new Application()
          .use(router.routes())
          .listen({
            hostname: "127.0.0.1",
            port: parseInt(Deno.env.get("PORT") as string),
        });
      '';
    };
    environment = mkOption {
      type = types.listOf types.str;
      default = [ "TOPIC=https://ntfy.nyaw.xyz/crit" "PORT=8009" "DENO_DIR=/tmp" ];
    };

  };
  config =
    mkIf cfg.enable {
      systemd.services.prom-ntfy-bridge = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        description = "prom-ntfy-bridge Daemon";
        serviceConfig = {
          Type = "simple";
          DynamicUser = true;
          ExecStart =
            let scriptPath = pkgs.writeText "alert.ts" cfg.script;
            in "${lib.getExe pkgs.deno} run --allow-env --allow-net --no-check ${scriptPath}";
          Environment = cfg.environment;
          Restart = "on-failure";
        };
      };
    };
}
