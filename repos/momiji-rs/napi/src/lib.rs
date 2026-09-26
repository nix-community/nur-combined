//! Native Node addon over [`sasso`] — the F4 engine of
//! `docs/ASYNC_PERF_ARCHITECTURE.md`. No wasm, no asyncify: async compiles run
//! on a dedicated OS thread each (real CPU parallelism across concurrent
//! compiles), and JS callbacks (importers, custom functions, logger) round-trip
//! through a ThreadsafeFunction + reply-by-id channel bridge, because the core
//! [`sasso::Importer`] trait is synchronous — the compile thread parks until
//! the JS thread answers.
//!
//! Split of responsibilities with the JS wrapper (`npm/index.mjs`):
//!   • Rust owns the compile, the NATIVE filesystem importer (`loadPaths` +
//!     relative resolution never leave Rust — zero bridge round-trips for the
//!     common case), `loadedUrls` recording, and the canonical-URL ownership
//!     map (which side canonicalized what, so `load` routes back correctly).
//!   • JS owns the user-importer chain (dart-sass `Importer`/`FileImporter`
//!     bridging, maybe-async semantics — the same `_importer.mjs` machinery
//!     the wasm loader uses), the `logger`, and custom-function values (the
//!     byte protocol of `_value.mjs`, identical to the wasm path).
//!
//! Canonical-URL namespace: user importers speak URL hrefs (any scheme); the
//! native fs importer speaks ABSOLUTE PATHS (the core `FsImporter`'s own
//! canonical form). A containing URL is forwarded to the fs importer only when
//! it is schemaless (a path — i.e. fs-owned); custom-scheme containers skip
//! relative fs resolution, exactly like the wasm JS chain. The JS wrapper
//! converts paths to `file:` URLs at the API boundary (`loadedUrls`, importer
//! `containingUrl`).
//!
//! Error transport: a Sass compile error crosses as a JSON payload in the
//! napi error message (`{"sassoError":{...}}`); the wrapper rebuilds the same
//! `Exception` the wasm loader throws.

#![allow(clippy::type_complexity)]

use std::cell::RefCell;
use std::collections::HashMap;
use std::path::PathBuf;
use std::rc::Rc;
use std::sync::atomic::{AtomicU32, Ordering};
use std::sync::mpsc;
use std::sync::Mutex;

use napi::bindgen_prelude::*;
use napi::threadsafe_function::{ErrorStrategy, ThreadsafeFunction, ThreadsafeFunctionCallMode};
use napi::{Env, JsFunction, JsUnknown, NapiRaw, ValueType};

/// `bindgen_prelude` shadows `Result` with napi's; sasso-facing signatures use std's.
type SResult<T, E> = std::result::Result<T, E>;
use napi_derive::napi;

use sasso::{
    CanonicalUrl, CanonicalizeContext, FsImporter, Importer, ImporterError, ImporterResult, Options,
    OutputStyle, Syntax, WarnEvent, WarnKind,
};

// ---------------------------------------------------------------- bridge core

/// Request kinds sent to the JS bridge function (id, kind, ...payload).
const KIND_CANONICALIZE: u32 = 0;
const KIND_LOAD: u32 = 1;
const KIND_WARN: u32 = 2;
const KIND_FUNCTION: u32 = 3;

/// One request to the JS bridge. Marshalled into
/// `bridge(id, kind, a, b, c, buf)` — see `make_tsfn`.
struct BridgeRequest {
    id: u32,
    kind: u32,
    /// canonicalize: the import url · load: the canonical url · warn: JSON payload
    a: String,
    /// canonicalize: containing canonical (or None)
    b: Option<String>,
    /// canonicalize: fromImport · function: function index
    c: u32,
    /// function: serialized argument bytes
    buf: Option<Vec<u8>>,
}

/// A settled reply delivered by JS via `bridgeReply(id, rc, syntax, s1, s2, buf)`.
struct BridgeReply {
    /// 1 = hit, 0 = miss, -1 = error (message in `s1`)
    rc: i32,
    /// load: syntax code 0/1/2
    syntax: u32,
    /// canonicalize: canonical href · load: contents · error: message
    s1: Option<String>,
    /// load: sourceMapUrl
    s2: Option<String>,
    /// function: serialized value bytes
    buf: Option<Vec<u8>>,
}

/// Pending replies, keyed by request id. Global on purpose: `bridgeReply` is a
/// plain exported function and compiles run on many threads.
static REPLIES: Mutex<Option<HashMap<u32, mpsc::Sender<BridgeReply>>>> = Mutex::new(None);
static NEXT_ID: AtomicU32 = AtomicU32::new(1);

fn register_waiter(id: u32, tx: mpsc::Sender<BridgeReply>) {
    let mut g = REPLIES.lock().unwrap();
    g.get_or_insert_with(HashMap::new).insert(id, tx);
}

fn take_waiter(id: u32) -> Option<mpsc::Sender<BridgeReply>> {
    REPLIES.lock().unwrap().as_mut().and_then(|m| m.remove(&id))
}

