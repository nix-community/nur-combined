#!/usr/bin/env bash
set -euo pipefail

out="$1"
xvfb_run="$2"
port="${3:-9222}"
marker="nurpkgs-persistence-test"

app_bin="$out/bin/degrees-of-lewdity"
user_data="$(mktemp -d)"
write_log="$(mktemp)"
read_log="$(mktemp)"
app_log="$(mktemp)"
node_script="$(mktemp --suffix=.mjs)"

cleanup() {
  if [[ -n "${app_pid:-}" ]]; then
    kill "$app_pid" 2>/dev/null || true
    wait "$app_pid" 2>/dev/null || true
  fi
  rm -f "$write_log" "$read_log" "$app_log" "$node_script"
  rm -rf "$user_data"
}
trap cleanup EXIT

cat > "$node_script" <<'EOF'
import { setTimeout as sleep } from "node:timers/promises";

const port = process.env.DOL_CDP_PORT;
const phase = process.env.DOL_TEST_PHASE;
const marker = process.env.DOL_TEST_MARKER;

async function getPageTarget() {
  const targets = await (await fetch(`http://127.0.0.1:${port}/json/list`)).json();
  const page = targets.find((target) => target.type === "page");
  if (!page) throw new Error("no CDP page target");
  return page;
}

async function withCdp(run) {
  const page = await getPageTarget();
  const ws = new WebSocket(page.webSocketDebuggerUrl);
  let id = 0;
  const pending = new Map();

  ws.addEventListener("message", (event) => {
    const message = JSON.parse(event.data);
    if (!message.id) return;
    const entry = pending.get(message.id);
    if (!entry) return;
    pending.delete(message.id);
    if (message.error) entry.reject(new Error(message.error.message));
    else entry.resolve(message.result);
  });

  await new Promise((resolve, reject) => {
    ws.addEventListener("open", resolve, { once: true });
    ws.addEventListener("error", reject, { once: true });
  });

  const send = (method, params = {}) =>
    new Promise((resolve, reject) => {
      const messageId = ++id;
      pending.set(messageId, { resolve, reject });
      ws.send(JSON.stringify({ id: messageId, method, params }));
    });

  try {
    await send("Runtime.enable");
    return await run(send);
  } finally {
    ws.close();
  }
}

const writeScript = `
(() => {
  const Save = SugarCube.Save;
  const Config = SugarCube.Config;
  const marker = ${JSON.stringify(marker)};
  Config.saves.isAllowed = () => true;
  if (window.idb) window.idb.active = false;

  const slotOk = Save.slots.save(1, marker, { saveId: marker, saveName: marker });
  const autoOk = Save.autosave.save(null, { saveId: marker, saveName: marker });

  return {
    slotOk,
    autoOk,
    slotHas: Save.slots.has(1),
    autoHas: Save.autosave.has(),
    idbActive: Boolean(window.idb && window.idb.active),
    dolDetails: localStorage.getItem("dolSaveDetails"),
    saveKeys: Object.keys(localStorage).filter((key) => key.includes("save") || key.includes("SugarCube")),
  };
})()
`;

const readScript = `
(() => {
  const Save = SugarCube.Save;
  const slot = Save.slots.has(1) ? Save.slots.get(1) : null;
  const auto = Save.autosave.has() ? Save.autosave.get() : null;
  return {
    slotHas: Save.slots.has(1),
    autoHas: Save.autosave.has(),
    slotTitle: slot ? slot.title : null,
    autoTitle: auto ? auto.title : null,
    idbActive: Boolean(window.idb && window.idb.active),
    dolDetails: localStorage.getItem("dolSaveDetails"),
    saveKeys: Object.keys(localStorage).filter((key) => key.includes("save") || key.includes("SugarCube")),
  };
})()
`;

async function waitForSugarCube(send) {
  for (let attempt = 0; attempt < 120; attempt++) {
    const { result } = await send("Runtime.evaluate", {
      expression: `typeof SugarCube !== "undefined" && typeof SugarCube.Save !== "undefined"`,
      returnByValue: true,
    });
    if (result.value) return;
    await sleep(1000);
  }
  throw new Error("SugarCube save API did not become ready");
}

async function evaluate(send, expression) {
  const response = await send("Runtime.evaluate", {
    expression,
    returnByValue: true,
    awaitPromise: false,
  });
  const { result } = response;
  if (!result) {
    throw new Error(`missing CDP result: ${JSON.stringify(response)}`);
  }
  if (result.exceptionDetails) {
    throw new Error(JSON.stringify(result.exceptionDetails));
  }
  if (result.type === "undefined") {
    return undefined;
  }
  return result.value;
}

async function main() {
  const value = await withCdp(async (send) => {
    await waitForSugarCube(send);
    const expression = phase === "write" ? writeScript : readScript;
    return evaluate(send, expression);
  });
  if (value === undefined) {
    throw new Error("CDP evaluate returned no value");
  }
  process.stdout.write(`${JSON.stringify(value, null, 2)}\n`);
}

await main();
EOF

start_app() {
  "$xvfb_run" -a "$app_bin" \
    --no-sandbox \
    --remote-debugging-port="$port" \
    --user-data-dir="$user_data" \
    > "$app_log" 2>&1 &
  app_pid=$!
  for _ in $(seq 1 60); do
    if curl -sf "http://127.0.0.1:${port}/json/version" >/dev/null 2>&1; then
      return 0
    fi
    if ! kill -0 "$app_pid" 2>/dev/null; then
      echo "app exited before CDP became available" >&2
      echo "--- app output ---" >&2
      cat "$app_log" >&2
      return 1
    fi
    sleep 1
  done
  echo "timed out waiting for CDP" >&2
  echo "--- app output ---" >&2
  cat "$app_log" >&2
  return 1
}

stop_app() {
  if [[ -n "${app_pid:-}" ]]; then
    kill "$app_pid" 2>/dev/null || true
    wait "$app_pid" 2>/dev/null || true
    unset app_pid
  fi
  for _ in $(seq 1 20); do
    if ! curl -sf "http://127.0.0.1:${port}/json/version" >/dev/null 2>&1; then
      return 0
    fi
    sleep 0.5
  done
}

run_phase() {
  local phase="$1"
  local log_file="$2"
  export DOL_CDP_PORT="$port"
  export DOL_TEST_PHASE="$phase"
  export DOL_TEST_MARKER="$marker"
  start_app
  if ! node "$node_script" > "$log_file"; then
    echo "${phase} phase failed" >&2
    cat "$log_file" >&2 || true
    return 1
  fi
  stop_app
}

run_phase write "$write_log"

if ! grep -q '"slotHas": true' "$write_log"; then
  echo "write phase did not create slot save" >&2
  cat "$write_log" >&2
  exit 1
fi

if ! grep -q '"autoHas": true' "$write_log"; then
  echo "write phase did not create autosave" >&2
  cat "$write_log" >&2
  exit 1
fi

sleep 2
run_phase read "$read_log"

if ! grep -q '"slotHas": true' "$read_log"; then
  echo "slot save did not persist across restart" >&2
  echo "write:" >&2
  cat "$write_log" >&2
  echo "read:" >&2
  cat "$read_log" >&2
  exit 1
fi

if ! grep -q '"autoHas": true' "$read_log"; then
  echo "autosave did not persist across restart" >&2
  echo "write:" >&2
  cat "$write_log" >&2
  echo "read:" >&2
  cat "$read_log" >&2
  exit 1
fi

echo "persistence test passed using production wrapper"
echo "write result:"
cat "$write_log"
echo "read result:"
cat "$read_log"
