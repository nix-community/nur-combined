import ky from "https://esm.sh/ky@0.33.3";
import { createHash } from "https://deno.land/std@0.80.0/hash/mod.ts";

const COMMON_HEADERS = {
  'user-agent': Deno.env.get("UA"),
  'content-type': 'application/json',
  'dnt': '1',
  'sec-ch-ua': '"Not/A=Brand";v="99", "Google Chrome";v="133", "Chromium";v="133"',
  'sec-ch-ua-platform': '"Linux"',
};

const NTFY_CONFIG = {
  url: 'https://ntfy.nyaw.xyz/info',
  token: `Bearer ${Deno.env.get("NTFY_TOKEN")}`
};

async function performSign(mode: "in" | "out") {
  try {
    const codeRes = await ky.get("https://xyb.1zpass.cloud/api/code", {
      headers: COMMON_HEADERS,
    }).json<{ id: number }>();

    const loginRes = await ky.post("https://xyb.1zpass.cloud/api/xyb/login", {
      headers: COMMON_HEADERS,
      json: {
        username: Deno.env.get("PHONE"),
        password: createHash("md5").update(Deno.env.get("PASSWORD")).toString(),
        codeId: codeRes.id,
      },
    }).json<{
      success: boolean;
      data: { sessionId: string; loginerId: number; encryptValue: string };
    }>();

    if (!loginRes.success) {
      console.error("login fail")
      Deno.exit(1)
    };

    const AUTH_HEADERS = {
      ...COMMON_HEADERS,
      'sessionid': loginRes.data.sessionId,
      'loginerid': String(loginRes.data.loginerId),
      'encryptvalue': loginRes.data.encryptValue,
    };

    const projectRes = await ky.post("https://xyb.1zpass.cloud/api/xyb/projects", {
      headers: AUTH_HEADERS,
      json: { force: false },
    }).json<{ data: Array<{ planId: number }> }>();

    console.log("projRes:", projectRes)

    const taskRes = await ky.post("https://xyb.1zpass.cloud/api/xyb/tasks", {
      headers: AUTH_HEADERS,
      json: {
        moduleId: projectRes.data[0].moduleIds[0],
        projectRuleId: projectRes.data[0].projectRuleIds[0], // assume only
        planId: projectRes.data[0].planId
      },
    }).json<{ data: { planId: number } }>();

    console.log("taskRes:", taskRes)

    const trainRes = await ky.post("https://xyb.1zpass.cloud/api/xyb/clock/trainid", {
      headers: AUTH_HEADERS,
      json: { planId: taskRes.data.planId },
    }).json<{ data: { traineeId: number } }>();

    const clockRes = await ky.post("https://xyb.1zpass.cloud/api/xyb/clock", {
      headers: AUTH_HEADERS,
      json: {
        postInfo: {
          address: Deno.env.get("ADDR"),
          lat: Deno.env.get("LAT"),
          lng: Deno.env.get("LNG"),
          traineeId: trainRes.data.traineeId,
          clock: 1,
          compare: 1,
          distance: 1000,
          state: 1
        },
        mode: mode,
        isResign: false
      }
    }).json<{
      success: boolean;
      data: { startTraineeDayNum: number };
      msg: string
    }>();

    await ky.post(NTFY_CONFIG.url, {
      headers: { Authorization: NTFY_CONFIG.token },
      body: `${mode}签到成功，累计天数: ${clockRes.data.startTraineeDayNum}`
    });

    return clockRes;

  } catch (error) {
    await ky.post(NTFY_CONFIG.url, {
      headers: { Authorization: NTFY_CONFIG.token },
      body: `${mode}签到失败：${error.message}`
    });
    console.error(error);
    Deno.exit(1)
  }
}

async function main() {
  try {
    // 签入流程
    const inRes = await performSign("in");
    console.log("签入成功，等待3秒...");

    // 等待3秒
    await new Promise(resolve => setTimeout(resolve, 3000));

    // 签出流程
    const outRes = await performSign("out");
    console.log("完整签到流程完成！最终天数:", outRes.data.startTraineeDayNum);

  } catch (error) {
    console.error("完整流程执行失败:", error);
  }
}

await main();