/// JS side answers a bridge request. `rc`: 1 hit / 0 miss / -1 error.
#[napi]
pub fn bridge_reply(
    id: u32,
    rc: i32,
    syntax: u32,
    s1: Option<String>,
    s2: Option<String>,
    buf: Option<Buffer>,
) {
    if let Some(tx) = take_waiter(id) {
        // A dropped receiver just means the compile already gave up (timeout).
        let _ = tx.send(BridgeReply {
            rc,
            syntax,
            s1,
            s2,
            buf: buf.map(|b| b.to_vec()),
        });
    }
}

type Tsfn = ThreadsafeFunction<BridgeRequest, ErrorStrategy::Fatal>;

/// Build the TSFN that marshals a `BridgeRequest` into the JS bridge call
/// `bridge(id, kind, a, b, c, buf)`.
fn make_tsfn(bridge: JsFunction) -> Result<Tsfn> {
    bridge.create_threadsafe_function(0, |ctx| {
        let req: BridgeRequest = ctx.value;
        let env = ctx.env;
        let mut args: Vec<JsUnknown> = Vec::with_capacity(6);
        args.push(env.create_uint32(req.id)?.into_unknown());
        args.push(env.create_uint32(req.kind)?.into_unknown());
        args.push(env.create_string(&req.a)?.into_unknown());
        match &req.b {
            Some(s) => args.push(env.create_string(s)?.into_unknown()),
            None => args.push(env.get_null()?.into_unknown()),
        }
        args.push(env.create_uint32(req.c)?.into_unknown());
        match req.buf {
            Some(b) => args.push(env.create_buffer_with_data(b)?.into_raw().into_unknown()),
            None => args.push(env.get_null()?.into_unknown()),
        }
        Ok(args)
    })
}

/// Fire a request and park this (compile) thread until JS replies. No
/// timeout: dart-sass and the wasm engine wait indefinitely on importers, and
/// every JS bridge path (including marshal failures) answers. The two ways a
/// reply can genuinely never come are both handled: a rejected TSFN call
/// (env teardown) fails fast below, and a dropped sender surfaces as an error.
fn ask(tsfn: &Tsfn, mut req: BridgeRequest) -> BridgeReply {
    let err = |m: &str| BridgeReply {
        rc: -1,
        syntax: 0,
        s1: Some(m.to_string()),
        s2: None,
        buf: None,
    };
    let (tx, rx) = mpsc::channel();
    let id = NEXT_ID.fetch_add(1, Ordering::Relaxed);
    req.id = id;
    register_waiter(id, tx);
    let status = tsfn.call(req, ThreadsafeFunctionCallMode::NonBlocking);
    if status != Status::Ok {
        take_waiter(id);
        return err("sasso-napi: the JS bridge is gone (environment tearing down?)");
    }
    match rx.recv() {
        Ok(r) => r,
        Err(_) => err("sasso-napi: bridge reply channel dropped"),
    }
}

/// Fire-and-forget (warn events need no reply).
fn tell(tsfn: &Tsfn, req: BridgeRequest) {
    tsfn.call(req, ThreadsafeFunctionCallMode::NonBlocking);
}

// ------------------------------------------------------------- compile config

#[napi(object)]
pub struct CompileConfig {
    /// 0 = SCSS, 1 = indented, 2 = CSS (the wasm loader's syntax codes).
    pub syntax: u32,
    /// true = compressed
    pub compressed: bool,
    /// Entry url for diagnostics and entry-relative resolution. `file:` URLs
    /// are converted to plain paths by the JS wrapper (the native fs importer's
    /// canonical form); other schemes pass through untouched.
    pub url: Option<String>,
    /// The directory diagnostic paths are spelled relative to. The JS wrapper
    /// passes `process.cwd()`: the addon's own `getcwd` is the same one, but
    /// the wasm engine has none, and a frame must not depend on which engine
    /// happened to run (they disagreed — #153).
    pub cwd: Option<String>,
    pub want_map: bool,
    pub include_sources: bool,
    pub charset: bool,
    /// dart-sass `quietDeps`: drop deprecation warnings raised inside a
    /// stylesheet reached through a load path or a user importer (see
    /// `NapiChain::canonicalize`).
    pub quiet_deps: bool,
    /// dart-sass `silenceDeprecations`: deprecation ids to drop. Applied
    /// inside the compiler, beside `quietDeps`, so a silenced deprecation
    /// never reaches the per-id cap and cannot leave the run reporting "N
    /// repetitive deprecation warnings omitted" for warnings the caller
    /// asked not to see.
    ///
    /// Optional: the addon export is public and a caller that predates this
    /// option — or builds a config by hand — should not have to name it.
    pub silence_deprecations: Option<Vec<String>>,
    /// Render diagnostics with the Unicode box glyphs (dart-sass `--unicode`).
    pub unicode: bool,
    pub load_paths: Vec<String>,
    /// Whether any user importers exist (routes canonicalize through JS first).
    pub has_user_importers: bool,
    /// Custom-function signatures, in registration order (`_value.mjs` bytes).
    pub function_signatures: Vec<String>,
    /// Whether warn events should cross the bridge (a logger or stderr routing
    /// exists JS-side). Always true from the wrapper today.
    pub want_warn: bool,
}

