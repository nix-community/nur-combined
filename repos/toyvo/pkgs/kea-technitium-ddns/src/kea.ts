/**
 * Query Kea's in-memory leases over its unix control socket.
 *
 * Unlike the on-disk memfile (rewritten periodically, so readers can
 * catch it empty or half-written), the control channel answers from
 * Kea's live in-memory lease store. Protocol, confirmed against Kea's
 * own `unix_command_mgr.cc`: send one raw JSON command, the server
 * processes it once the object is complete and closes the connection
 * after sending the response.
 */

export async function queryKeaLeases(
  socketPath: string,
  timeoutMs = 5000,
): Promise<unknown[]> {
  const command = JSON.stringify({
    command: "lease4-get-all",
    service: ["dhcp4"],
  });
  const chunks: Uint8Array[] = [];
  const text = await new Promise<string>((resolve, reject) => {
    let sock: { end: () => void } | null = null;
    const timer = setTimeout(() => {
      try {
        sock?.end();
      } catch {
        // ignore close errors; the timeout below reports the failure
      }
      reject(new Error(`kea control socket timeout after ${timeoutMs}ms`));
    }, timeoutMs);
    Bun.connect({
      unix: socketPath,
      socket: {
        open(s) {
          sock = s;
          s.write(command);
        },
        data(_s, data) {
          chunks.push(data);
        },
        close() {
          clearTimeout(timer);
          resolve(Buffer.concat(chunks).toString("utf8"));
        },
        error(_s, err) {
          clearTimeout(timer);
          reject(err);
        },
      },
    }).catch((e) => {
      clearTimeout(timer);
      reject(e);
    });
  });
  let parsed: any;
  try {
    parsed = JSON.parse(text);
  } catch {
    throw new Error(
      `kea control socket returned non-JSON: ${text.slice(0, 200)}`,
    );
  }
  if (parsed?.result !== 0) {
    throw new Error(
      `kea error: ${String(parsed?.text ?? JSON.stringify(parsed)).slice(0, 200)}`,
    );
  }
  const leases = parsed?.arguments?.leases;
  if (!Array.isArray(leases)) {
    throw new Error("kea response has no arguments.leases array");
  }
  return leases as unknown[];
}
