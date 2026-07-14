import { invoke } from "@tauri-apps/api/core";
import { listen, UnlistenFn } from "@tauri-apps/api/event";
import { useEffect, useMemo, useRef, useState } from "react";
import { Terminal } from "xterm";
import { FitAddon } from "xterm-addon-fit";
import { Unicode11Addon } from "xterm-addon-unicode11";
import "xterm/css/xterm.css";

type TerminalOutput = {
  session_id: number;
  data: number[];
};

type TerminalExit = {
  session_id: number;
  status: number | null;
};

type ConnectionState = "connecting" | "connected" | "closed" | "error";

function getThemePalette() {
  const isDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
  return {
    isDark,
    background: isDark ? "#0b0d0f" : "#ffffff",
    toolbarBackground: isDark ? "#181c20" : "#f1f3f5",
    border: isDark ? "#2b333b" : "#dee2e6",
    text: isDark ? "#d7dde5" : "#212529",
    termBackground: isDark ? "#101214" : "#ffffff",
    termForeground: isDark ? "#d7dde5" : "#212529",
    termCursor: isDark ? "#f2cc60" : "#000000",
    termSelection: isDark ? "#315f72" : "#cce5ff",
    inputBackground: isDark ? "#0f1317" : "#ffffff",
    buttonBackground: isDark ? "#28313a" : "#e9ecef",
    buttonBorder: isDark ? "#3a4652" : "#ced4da",
    activeButtonBackground: isDark ? "#176b87" : "#228be6",
    activeButtonBorder: isDark ? "#2d94b8" : "#1c7ed6",
    activeButtonText: isDark ? "#ffffff" : "#ffffff",
    primaryButtonBg: isDark ? "#2f6f4e" : "#40c057",
    primaryButtonBorder: isDark ? "#43815f" : "#37b24d",
    closeButtonHover: isDark ? "#4a1e22" : "#ffc9c9",
  };
}