#[napi(object)]
pub struct NativeResult {
    pub css: String,
    /// Source map JSON (parsed JS-side) when `want_map`.
    pub source_map: Option<String>,
    /// Canonical urls actually loaded, in load order (fs entries are absolute
    /// paths; user entries are whatever the user importer canonicalized).
    pub loaded_urls: Vec<String>,
}

/// Which side owns a canonical url (routes `load`). `User` carries the
/// canonical AS THE USER IMPORTER RETURNED IT (a file: href may have been
/// re-keyed to its path form for module-cache unification).
#[derive(Clone, PartialEq)]
enum Owner {
    User(String),
    Fs,
}

/// How the chain reaches user importers: over the TSFN (worker-thread compile)
/// or by calling the JS bridge function directly (sync compile — we ARE on the
/// JS thread, and sync importers must answer synchronously).
enum UserBridge<'a> {
    Tsfn(&'a Tsfn),
    Sync(&'a SyncBridge<'a>),
    None,
}

/// The importer the core sees: user importers (via bridge) first, then the
/// native fs importer — the same precedence as the wasm JS chain.
struct NapiChain<'a> {
    user: UserBridge<'a>,
    fs: FsImporter,
    /// Kept for the no-container case, where each path becomes its own
    /// synthetic base (see `canonicalize`).
    load_paths: Vec<String>,
    owner: RefCell<HashMap<String, Owner>>,
    loaded: RefCell<Vec<String>>,
}

impl<'a> NapiChain<'a> {
    fn new(user: UserBridge<'a>, load_paths: &[String]) -> Self {
        NapiChain {
            user,
            fs: FsImporter::new(load_paths.iter().map(PathBuf::from).collect()),
            load_paths: load_paths.to_vec(),
            owner: RefCell::new(HashMap::new()),
            loaded: RefCell::new(Vec::new()),
        }
    }

    fn user_canonicalize(
        &self,
        url: &str,
        ctx: &CanonicalizeContext<'_>,
    ) -> SResult<Option<String>, ImporterError> {
        // Only real containers cross the bridge: an absolute fs path or a URL
        // with a scheme. The evaluator's synthetic entry names ("stdin", or a
        // schemaless `url` option) must surface as `containingUrl: undefined`,
        // exactly like the wasm chain.
        //
        // "Absolute" through `is_absolute_path`, the same rule the other
        // site here uses, rather than a second leading-`/` test: `\\server\share`
        // has no leading `/` and no colon, so BOTH halves of the old line
        // missed it and a file reached through a UNC share crossed as "no
        // containing url" — every relative `@use` beside it then fell
        // through to the load paths.
        let containing = ctx
            .containing_url
            .map(|c| c.as_str())
            .filter(|s| is_absolute_path(s) || s.contains(':'))
            .map(String::from);
        let reply = match &self.user {
            UserBridge::Tsfn(tsfn) => ask(
                tsfn,
                BridgeRequest {
                    id: 0,
                    kind: KIND_CANONICALIZE,
                    a: url.to_string(),
                    b: containing,
                    c: u32::from(ctx.from_import),
                    buf: None,
                },
            ),
            UserBridge::Sync(sb) => sb.call(KIND_CANONICALIZE, url, containing, ctx.from_import as u32, None),
            UserBridge::None => return Ok(None),
        };
        match reply.rc {
            1 => match reply.s1 {
                Some(c) => Ok(Some(c)),
                None => Err(ImporterError {
                    message: "sasso: importer's canonicalize() returned a non-string canonical".into(),
                }),
            },
            0 => Ok(None),
            _ => Err(ImporterError {
                message: reply.s1.unwrap_or_else(|| "importer failed".into()),
            }),
        }
    }

    fn user_load(&self, canonical: &str) -> SResult<Option<ImporterResult>, ImporterError> {
        let reply = match &self.user {
            UserBridge::Tsfn(tsfn) => ask(
                tsfn,
                BridgeRequest {
                    id: 0,
                    kind: KIND_LOAD,
                    a: canonical.to_string(),
                    b: None,
                    c: 0,
                    buf: None,
                },
            ),
            UserBridge::Sync(sb) => sb.call(KIND_LOAD, canonical, None, 0, None),
            UserBridge::None => return Ok(None),
        };
        match reply.rc {
            1 => match reply.s1 {
                Some(contents) => Ok(Some(ImporterResult {
                    contents,
                    syntax: syntax_from(reply.syntax),
                    source_map_url: reply.s2,
                })),
                // A hit with no string contents is a malformed reply, never an
                // empty stylesheet.
                None => Err(ImporterError {
                    message: "sasso: importer's load() returned non-string contents".into(),
                }),
            },
            0 => Ok(None),
            _ => Err(ImporterError {
                message: reply.s1.unwrap_or_else(|| "importer failed".into()),
            }),
        }
    }
}

