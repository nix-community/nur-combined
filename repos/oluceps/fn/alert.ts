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
      let msg = '\n' + Array
        .from(Object.entries(alert.labels), ([k, v]) => `${k}: ${v}`)
        .join("\n");

      console.log(msg);
      await fetch(Deno.env.get("TOPIC"), {
        method: "POST",
        headers: {
          "prio": "high",
          "Authorization": "Bearer tk_1de9fawbsx54apyefl6w9am8h92jg"
        },
        body: msg,
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