function TerminalSession({ 
  host, 
  nonce, 
  isActive, 
  theme
}: { 
  host: string; 
  nonce: number; 
  isActive: boolean; 
  theme: ReturnType<typeof getThemePalette>;
}) {
  const terminalRef = useRef<HTMLDivElement>(null);
  const termRef = useRef<Terminal | null>(null);
  const fitAddonRef = useRef<FitAddon | null>(null);
  const sessionIdRef = useRef<number | null>(null);
  const [, setConnectionState] = useState<ConnectionState>("closed");

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
        background: theme.termBackground,
        foreground: theme.termForeground,
        cursor: theme.termCursor,
        selectionBackground: theme.termSelection,
      },
    });
    const fitAddon = new FitAddon();
    const unicode11Addon = new Unicode11Addon();

    terminalRef.current.innerHTML = "";
    term.loadAddon(fitAddon);
    term.loadAddon(unicode11Addon);
    term.unicode.activeVersion = '11';
    term.open(terminalRef.current);
    try {
      fitAddon.fit();
    } catch (e) {
      console.warn("fitAddon initial fit failed:", e);
    }
    term.focus();

    term.attachCustomKeyEventHandler((e) => {
      if (e.type === 'keydown') {
        if (e.ctrlKey && e.shiftKey && (e.code === 'KeyC' || e.key === 'c' || e.key === 'C')) {
          const selection = term.getSelection();
          if (selection) {
            navigator.clipboard.writeText(selection);
          }
          return false;
        }
        if (e.ctrlKey && e.shiftKey && (e.code === 'KeyV' || e.key === 'v' || e.key === 'V')) {
          navigator.clipboard.readText().then(text => {
            term.paste(text);
          });
          return false;
        }
      }
      return true;
    });

    termRef.current = term;
    fitAddonRef.current = fitAddon;
    sessionIdRef.current = null;
    
    setConnectionState("connecting");
    term.writeln(`OmniMux: connecting to ${host}`);

    const resizeActiveSession = () => {
      if (!terminalRef.current || terminalRef.current.clientWidth === 0) return;
      try {
        fitAddon.fit();
      } catch (e) {
        return;
      }
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
      let sessionId: number;
      try {
        sessionId = await invoke<number>("create_session_id");
        sessionIdRef.current = sessionId;
      } catch (error) {
        setConnectionState("error");
        term.writeln(`OmniMux: failed to allocate session ID: ${String(error)}`);
        return;
      }

      const unlistenOutput = await listen<TerminalOutput>("terminal-output", (event) => {
        if (event.payload.session_id === sessionIdRef.current) {
          term.write(new Uint8Array(event.payload.data));
        }
      });
      if (stopped) {
        unlistenOutput();
      } else {
        outputUnlisten = unlistenOutput;
      }

      const unlistenExit = await listen<TerminalExit>("terminal-exit", (event) => {
        if (event.payload.session_id !== sessionIdRef.current) return;
        const status = event.payload.status;
        setConnectionState("closed");
        term.writeln("");
        term.writeln(status === null ? "OmniMux: session closed" : `OmniMux: session exited with status ${status}`);
        sessionIdRef.current = null;
      });
      if (stopped) {
        unlistenExit();
      } else {
        exitUnlisten = unlistenExit;
      }

      try {
        await invoke("start_session", {
          sessionId,
          host,
          cols: term.cols,
          rows: term.rows,
        });
        if (stopped) {
          await invoke("stop_session", { sessionId }).catch(() => undefined);
          return;
        }

        setConnectionState("connected");
      } catch (error) {
        setConnectionState("error");
        term.writeln(`OmniMux: failed to start session: ${String(error)}`);
      }
    };

    const dataDisposable = term.onData((data) => {
      const sessionId = sessionIdRef.current;
      if (sessionId !== null) {
        invoke("write_session", { sessionId, data }).catch(() => {
          setConnectionState("error");
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
  }, [host, nonce]);

  // Update theme dynamically
  useEffect(() => {
    if (termRef.current) {
      termRef.current.options.theme = {
        background: theme.termBackground,
        foreground: theme.termForeground,
        cursor: theme.termCursor,
        selectionBackground: theme.termSelection,
      };
    }
  }, [theme]);
  
  // Refit when becoming active
  useEffect(() => {
    if (isActive && fitAddonRef.current && termRef.current && sessionIdRef.current !== null) {
      setTimeout(() => {
        try {
          fitAddonRef.current?.fit();
        } catch (e) {
          return;
        }
        if (sessionIdRef.current !== null && termRef.current) {
          invoke("resize_session", {
            sessionId: sessionIdRef.current,
            cols: termRef.current.cols,
            rows: termRef.current.rows,
          }).catch(() => undefined);
        }
      }, 10);
    }
  }, [isActive]);

  return (
    <div style={{ flex: 1, minHeight: 0, overflow: "hidden", padding: 8, display: isActive ? 'block' : 'none' }}>
      <div ref={terminalRef} style={{ width: '100%', height: '100%' }} />
    </div>
  );
}

type Tab = {
  id: string;
  type: 'quick-connect' | 'terminal';
  host?: string;
  nonce?: number;
};

function App() {
  const [theme, setTheme] = useState(getThemePalette());

  useEffect(() => {
    const matcher = window.matchMedia('(prefers-color-scheme: dark)');
    const listener = () => setTheme(getThemePalette());
    matcher.addEventListener('change', listener);
    return () => matcher.removeEventListener('change', listener);
  }, []);

  const [hosts, setHosts] = useState<string[]>(["localhost"]);
  const [tabs, setTabs] = useState<Tab[]>([{ id: 'qc', type: 'quick-connect' }]);
  const [activeTabId, setActiveTabId] = useState<string>('qc');
  const [newHost, setNewHost] = useState("");

  const sortedHosts = useMemo(
    () => Array.from(new Set(hosts.map((host) => host.trim()).filter(Boolean))),
    [hosts],
  );

  useEffect(() => {
    invoke<string[]>("get_ssh_hosts")
      .then((fetchedHosts) => {
        const merged = ["localhost", ...fetchedHosts.filter((h) => h !== "localhost")];
        setHosts(Array.from(new Set(merged)));
      })
      .catch((err) => console.error("Failed to fetch SSH hosts:", err));
  }, []);

  const addHost = () => {
    const host = newHost.trim();
    if (!host) return;
    setHosts((currentHosts) => Array.from(new Set([...currentHosts, host])));
    connectToHost(host);
    setNewHost("");
  };

  const connectToHost = (host: string) => {
    const newTabId = `term-${Date.now()}-${Math.random().toString(36).substring(2, 9)}`;
    setTabs([...tabs, { id: newTabId, type: 'terminal', host, nonce: 0 }]);
    setActiveTabId(newTabId);
  };

  const closeTab = (id: string, e: React.MouseEvent) => {
    e.stopPropagation();
    const index = tabs.findIndex(t => t.id === id);
    if (index === -1) return;
    
    const newTabs = tabs.filter(t => t.id !== id);
    if (newTabs.length === 0) {
      newTabs.push({ id: 'qc', type: 'quick-connect' });
    }
    
    setTabs(newTabs);
    
    if (activeTabId === id) {
      // switch to previous tab if possible
      const newActiveIndex = Math.max(0, index - 1);
      setActiveTabId(newTabs[newActiveIndex].id);
    }
  };

  const reconnect = () => {
    setTabs(tabs.map(tab => {
      if (tab.id === activeTabId && tab.type === 'terminal') {
        return { ...tab, nonce: (tab.nonce || 0) + 1 };
      }
      return tab;
    }));
  };

  return (
    <main style={{ 
      background: theme.background, 
      color: theme.text, 
      display: "flex", 
      flexDirection: "column", 
      height: "100vh", 
      minWidth: 0,
      fontFamily: "system-ui, -apple-system, sans-serif"
    }}>
      <header style={{
        alignItems: "center",
        background: theme.toolbarBackground,
        borderBottom: `1px solid ${theme.border}`,
        display: "flex",
        flexWrap: "wrap",
        minHeight: 40,
        padding: "0 10px",
        paddingTop: 8,
        gap: 2,
      }}>
        <div style={{ color: theme.text, fontSize: 15, fontWeight: 700, marginRight: 16, paddingBottom: 8 }}>
          OmniMux
        </div>
        <div style={{ display: 'flex', flex: 1, overflowX: 'auto', gap: 4 }}>
          {tabs.map((tab) => {
            const isActive = tab.id === activeTabId;
            return (
              <div
                key={tab.id}
                onClick={() => setActiveTabId(tab.id)}
                style={{
                  background: isActive ? theme.background : theme.buttonBackground,
                  border: `1px solid ${isActive ? theme.border : theme.buttonBorder}`,
                  borderBottom: isActive ? `1px solid ${theme.background}` : `1px solid ${theme.border}`,
                  borderRadius: "6px 6px 0 0",
                  color: isActive ? theme.text : theme.text,
                  cursor: "pointer",
                  padding: "6px 12px",
                  fontSize: 13,
                  display: 'flex',
                  alignItems: 'center',
                  gap: 8,
                  marginBottom: -1,
                  zIndex: isActive ? 2 : 1,
                  opacity: isActive ? 1 : 0.8,
                }}
              >
                {tab.type === 'quick-connect' ? 'Quick Connect' : tab.host}
                <button 
                  onClick={(e) => closeTab(tab.id, e)}
                  style={{
                    background: 'transparent',
                    border: 'none',
                    color: 'inherit',
                    cursor: 'pointer',
                    padding: 2,
                    fontSize: 14,
                    lineHeight: 1,
                    opacity: 0.6,
                    borderRadius: 4,
                  }}
                  onMouseOver={(e) => { e.currentTarget.style.opacity = '1'; e.currentTarget.style.background = theme.closeButtonHover; }}
                  onMouseOut={(e) => { e.currentTarget.style.opacity = '0.6'; e.currentTarget.style.background = 'transparent'; }}
                >
                  ×
                </button>
              </div>
            );
          })}
          <button 
            onClick={() => {
              const newId = `qc-${Date.now()}`;
              setTabs([...tabs, { id: newId, type: 'quick-connect' }]);
              setActiveTabId(newId);
            }}
            style={{
              background: 'transparent',
              border: 'none',
              color: theme.text,
              cursor: 'pointer',
              fontSize: 18,
              padding: "4px 8px",
              opacity: 0.6,
            }}
            onMouseOver={(e) => e.currentTarget.style.opacity = '1'}
            onMouseOut={(e) => e.currentTarget.style.opacity = '0.6'}
          >
            +
          </button>
        </div>
        
        {tabs.find(t => t.id === activeTabId)?.type === 'terminal' && (
          <button onClick={reconnect} style={{
            background: theme.buttonBackground,
            border: `1px solid ${theme.buttonBorder}`,
            borderRadius: 6,
            color: theme.text,
            cursor: "pointer",
            font: "inherit",
            height: 28,
            padding: "0 10px",
            fontSize: 12,
            marginBottom: 8,
          }}>
            Reconnect
          </button>
        )}
      </header>
      
      <section style={{ flex: 1, minHeight: 0, display: 'flex', flexDirection: 'column', position: 'relative' }}>
        {tabs.map(tab => {
          if (tab.type === 'quick-connect') {
            return (
              <div 
                key={tab.id} 
                style={{ 
                  display: activeTabId === tab.id ? 'flex' : 'none',
                  flexDirection: 'column',
                  padding: 24,
                  maxWidth: 600,
                  margin: '0 auto',
                  width: '100%'
                }}
              >
                <h2 style={{ marginTop: 0, marginBottom: 24 }}>Quick Connect</h2>
                
                <div style={{ display: 'flex', gap: 8, marginBottom: 24 }}>
                  <input
                    value={newHost}
                    onChange={(event) => setNewHost(event.target.value)}
                    placeholder="user@host"
                    onKeyDown={(e) => { if (e.key === 'Enter') addHost(); }}
                    style={{
                      background: theme.inputBackground,
                      border: `1px solid ${theme.border}`,
                      borderRadius: 6,
                      color: theme.text,
                      font: "inherit",
                      height: 36,
                      flex: 1,
                      padding: "0 12px",
                    }}
                  />
                  <button onClick={addHost} style={{
                    background: theme.primaryButtonBg,
                    border: `1px solid ${theme.primaryButtonBorder}`,
                    borderRadius: 6,
                    color: "#ffffff",
                    cursor: "pointer",
                    font: "inherit",
                    fontWeight: 600,
                    height: 36,
                    padding: "0 16px",
                  }}>
                    Connect
                  </button>
                </div>

                <h3 style={{ fontSize: 14, textTransform: 'uppercase', opacity: 0.6, marginBottom: 12 }}>Saved Hosts</h3>
                <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                  {sortedHosts.map((host) => (
                    <div 
                      key={host}
                      onClick={() => connectToHost(host)}
                      style={{
                        background: theme.toolbarBackground,
                        border: `1px solid ${theme.border}`,
                        borderRadius: 6,
                        padding: "12px 16px",
                        cursor: "pointer",
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'space-between'
                      }}
                      onMouseOver={(e) => e.currentTarget.style.borderColor = theme.activeButtonBorder}
                      onMouseOut={(e) => e.currentTarget.style.borderColor = theme.border}
                    >
                      <span>{host}</span>
                      <span style={{ opacity: 0.5 }}>→</span>
                    </div>
                  ))}
                </div>
              </div>
            );
          }
          
          return (
            <TerminalSession 
              key={tab.id}
              host={tab.host!}
              nonce={tab.nonce || 0}
              isActive={activeTabId === tab.id}
              theme={theme}
            />
          );
        })}
      </section>
    </main>
  );
}

export default App;