/// The local filesystem path a `file:` URL names.
///
/// One line, because the rule lives in the `sasso` crate now. This file had
/// its own copy of it and the two had already drifted twice (#163): this
/// one accepted a `localhost` authority the other declined, and the two
/// disagreed about undecodable bytes. The second disagreement was the
/// right one and is preserved — `sasso::file_url_to_path` is the STRICT
/// reading, which is what a path about to be opened wants.
fn file_url_to_path(s: &str) -> Option<String> {
    sasso::file_url_to_path(s)
}

/// Is this canonical a native absolute path?
///
/// The HOST's rule, asked of the host — not a leading `/`, and not a hand-
/// written list of spellings. It is the same question `absolute_normalized`
/// in the core asked when it BUILT this canonical, so the two cannot
/// disagree about a value the core produced: `/a`, `C:\a`, `\\server\share\a`,
/// `\\?\C:\a`.
///
/// A leading-`/` test read the last three as relative. Windows-only, and
/// there is no Windows prebuild of this addon and no job that runs it
/// (#172), so nothing here is reachable today — written the way that is
/// correct anyway, rather than the way that happens to work where it is
/// exercised.
fn is_absolute_path(s: &str) -> bool {
    std::path::Path::new(s).is_absolute()
}

/// A containing canonical usable as an fs base: an absolute path as-is, or a
/// `file:` URL decoded to one. Everything else (custom schemes, synthetic
/// entry names like "stdin") has no fs base.
fn containing_fs_path(s: &str) -> Option<String> {
    if is_absolute_path(s) {
        return Some(s.to_string());
    }
    file_url_to_path(s).filter(|p| is_absolute_path(p))
}

fn syntax_from(code: u32) -> Syntax {
    match code {
        1 => Syntax::Sass,
        2 => Syntax::Css,
        _ => Syntax::Scss,
    }
}

impl Importer for NapiChain<'_> {
    fn canonicalize(
        &self,
        url: &str,
        ctx: &CanonicalizeContext<'_>,
    ) -> SResult<Option<CanonicalUrl>, ImporterError> {
        // 1. User importers (JS side walks its own chain in order). A user
        //    canonical that is a file: URL is keyed by its PATH form so the
        //    module cache unifies it with fs-canonicalized loads of the same
        //    file (the wasm chain gets this for free — everything there is a
        //    file: href); the ownership map remembers the original href so
        //    `load` still routes to the user importer that claimed it.
        if let Some(canon) = self.user_canonicalize(url, ctx)? {
            let key = file_url_to_path(&canon).unwrap_or_else(|| canon.clone());
            self.owner.borrow_mut().insert(key.clone(), Owner::User(canon));
            // A user importer's stylesheet is a dependency for `quietDeps`, as
            // in dart (measured against dart-sass 1.104.1's JS API on
            // 2026-09-17). The fs importer keeps the record for the whole
            // chain, so what this file then loads relatively counts too.
            self.fs.dependencies().mark(&key);
            return Ok(Some(CanonicalUrl::new(key)));
        }
        // 2. Native fs. The core FsImporter unconditionally searches the
        //    containing dir (or CWD!) first, so gate it: with a real fs base
        //    (absolute path or file: URL container) use it directly; without
        //    one, search ONLY the load paths — the wasm JS chain never falls
        //    back to the CWD, and neither may we.
        let canon = match ctx
            .containing_url
            .map(|c| c.as_str())
            .and_then(containing_fs_path)
        {
            Some(base) => {
                let containing = CanonicalUrl::new(base);
                let fs_ctx = CanonicalizeContext {
                    from_import: ctx.from_import,
                    containing_url: Some(&containing),
                };
                self.fs.canonicalize(url, &fs_ctx)?
            }
            None => {
                // Per-load-path resolution via a synthetic container FILE
                // inside each path (Path::parent of "<lp>/x" is "<lp>"; note
                // "<lp>/." normalizes the dot away and would step UP a level),
                // which keeps the CWD base out of the search order.
                let mut found = None;
                for lp in &self.load_paths {
                    let fake = CanonicalUrl::new(format!("{}/x", lp));
                    let one = FsImporter::new(Vec::new());
                    let fs_ctx = CanonicalizeContext {
                        from_import: ctx.from_import,
                        containing_url: Some(&fake),
                    };
                    if let Some(c) = one.canonicalize(url, &fs_ctx)? {
                        // Found through a load path: a dependency. The throwaway
                        // importer has its own record, so mark it on the one the
                        // compile reads.
                        self.fs.dependencies().mark(c.as_str());
                        found = Some(c);
                        break;
                    }
                }
                found
            }
        };
        if let Some(canon) = canon {
            self.owner
                .borrow_mut()
                .insert(canon.as_str().to_string(), Owner::Fs);
            return Ok(Some(canon));
        }
        Ok(None)
    }

    fn load(&self, canonical: &CanonicalUrl) -> SResult<Option<ImporterResult>, ImporterError> {
        let owner = self.owner.borrow().get(canonical.as_str()).cloned();
        let res = match owner {
            Some(Owner::User(href)) => self.user_load(&href)?,
            _ => self.fs.load(canonical)?,
        };
        if res.is_some() {
            self.loaded.borrow_mut().push(canonical.as_str().to_string());
        }
        Ok(res)
    }
}

