//! Capability-free WebAssembly host. Runs only in the private worker process.
use std::{
    fs,
    io::{Read, Write},
    path::Path,
};
use wasmi::{
    Caller, Config, EnforcedLimits, Engine, Error, Linker, Module, Store, StoreLimits,
    StoreLimitsBuilder,
};

pub const MODULE_LIMIT: usize = 4 * 1024 * 1024;
const REQUEST_LIMIT: usize = 512 * 1024;
const MEMORY_LIMIT: usize = 32 * 1024 * 1024;
const FUEL: u64 = 20_000_000;

struct Host {
    request: Vec<u8>,
    output: Box<dyn Write + Send>,
    limits: StoreLimits,
    calls: usize,
    emitted: usize,
}
fn checked(caller: &mut Caller<'_, Host>) -> Result<(), Error> {
    caller.data_mut().calls += 1;
    if caller.data().calls > 256 {
        return Err(Error::new("Plugin exceeded 256 host calls"));
    }
    Ok(())
}
fn memory(caller: &Caller<'_, Host>) -> Result<wasmi::Memory, Error> {
    caller
        .get_export("memory")
        .and_then(|e| e.into_memory())
        .ok_or_else(|| Error::new("Plugin must export memory"))
}
fn execute(bytes: &[u8], request: Vec<u8>, output: Box<dyn Write + Send>) -> Result<(), String> {
    if bytes.len() > MODULE_LIMIT || !bytes.starts_with(b"\0asm") {
        return Err("Expected a binary WASM module, at most 4 MiB".into());
    }
    if request.len() > REQUEST_LIMIT {
        return Err("Plugin request exceeds 512 KiB".into());
    }
    let mut config = Config::default();
    config
        .consume_fuel(true)
        .set_max_recursion_depth(256)
        .set_max_stack_height(65536)
        .enforced_limits(EnforcedLimits::strict());
    let engine = Engine::new(&config);
    // Validation is enabled explicitly in Cargo.toml; never use new_unchecked.
    let module = Module::new(&engine, bytes).map_err(|e| format!("Invalid WASM module: {e}"))?;
    let mut store = Store::new(
        &engine,
        Host {
            request,
            output,
            calls: 0,
            emitted: 0,
            limits: StoreLimitsBuilder::new()
                .memory_size(MEMORY_LIMIT)
                .memories(1)
                .instances(1)
                .tables(1)
                .table_elements(10000)
                .trap_on_grow_failure(true)
                .build(),
        },
    );
    store.limiter(|host| &mut host.limits);
    store.set_fuel(FUEL).map_err(|e| e.to_string())?;
    let mut linker = Linker::new(&engine);
    // These are the ONLY imports. There is no WASI, filesystem, environment,
    // network, clock, process, clipboard, or desktop API inside the guest.
    linker
        .func_wrap(
            "spotlight",
            "request_len",
            |mut caller: Caller<'_, Host>| -> Result<i32, Error> {
                checked(&mut caller)?;
                Ok(caller.data().request.len() as i32)
            },
        )
        .map_err(|e| e.to_string())?;
    linker
        .func_wrap(
            "spotlight",
            "read_request",
            |mut caller: Caller<'_, Host>, ptr: i32, capacity: i32| -> Result<i32, Error> {
                checked(&mut caller)?;
                if ptr < 0 || capacity < 0 || (capacity as usize) < caller.data().request.len() {
                    return Err(Error::new("Invalid request buffer"));
                }
                let memory = memory(&caller)?;
                let request = caller.data().request.clone();
                memory
                    .write(&mut caller, ptr as usize, &request)
                    .map_err(|_| Error::new("Request buffer is outside guest memory"))?;
                Ok(request.len() as i32)
            },
        )
        .map_err(|e| e.to_string())?;
    linker
        .func_wrap(
            "spotlight",
            "emit",
            |mut caller: Caller<'_, Host>, ptr: i32, len: i32| -> Result<(), Error> {
                checked(&mut caller)?;
                if ptr < 0 || !(1..=65535).contains(&len) {
                    return Err(Error::new("Invalid output buffer or output exceeds 64 KiB"));
                }
                let memory = memory(&caller)?;
                let mut bytes = vec![0; len as usize];
                memory
                    .read(&caller, ptr as usize, &mut bytes)
                    .map_err(|_| Error::new("Output buffer is outside guest memory"))?;
                if std::str::from_utf8(&bytes).is_err()
                    || bytes.contains(&b'\n')
                    || bytes.contains(&b'\r')
                {
                    return Err(Error::new(
                        "emit requires one UTF-8 JSON object without raw newlines",
                    ));
                }
                let host = caller.data_mut();
                host.emitted += bytes.len() + 1;
                if host.emitted > 1_048_576 {
                    return Err(Error::new("Plugin output exceeds 1 MiB"));
                }
                host.output
                    .write_all(&bytes)
                    .and_then(|_| host.output.write_all(b"\n"))
                    .and_then(|_| host.output.flush())
                    .map_err(|_| Error::new("Plugin result view closed"))
            },
        )
        .map_err(|e| e.to_string())?;
    let instance = linker
        .instantiate_and_start(&mut store, &module)
        .map_err(|e| format!("WASM sandbox: {e}"))?;
    if instance.get_memory(&store, "memory").is_none() {
        return Err("Plugin must export memory".into());
    }
    let run = instance
        .get_typed_func::<(), ()>(&store, "spotlight_run")
        .map_err(|_| "Plugin must export spotlight_run() with no arguments or return value")?;
    run.call(&mut store, ())
        .map_err(|e| format!("WASM sandbox: {e}"))
}
pub fn worker() -> Result<(), String> {
    let path = std::env::args_os().nth(2).ok_or("Missing module path")?;
    // Bound reads even if the module changes between discovery and execution.
    let mut bytes = Vec::new();
    fs::File::open(Path::new(&path))
        .map_err(|e| e.to_string())?
        .take(MODULE_LIMIT as u64 + 1)
        .read_to_end(&mut bytes)
        .map_err(|e| e.to_string())?;
    let mut request = Vec::new();
    std::io::stdin()
        .take(REQUEST_LIMIT as u64 + 1)
        .read_to_end(&mut request)
        .map_err(|e| e.to_string())?;
    let value: serde_json::Value =
        serde_json::from_slice(&request).map_err(|_| "Invalid plugin request JSON")?;
    if value["api_version"] != 1 {
        return Err("Unsupported plugin API version".into());
    }
    execute(&bytes, request, Box::new(std::io::stdout()))
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::sync::{Arc, Mutex};
    struct Output(Arc<Mutex<Vec<u8>>>);
    impl Write for Output {
        fn write(&mut self, bytes: &[u8]) -> std::io::Result<usize> {
            self.0.lock().unwrap().extend_from_slice(bytes);
            Ok(bytes.len())
        }
        fn flush(&mut self) -> std::io::Result<()> {
            Ok(())
        }
    }
    fn run(wat: &str) -> Result<Vec<u8>, String> {
        let output = Arc::new(Mutex::new(Vec::new()));
        execute(
            &wat::parse_str(wat).unwrap(),
            b"{\"api_version\":1}".to_vec(),
            Box::new(Output(output.clone())),
        )?;
        Ok(output.lock().unwrap().clone())
    }
    #[test]
    fn language_neutral_request_and_streaming_output() {
        let output = run(r#"(module
            (import "spotlight" "request_len" (func $len (result i32)))
            (import "spotlight" "read_request" (func $read (param i32 i32) (result i32)))
            (import "spotlight" "emit" (func $emit (param i32 i32)))
            (memory (export "memory") 1)
            (func (export "spotlight_run")
                i32.const 16 call $len call $read drop
                i32.const 16 call $len call $emit))"#)
        .unwrap();
        assert_eq!(output, b"{\"api_version\":1}\n");
    }
    #[test]
    fn sandbox_denies_ambient_capabilities_and_bad_modules() {
        for (module, reason) in [
            (
                r#"(module (import "wasi_snapshot_preview1" "path_open" (func)) (memory (export "memory") 1) (func (export "spotlight_run")))"#,
                "definition",
            ),
            (
                r#"(module (import "env" "system" (func)) (memory (export "memory") 1) (func (export "spotlight_run")))"#,
                "definition",
            ),
            (
                r#"(module (memory (export "memory") 513) (func (export "spotlight_run")))"#,
                "memory",
            ),
            (
                r#"(module (memory (export "memory") 1) (func (export "spotlight_run") i32.const 513 memory.grow drop))"#,
                "memory",
            ),
            (
                r#"(module (memory (export "memory") 1) (func (export "spotlight_run") loop br 0 end))"#,
                "fuel",
            ),
            (
                r#"(module (import "spotlight" "emit" (func $emit (param i32 i32))) (memory (export "memory") 1) (func (export "spotlight_run") i32.const 65535 i32.const 100 call $emit))"#,
                "outside",
            ),
        ] {
            let error = run(module).unwrap_err();
            assert!(
                error.to_lowercase().contains(reason)
                    || (reason == "memory" && error.contains("growth")),
                "{reason}: {error}"
            );
        }
        assert!(execute(b"\0asmgarbage", vec![], Box::new(std::io::sink())).is_err());
    }
}
