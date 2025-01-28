import ky from "https://esm.sh/ky@0.33.3";
import { encodeHex } from "jsr:@std/encoding@1/hex";
import { createHash } from "https://deno.land/std@0.80.0/hash/mod.ts";


// 公共请求头配置
const COMMON_HEADERS = {
  'user-agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36',
  'content-type': 'application/json',
  'dnt': '1',
  'sec-ch-ua': '"Not/A=Brand";v="99", "Google Chrome";v="133", "Chromium";v="133"',
  'sec-ch-ua-platform': '"Linux"',
};

async function main() {
  try {
    // 第一步：获取验证码ID
    const codeRes = await ky.get("https://xyb.1zpass.cloud/api/code", {
      headers: COMMON_HEADERS,
    }).json<{ id: number }>();
    console.log("获取验证码ID成功:", codeRes.id);

    // 第二步：登录
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

    if (!loginRes.success) throw new Error("登录失败");
    console.log("登录成功:", loginRes.data.sessionId);

    // 后续请求公共头配置
    const AUTH_HEADERS = {
      ...COMMON_HEADERS,
      'sessionid': loginRes.data.sessionId,
      'loginerid': String(loginRes.data.loginerId),
      'encryptvalue': loginRes.data.encryptValue,
    };

    // 第三步：获取账户信息
    await ky.post("https://xyb.1zpass.cloud/api/xyb/account", {
      headers: AUTH_HEADERS,
    }).json();
    console.log("账户信息验证成功");

    // 第四步：获取项目列表
    const projectRes = await ky.post("https://xyb.1zpass.cloud/api/xyb/projects", {
      headers: AUTH_HEADERS,
      json: { force: false },
    }).json<{ data: Array<{ planId: number }> }>();
    console.log("获取项目列表成功");

    // 第五步：获取任务详情
    const taskRes = await ky.post("https://xyb.1zpass.cloud/api/xyb/tasks", {
      headers: AUTH_HEADERS,
      json: projectRes.data[0], // 使用第一个项目
    }).json<{ data: { planId: number } }>();
    console.log("获取任务详情成功");

    // 第六步：获取训练ID
    const trainRes = await ky.post("https://xyb.1zpass.cloud/api/xyb/clock/trainid", {
      headers: AUTH_HEADERS,
      json: { planId: taskRes.data.planId },
    }).json<{ data: { traineeId: number } }>();
    console.log("获取训练ID成功:", trainRes.data.traineeId);

    const clockRes = await ky.post("https://xyb.1zpass.cloud/api/xyb/clock/form", {
      headers: AUTH_HEADERS,
      json: { traineeId: trainRes.data.traineeId },
    }).json<{
      data: {
        clockInfo: { inTime: string };
        postInfo: { // 新增类型定义
          address: string;
          lat: number;
          lng: number;
          // 其他字段根据需要使用
        }
      }
    }>();

    // 第八步：分步签到（先签入后签出）
    const performClock = async (mode: "in" | "out") => {
      const res = await ky.post("https://xyb.1zpass.cloud/api/xyb/clock", {
        headers: AUTH_HEADERS,
        json: {
          postInfo: {
            ...clockRes.data.postInfo,
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

      console.log(
        `${mode === "in" ? "签入" : "签出"}成功！`,
        `累计天数: ${res.data.startTraineeDayNum}`,
        `| 消息: ${res.msg}`
      );

      return res;
    };

    // 执行双阶段签到
    try {
      // 第一阶段：签入
      const clockInRes = await performClock("in");

      // 精确等待3秒（3000毫秒）
      await new Promise(resolve => setTimeout(resolve, 3000));

      // 第二阶段：签出
      const clockOutRes = await performClock("out");

      // 验证双阶段结果
      if (!clockInRes.success || !clockOutRes.success) {
        throw new Error("双阶段签到未完全成功");
      }

      console.log("完整签到流程完成！最终天数:", clockOutRes.data.startTraineeDayNum);
      await ky.post('https://ntfy.nyaw.xyz/info', {
        Authorization: "Bearer tk_i6zp5x3z4hd5mg1eq5m7w3ohfz3u0",
        body: `签到成功, 第 ${clockOutRes.data.startTraineeDayNum} 天`,
      })
    } catch (error) {
      console.error("签到阶段发生错误:", error);
    }
  } catch (error) {
    await ky.post('https://ntfy.nyaw.xyz/info', {
      Authorization: "Bearer tk_i6zp5x3z4hd5mg1eq5m7w3ohfz3u0",
      body: `失败：${error}`,
    })
    console.error("流程执行失败:", error);
  }
}

await main();