// ----------------------------------------------------------------- warn / fns

fn warn_json(ev: &WarnEvent<'_>) -> String {
    // Hand-rolled JSON (no serde in this repo): every string field escaped.
    fn esc(s: &str, out: &mut String) {
        out.push('"');
        for c in s.chars() {
            match c {
                '"' => out.push_str("\\\""),
                '\\' => out.push_str("\\\\"),
                '\n' => out.push_str("\\n"),
                '\r' => out.push_str("\\r"),
                '\t' => out.push_str("\\t"),
                c if (c as u32) < 0x20 => out.push_str(&format!("\\u{:04x}", c as u32)),
                c => out.push(c),
            }
        }
        out.push('"');
    }
    let mut s = String::with_capacity(ev.formatted.len() + ev.message.len() + 96);
    s.push_str("{\"kind\":");
    s.push_str(if ev.kind == WarnKind::Debug { "1" } else { "0" });
    s.push_str(",\"deprecation\":");
    s.push_str(if ev.deprecation { "true" } else { "false" });
    s.push_str(",\"line\":");
    s.push_str(&ev.line.to_string());
    s.push_str(",\"deprecationId\":");
    esc(ev.deprecation_id, &mut s);
    s.push_str(",\"url\":");
    esc(ev.url, &mut s);
    s.push_str(",\"message\":");
    esc(ev.message, &mut s);
    s.push_str(",\"formatted\":");
    esc(ev.formatted, &mut s);
    s.push('}');
    s
}

/// Encode a compile error as the wrapper's structured-JSON transport.
fn error_json(err: &sasso::Error, url: Option<&str>) -> String {
    let mut s = String::new();
    s.push_str("{\"sassoError\":{\"line\":");
    s.push_str(&err.line.to_string());
    s.push_str(",\"col\":");
    s.push_str(&err.col.to_string());
    s.push_str(",\"url\":");
    json_str(url.unwrap_or(""), &mut s);
    s.push_str(",\"sassMessage\":");
    json_str(&err.message, &mut s);
    s.push_str(",\"rendered\":");
    json_str(&err.to_string(), &mut s);
    s.push_str("}}");
    s
}

/// Text of a caught panic payload.
fn panic_text(panic: &(dyn std::any::Any + Send)) -> String {
    if let Some(s) = panic.downcast_ref::<&str>() {
        (*s).to_string()
    } else if let Some(s) = panic.downcast_ref::<String>() {
        s.clone()
    } else {
        "unknown panic".to_string()
    }
}

/// Structured-JSON transport for an internal (non-Sass) failure, so the
/// wrapper still produces an Exception instead of a bare napi error.
fn internal_error_json(msg: &str) -> String {
    let mut s = String::new();
    s.push_str("{\"sassoError\":{\"line\":0,\"col\":0,\"url\":\"\",\"sassMessage\":");
    json_str(&format!("sasso-napi internal error: {msg}"), &mut s);
    s.push_str(",\"rendered\":");
    json_str(&format!("Error: sasso-napi internal error: {msg}"), &mut s);
    s.push_str("}}");
    s
}

fn json_str(v: &str, out: &mut String) {
    out.push('"');
    for c in v.chars() {
        match c {
            '"' => out.push_str("\\\""),
            '\\' => out.push_str("\\\\"),
            '\n' => out.push_str("\\n"),
            '\r' => out.push_str("\\r"),
            '\t' => out.push_str("\\t"),
            c if (c as u32) < 0x20 => out.push_str(&format!("\\u{:04x}", c as u32)),
            c => out.push(c),
        }
    }
    out.push('"');
}

/// Touch stdout/stderr once, before any compile scope can be entered.
///
/// std heap-allocates the stdio locks lazily on first use (a boxed
/// `pthread_mutex_t` on macOS). If that first use happens INSIDE an arena
/// scope — a deprecation warning mid-compile does it — the lock is allocated
/// in the arena and freed by the scope reset, and the next print aborts with
/// `failed to lock mutex: Invalid argument`. It is not a hypothetical: it is
/// what installing the allocator without this does, on the first lila
/// stylesheet that carries an `@import`.
///
/// `fn main` in the binary has done this since the arena landed. Here rather
/// than in the two entry points because every compile funnels through
/// `run_compile`, and it runs before `sasso::compile` opens the scope.
fn warm_stdio() {
    static WARM: std::sync::Once = std::sync::Once::new();
    WARM.call_once(|| {
        use std::io::Write;
        let _ = std::io::stdout().lock().flush();
        let _ = std::io::stderr().lock().flush();
    });
}

