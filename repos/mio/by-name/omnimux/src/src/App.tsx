import { invoke } from "@tauri-apps/api/core";
import { listen, UnlistenFn } from "@tauri-apps/api/event";
import type { CSSProperties } from "react";
import { useEffect, useMemo, useRef, useState } from "react";
import { Terminal } from "xterm";
import { FitAddon } from "xterm-addon-fit";
import "xterm/css/xterm.css";

type TerminalOutput = {
  session_id: number;
  data: string;
};

type TerminalExit = {
  session_id: number;
  status: number | null;
};

type ConnectionState = "connecting" | "connected" | "closed" | "error";

function App() {
  const terminalRef = useRef<HTMLDivElement>(null);
  const termRef = useRef<Terminal | null>(null);
  const fitAddonRef = useRef<FitAddon | null>(null);
  const sessionIdRef = useRef<number | null>(null);
  const [hosts, setHosts] = useState(["localhost"]);
  const [activeHost, setActiveHost] = useState("localhost");
  const [newHost, setNewHost] = useState("");
  const [connectionState, setConnectionState] = useState<ConnectionState>("connecting");
  const [statusText, setStatusText] = useState("Starting session");
  const [sessionNonce, setSessionNonce] = useState(0);

  const sortedHosts = useMemo(
    () => Array.from(new Set(hosts.map((host) => host.trim()).filter(Boolean))),
    [hosts],
  );

  useEffect(() => {
    if (!terminalRef.current) return;

    let stopped = false;
    let outputUnlisten: UnlistenFn | undefined;
    let exitUnlisten: UnlistenFn | undefined;
    const term = new Terminal({
      cursorBlink: true,
      convertEol: true,
      fontFamily: "ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace",
      fontSize: 13,
      theme: {
        background: "#101214",
        foreground: "#d7dde5",
        cursor: "#f2cc60",
        selectionBackground: "#315f72",
      },
    });
    const fitAddon = new FitAddon();

    terminalRef.current.innerHTML = "";
    term.loadAddon(fitAddon);
    term.open(terminalRef.current);
    fitAddon.fit();
    term.focus();

    termRef.current = term;
    fitAddonRef.current = fitAddon;
    sessionIdRef.current = null;
    setConnectionState("connecting");
    setStatusText(`Connecting to ${activeHost}`);
    term.writeln(`OmniMux: connecting to ${activeHost}`);

    const resizeActiveSession = () => {
      fitAddon.fit();
      const sessionId = sessionIdRef.current;
      if (sessionId !== null) {
        invoke("resize_session", {
          sessionId,
          cols: term.cols,
          rows: term.rows,
        }).catch(() => undefined);
      }
    };

    const start = async () => {
      outputUnlisten = await listen<TerminalOutput>("terminal-output", (event) => {
        if (event.payload.session_id === sessionIdRef.current) {
          term.write(event.payload.data);
        }
      });

      exitUnlisten = await listen<TerminalExit>("terminal-exit", (event) => {
        if (event.payload.session_id !== sessionIdRef.current) return;
        const status = event.payload.status;
        setConnectionState("closed");
        setStatusText(status === null ? "Session closed" : `Session exited with status ${status}`);
        term.writeln("");
        term.writeln(status === null ? "OmniMux: session closed" : `OmniMux: session exited with status ${status}`);
        sessionIdRef.current = null;
      });

      try {
        const sessionId = await invoke<number>("start_session", {
          host: activeHost,
          cols: term.cols,
          rows: term.rows,
        });
        if (stopped) {
          await invoke("stop_session", { sessionId }).catch(() => undefined);
          return;
        }

        sessionIdRef.current = sessionId;
        setConnectionState("connected");
        setStatusText(`Connected to ${activeHost}`);
      } catch (error) {
        setConnectionState("error");
        setStatusText(String(error));
        term.writeln(`OmniMux: failed to start session: ${String(error)}`);
      }
    };

    const dataDisposable = term.onData((data) => {
      const sessionId = sessionIdRef.current;
      if (sessionId !== null) {
        invoke("write_session", { sessionId, data }).catch((error) => {
          setConnectionState("error");
          setStatusText(String(error));
        });
      }
    });

    const resizeObserver = new ResizeObserver(resizeActiveSession);
    resizeObserver.observe(terminalRef.current);
    window.addEventListener("resize", resizeActiveSession);
    start();

    return () => {
      stopped = true;
      const sessionId = sessionIdRef.current;
      sessionIdRef.current = null;
      if (sessionId !== null) {
        invoke("stop_session", { sessionId }).catch(() => undefined);
      }
      outputUnlisten?.();
      exitUnlisten?.();
      dataDisposable.dispose();
      resizeObserver.disconnect();
      window.removeEventListener("resize", resizeActiveSession);
      term.dispose();
      if (termRef.current === term) termRef.current = null;
      if (fitAddonRef.current === fitAddon) fitAddonRef.current = null;
    };
  }, [activeHost, sessionNonce]);

  const addHost = () => {
    const host = newHost.trim();
    if (!host) return;
    setHosts((currentHosts) => Array.from(new Set([...currentHosts, host])));
    setActiveHost(host);
    setNewHost("");
  };

  const reconnect = () => {
    setSessionNonce((nonce) => nonce + 1);
  };

  return (
    <main style={styles.shell}>
      <header style={styles.toolbar}>
        <div style={styles.brand}>OmniMux</div>
        <nav style={styles.hosts}>
          {sortedHosts.map((host) => (
            <button
              key={host}
              onClick={() => setActiveHost(host)}
              style={{
                ...styles.hostButton,
                ...(activeHost.trim() === host ? styles.activeHostButton : {}),
              }}
            >
              {host}
            </button>
          ))}
        </nav>
        <form
          style={styles.addHost}
          onSubmit={(event) => {
            event.preventDefault();
            addHost();
          }}
        >
          <input
            value={newHost}
            onChange={(event) => setNewHost(event.target.value)}
            placeholder="user@host"
            style={styles.hostInput}
          />
          <button type="submit" style={styles.addButton}>
            Add
          </button>
        </form>
        <button onClick={reconnect} style={styles.reconnectButton}>
          Reconnect
        </button>
        <div style={{ ...styles.status, ...styles[connectionState] }}>{statusText}</div>
      </header>
      <section ref={terminalRef} style={styles.terminal} />
    </main>
  );
}