// ------------------------------------------------------------ the compile core

/// Run one compile with a fully-constructed chain/warn/functions environment.
/// Everything `Options` borrows lives on this stack frame — `Options` is not
/// `Send` (Rc warn handler), which is exactly why each async compile builds it
/// on its own thread.
fn run_compile(
    source: &str,
    cfg: &CompileConfig,
    chain: &NapiChain<'_>,
    warn: Option<sasso::WarnHandler>,
    functions: Vec<(String, sasso::HostFunction)>,
) -> std::result::Result<NativeResult, String> {
    warm_stdio();
    let mut opts = Options::new()
        .with_style(if cfg.compressed {
            OutputStyle::Compressed
        } else {
            OutputStyle::Expanded
        })
        .with_syntax(syntax_from(cfg.syntax))
        .with_charset(cfg.charset)
        .with_unicode(cfg.unicode)
        .with_importer(chain);
    if let Some(ids) = cfg.silence_deprecations.as_ref().filter(|v| !v.is_empty()) {
        opts = opts.with_silenced_deprecations(ids.iter().cloned());
    }
    if cfg.quiet_deps {
        // The record fills in as the chain resolves each load, so a deprecation
        // is judged by how its file was REACHED, not by where it sits.
        opts = opts.with_quiet_deps(chain.fs.dependencies());
    }
    if let Some(u) = cfg.url.as_deref() {
        opts = opts.with_url(u);
    }
    if let Some(c) = cfg.cwd.as_deref().filter(|c| !c.is_empty()) {
        opts = opts.with_cwd(c);
    }
    if cfg.want_map {
        opts = opts.with_source_map_include_sources(cfg.include_sources);
    }
    if let Some(w) = warn {
        opts = opts.with_warn_handler(w);
    }
    for (sig, f) in functions {
        opts = opts.with_function(&sig, f);
    }

    let out = if cfg.want_map {
        sasso::compile_with_source_map(source, &opts).map(|r| (r.css, Some(r.source_map.to_json())))
    } else {
        sasso::compile(source, &opts).map(|css| (css, None))
    };
    match out {
        Ok((css, map)) => Ok(NativeResult {
            css,
            source_map: map,
            loaded_urls: chain.loaded.borrow().clone(),
        }),
        Err(e) => Err(error_json(&e, cfg.url.as_deref())),
    }
}

fn make_warn_tsfn(tsfn: Tsfn) -> sasso::WarnHandler {
    Rc::new(move |ev: &WarnEvent<'_>| {
        tell(
            &tsfn,
            BridgeRequest {
                id: 0,
                kind: KIND_WARN,
                a: warn_json(ev),
                b: None,
                c: 0,
                buf: None,
            },
        );
    })
}

fn make_fn_tsfn(tsfn: Tsfn, index: u32) -> sasso::HostFunction {
    Rc::new(move |args: &[u8]| {
        let reply = ask(
            &tsfn,
            BridgeRequest {
                id: 0,
                kind: KIND_FUNCTION,
                a: String::new(),
                b: None,
                c: index,
                buf: Some(args.to_vec()),
            },
        );
        match reply.rc {
            1 => Ok(reply.buf.unwrap_or_default()),
            _ => Err(reply.s1.unwrap_or_else(|| "custom function failed".into())),
        }
    })
}

// ------------------------------------------------------------------ async API

/// Async compile: one OS thread per call. Returns a Promise of `NativeResult`;
/// a Sass error rejects with the structured-JSON message.
#[napi(ts_return_type = "Promise<NativeResult>")]
pub fn compile_string_async(
    env: Env,
    source: String,
    cfg: CompileConfig,
    bridge: JsFunction,
) -> Result<napi::JsObject> {
    let tsfn = make_tsfn(bridge)?;
    let (deferred, promise) = env.create_deferred::<NativeResult, _>()?;
    std::thread::Builder::new()
        .name("sasso-compile".into())
        .spawn(move || {
            let user = if cfg.has_user_importers {
                UserBridge::Tsfn(&tsfn)
            } else {
                UserBridge::None
            };
            let chain = NapiChain::new(user, &cfg.load_paths);
            let warn = if cfg.want_warn {
                Some(make_warn_tsfn(tsfn.clone()))
            } else {
                None
            };
            let functions = cfg
                .function_signatures
                .iter()
                .enumerate()
                .map(|(i, sig)| (sig.clone(), make_fn_tsfn(tsfn.clone(), i as u32)))
                .collect();
            // catch_unwind: a panicking compile must still SETTLE the promise
            // (a dropped-unsettled deferred hangs the caller forever and pins
            // the event loop). AssertUnwindSafe: everything captured is
            // per-compile and discarded on the panic path.
            let out = std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| {
                run_compile(&source, &cfg, &chain, warn, functions)
            }));
            match out {
                Ok(Ok(res)) => deferred.resolve(move |_| Ok(res)),
                Ok(Err(json)) => deferred.reject(napi::Error::new(Status::GenericFailure, json)),
                Err(panic) => {
                    let msg = panic_text(&panic);
                    deferred.reject(napi::Error::new(
                        Status::GenericFailure,
                        internal_error_json(&msg),
                    ));
                }
            }
        })
        .map_err(|e| napi::Error::new(Status::GenericFailure, format!("spawn failed: {e}")))?;
    Ok(promise)
}

// ------------------------------------------------------------------- sync API

/// The synchronous user bridge: calls the JS bridge function directly (we are
/// on the JS thread) and decodes its immediate return value
/// `[rc, syntax, s1, s2, buf]`. A user importer returning a Promise was
/// already rejected JS-side (`normalizeImporter(imp, false)`), so the return
/// is always settled.
struct SyncBridge<'a> {
    env: &'a Env,
    f: &'a JsFunction,
}

impl SyncBridge<'_> {
    fn call(&self, kind: u32, a: &str, b: Option<String>, c: u32, buf: Option<&[u8]>) -> BridgeReply {
        let err = |m: &str| BridgeReply {
            rc: -1,
            syntax: 0,
            s1: Some(m.to_string()),
            s2: None,
            buf: None,
        };
        let mut args: Vec<JsUnknown> = Vec::with_capacity(6);
        let build = (|| -> Result<()> {
            args.push(self.env.create_uint32(0)?.into_unknown());
            args.push(self.env.create_uint32(kind)?.into_unknown());
            args.push(self.env.create_string(a)?.into_unknown());
            match &b {
                Some(s) => args.push(self.env.create_string(s)?.into_unknown()),
                None => args.push(self.env.get_null()?.into_unknown()),
            }
            args.push(self.env.create_uint32(c)?.into_unknown());
            match buf {
                Some(bts) => args.push(self.env.create_buffer_with_data(bts.to_vec())?.into_unknown()),
                None => args.push(self.env.get_null()?.into_unknown()),
            }
            Ok(())
        })();
        if build.is_err() {
            return err("sasso-napi: failed to marshal bridge args");
        }
        let ret = match self.f.call(None, &args) {
            Ok(v) => v,
            // A JS exception thrown by the bridge surfaces here; carry its text.
            Err(e) => return err(&e.reason.to_string()),
        };
        decode_reply(self.env, ret).unwrap_or_else(|| err("sasso-napi: bridge returned a malformed reply"))
    }
}

/// Decode a sync-bridge return `[rc, syntax, s1, s2, buf]` (JS array).
fn decode_reply(_env: &Env, v: JsUnknown) -> Option<BridgeReply> {
    let obj = v.coerce_to_object().ok()?;
    let rc: i32 = obj.get_element::<napi::JsNumber>(0).ok()?.get_int32().ok()?;
    let syntax: u32 = obj.get_element::<napi::JsNumber>(1).ok()?.get_uint32().ok()?;
    let s_at = |i: u32| -> Option<String> {
        let el: JsUnknown = obj.get_element(i).ok()?;
        match el.get_type().ok()? {
            ValueType::String => el
                .coerce_to_string()
                .ok()?
                .into_utf8()
                .ok()?
                .as_str()
                .ok()
                .map(|s| s.to_string()),
            _ => None,
        }
    };
    let s1 = s_at(2);
    let s2 = s_at(3);
    let buf = (|| -> Option<Vec<u8>> {
        let el: JsUnknown = obj.get_element(4).ok()?;
        if el.get_type().ok()? == ValueType::Object {
            let b: Buffer = unsafe { Buffer::from_napi_value(_env.raw(), el.raw()).ok()? };
            Some(b.to_vec())
        } else {
            None
        }
    })();
    Some(BridgeReply {
        rc,
        syntax,
        s1,
        s2,
        buf,
    })
}