const styles: Record<string, CSSProperties> = {
  shell: {
    background: "#0b0d0f",
    color: "#d7dde5",
    display: "flex",
    flexDirection: "column",
    height: "100vh",
    minWidth: 0,
  },
  toolbar: {
    alignItems: "center",
    background: "#181c20",
    borderBottom: "1px solid #2b333b",
    display: "flex",
    flexWrap: "wrap",
    gap: 8,
    minHeight: 48,
    padding: "8px 10px",
  },
  brand: {
    color: "#ffffff",
    fontSize: 15,
    fontWeight: 700,
    marginRight: 4,
  },
  hosts: {
    display: "flex",
    flex: "1 1 auto",
    flexWrap: "wrap",
    gap: 6,
    minWidth: 180,
  },
  hostButton: {
    background: "#28313a",
    border: "1px solid #3a4652",
    borderRadius: 6,
    color: "#d7dde5",
    cursor: "pointer",
    font: "inherit",
    height: 30,
    padding: "0 10px",
  },
  activeHostButton: {
    background: "#176b87",
    borderColor: "#2d94b8",
    color: "#ffffff",
  },
  addHost: {
    display: "flex",
    gap: 6,
  },
  hostInput: {
    background: "#0f1317",
    border: "1px solid #3a4652",
    borderRadius: 6,
    color: "#d7dde5",
    font: "inherit",
    height: 30,
    minWidth: 120,
    padding: "0 8px",
  },
  addButton: {
    background: "#2f6f4e",
    border: "1px solid #43815f",
    borderRadius: 6,
    color: "#ffffff",
    cursor: "pointer",
    font: "inherit",
    height: 30,
    padding: "0 10px",
  },
  reconnectButton: {
    background: "#393f46",
    border: "1px solid #505a64",
    borderRadius: 6,
    color: "#ffffff",
    cursor: "pointer",
    font: "inherit",
    height: 30,
    padding: "0 10px",
  },
  status: {
    borderRadius: 6,
    fontSize: 12,
    maxWidth: 280,
    overflow: "hidden",
    padding: "5px 8px",
    textOverflow: "ellipsis",
    whiteSpace: "nowrap",
  },
  connecting: {
    background: "#3b3218",
    color: "#f2cc60",
  },
  connected: {
    background: "#173722",
    color: "#7ee787",
  },
  closed: {
    background: "#30363d",
    color: "#c9d1d9",
  },
  error: {
    background: "#4a1e22",
    color: "#ff9b9b",
  },
  terminal: {
    flex: 1,
    minHeight: 0,
    overflow: "hidden",
    padding: 8,
  },
};

export default App;