/// Sync compile on the JS thread. `bridge` (when present) must answer
/// synchronously by RETURNING `[rc, syntax, s1, s2, buf]`.
#[napi]
pub fn compile_string_sync(
    env: Env,
    source: String,
    cfg: CompileConfig,
    bridge: Option<JsFunction>,
) -> Result<NativeResult> {
    // Sync warn/custom functions also route through the direct bridge.
    let sb = bridge.as_ref().map(|f| SyncBridge { env: &env, f });
    let user = match (&sb, cfg.has_user_importers) {
        (Some(s), true) => UserBridge::Sync(s),
        _ => UserBridge::None,
    };
    let chain = NapiChain::new(user, &cfg.load_paths);
    // Rc<dyn Fn> demands 'static, but warn/function callbacks must re-enter
    // the LIVE SyncBridge (borrowing env) DURING the compile. Bridge access
    // therefore goes through a thread-local erased pointer that is set
    // immediately before `run_compile` and cleared right after — the compile
    // is single-threaded on the JS thread and never outlives this frame. A
    // nested sync compile started from inside a callback saves/restores the
    // outer pointer (see the scope guard below).
    fn with_sync_bridge<R>(f: impl FnOnce(&SyncBridge<'_>) -> R) -> std::result::Result<R, String> {
        SYNC_BRIDGE.with(|b| {
            let ptr = *b.borrow();
            match ptr {
                // SAFETY: set only while the owning `compile_string_sync`
                // frame (and its `env`) is alive, on this same thread.
                Some(p) => Ok(f(unsafe { &*(p as *const SyncBridge<'_>) })),
                None => Err("sasso-napi: sync bridge not available".to_string()),
            }
        })
    }
    let warn: Option<sasso::WarnHandler> = match (&sb, cfg.want_warn) {
        (Some(_), true) => Some(Rc::new(move |ev: &WarnEvent<'_>| {
            let json = warn_json(ev);
            let _ = with_sync_bridge(|s| s.call(KIND_WARN, &json, None, 0, None));
        }) as sasso::WarnHandler),
        _ => None,
    };
    let functions: Vec<(String, sasso::HostFunction)> = match (&sb, cfg.function_signatures.is_empty()) {
        (Some(_), false) => cfg
            .function_signatures
            .iter()
            .enumerate()
            .map(|(i, sig)| {
                let idx = i as u32;
                let f: sasso::HostFunction = Rc::new(move |args: &[u8]| {
                    let reply = with_sync_bridge(|s| s.call(KIND_FUNCTION, "", None, idx, Some(args)))?;
                    match reply.rc {
                        1 => Ok(reply.buf.unwrap_or_default()),
                        _ => Err(reply.s1.unwrap_or_else(|| "custom function failed".into())),
                    }
                });
                (sig.clone(), f)
            })
            .collect(),
        _ => Vec::new(),
    };

    // RAII scope guard (not straight-line save/restore: a panic must ALSO
    // restore, or the thread-local keeps a dangling frame pointer): save the
    // outer value so a re-entrant sync compile from inside an importer or
    // custom function targets ITS OWN bridge, not this one's.
    struct BridgeScope {
        prev: Option<*const ()>,
    }
    impl Drop for BridgeScope {
        fn drop(&mut self) {
            SYNC_BRIDGE.with(|b| *b.borrow_mut() = self.prev);
        }
    }
    let _scope = BridgeScope {
        prev: SYNC_BRIDGE.with(|b| *b.borrow()),
    };
    if let Some(s) = &sb {
        SYNC_BRIDGE.with(|b| *b.borrow_mut() = Some(s as *const SyncBridge<'_> as *const ()));
    }
    // catch_unwind: a panic must not unwind through the extern "C" napi
    // trampoline (that aborts the whole process) — surface it as an error.
    let out = std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| {
        run_compile(&source, &cfg, &chain, warn, functions)
    }));

    match out {
        Ok(r) => r.map_err(|json| napi::Error::new(Status::GenericFailure, json)),
        Err(panic) => Err(napi::Error::new(
            Status::GenericFailure,
            internal_error_json(&panic_text(&panic)),
        )),
    }
}

thread_local! {
    static SYNC_BRIDGE: RefCell<Option<*const ()>> = const { RefCell::new(None) };
}

// ------------------------------------------------------------- the allocator
//
// The same bump arena the binary installs (`src/main.rs`) and the wasm module
// uses. Without it `compile()`'s scope primitives are inert and the whole
// compiler runs on the system allocator, which is what made this addon 1.6x
// slower than the binary running the identical code (issue #83): 6.95 ms/file
// against 5.00 on 138 Lichess stylesheets, measured by removing the arena from
// the binary rather than by reasoning about it.
//
// Safe for the values that leave a compile. `compile()` deep-clones its result
// out before resetting, and the library pauses the arena around importer,
// warn-handler and host-function callbacks — see `eval/modules.rs`, "the
// caller's importer runs OUTSIDE the arena scope" — which is what keeps the
// chain's `loaded`/`owner` records and the dependency set alive past the
// reset. Verified, not assumed: CSS and `loadedUrls` for all 138 stylesheets
// are byte-identical with and without it.
#[global_allocator]
static GLOBAL: sasso::ScopedAlloc = sasso::ScopedAlloc;

// -------------------------------------------------------------------- values

/// Routed Value-method engine (`SassNumber.convert`, `SassColor.toSpace`, …)
/// for `_value.mjs` `setEngine` — the native twin of the wasm `sasso_value_op`.
#[napi]
pub fn value_op(op: u32, input: Buffer) -> Result<Buffer> {
    match sasso::host_value_op(op, &input) {
        Ok(bytes) => Ok(bytes.into()),
        Err(msg) => Err(napi::Error::new(Status::GenericFailure, msg)),
    }
}

/// Engine version string for `info`.
#[napi]
pub fn native_version() -> String {
    env!("CARGO_PKG_VERSION").to_string()
}
