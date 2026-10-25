//! No-code workflows compile to import-free WASM; desktop capabilities stay in the host UI.
use serde::{Deserialize, Serialize};
use std::{
    fs,
    io::{Read, Write},
    os::unix::fs::{DirBuilderExt, OpenOptionsExt},
    path::PathBuf,
};
use wasmi::{Config, Engine, Linker, Module, Store};
const SECTION: &str = "spotlight.workflow.v1";
#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum Kind {
    Input,
    Clipboard,
    Screenshot,
    Ocr,
    Translate,
    Summarize,
    Note,
    Copy,
}
impl Kind {
    pub const ALL: [Self; 8] = [
        Self::Input,
        Self::Clipboard,
        Self::Screenshot,
        Self::Ocr,
        Self::Translate,
        Self::Summarize,
        Self::Note,
        Self::Copy,
    ];
    pub fn label(self) -> &'static str {
        match self {
            Self::Input => "Input text",
            Self::Clipboard => "Clipboard text",
            Self::Screenshot => "Screenshot",
            Self::Ocr => "OCR image",
            Self::Translate => "Translate locally",
            Self::Summarize => "Summarize locally",
            Self::Note => "Save note",
            Self::Copy => "Copy text",
        }
    }
    fn code(self) -> i32 {
        Self::ALL.iter().position(|k| *k == self).unwrap() as i32
    }
}
#[derive(Clone, Debug, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct Step {
    pub kind: Kind,
    pub option: String,
}
#[derive(Clone, Debug, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct Definition {
    pub version: u32,
    pub id: String,
    pub name: String,
    pub steps: Vec<Step>,
}
impl Definition {
    pub fn new() -> Self {
        Self {
            version: 1,
            id: gtk::glib::uuid_string_random().into(),
            name: "Screenshot to translated note".into(),
            steps: vec![
                Step {
                    kind: Kind::Screenshot,
                    option: String::new(),
                },
                Step {
                    kind: Kind::Ocr,
                    option: String::new(),
                },
                Step {
                    kind: Kind::Translate,
                    option: "English".into(),
                },
                Step {
                    kind: Kind::Note,
                    option: String::new(),
                },
            ],
        }
    }
    pub fn validate(&self) -> Result<(), String> {
        if self.version != 1
            || self.id.len() != 36
            || !self.id.bytes().all(|b| b.is_ascii_hexdigit() || b == b'-')
        {
            return Err("Invalid workflow identifier or version".into());
        }
        if self.name.trim().is_empty()
            || self.name.len() > 160
            || self.name.chars().any(char::is_control)
            || self.steps.is_empty()
            || self.steps.len() > 12
        {
            return Err("Use a workflow name and between 1 and 12 actions".into());
        }
        let mut image = false;
        for step in &self.steps {
            if step.kind == Kind::Translate {
                if step.option.trim().is_empty()
                    || step.option.len() > 80
                    || !step
                        .option
                        .chars()
                        .all(|c| c.is_alphabetic() || " -_()".contains(c))
                {
                    return Err(
                        "Translate needs a target language, such as English or Spanish".into(),
                    );
                }
            } else if !step.option.is_empty() {
                return Err("Only Translate accepts a language option".into());
            }
            match step.kind {
                Kind::Screenshot => image = true,
                Kind::Input | Kind::Clipboard => image = false,
                Kind::Ocr if image => image = false,
                Kind::Ocr => return Err("OCR needs a Screenshot action before it".into()),
                _ if image => return Err("Add OCR before using screenshot text".into()),
                _ => {}
            }
        }
        Ok(())
    }
}
fn leb(mut n: usize) -> Vec<u8> {
    let mut out = Vec::new();
    loop {
        let byte = (n & 127) as u8;
        n >>= 7;
        out.push(byte | if n > 0 { 128 } else { 0 });
        if n == 0 {
            break;
        }
    }
    out
}
fn field(bytes: &[u8]) -> Vec<u8> {
    let mut out = leb(bytes.len());
    out.extend_from_slice(bytes);
    out
}
fn section(id: u8, bytes: Vec<u8>, out: &mut Vec<u8>) {
    out.push(id);
    out.extend(field(&bytes));
}
pub fn compile(def: &Definition) -> Result<Vec<u8>, String> {
    def.validate()?;
    let mut out = b"\0asm\x01\0\0\0".to_vec();
    let mut meta = field(SECTION.as_bytes());
    meta.extend(serde_json::to_vec(def).map_err(|_| "Cannot encode workflow")?);
    section(0, meta, &mut out);
    section(1, vec![1, 0x60, 1, 0x7f, 1, 0x7f], &mut out);
    section(3, vec![1, 0], &mut out);
    let mut export = vec![1];
    export.extend(field(b"workflow_step"));
    export.extend([0, 0]);
    section(7, export, &mut out);
    let mut body = vec![0];
    for (i, step) in def.steps.iter().enumerate() {
        body.extend([
            0x20,
            0,
            0x41,
            i as u8,
            0x46,
            0x04,
            0x7f,
            0x41,
            step.kind.code() as u8,
            0x05,
        ]);
    }
    body.extend([0x41, 0x7f]);
    body.extend(std::iter::repeat_n(0x0b, def.steps.len() + 1));
    let mut code = vec![1];
    code.extend(field(&body));
    section(10, code, &mut out);
    Ok(out)
}
fn take<'a>(bytes: &mut &'a [u8], n: usize) -> Result<&'a [u8], String> {
    if n > bytes.len() {
        return Err("Truncated workflow module".into());
    }
    let (head, tail) = bytes.split_at(n);
    *bytes = tail;
    Ok(head)
}
fn number(bytes: &mut &[u8]) -> Result<usize, String> {
    let mut n = 0usize;
    for shift in (0..35).step_by(7) {
        let byte = take(bytes, 1)?[0];
        n |= ((byte & 127) as usize) << shift;
        if byte & 128 == 0 {
            return Ok(n);
        }
    }
    Err("Invalid workflow module length".into())
}
pub fn decode(bytes: &[u8]) -> Result<Definition, String> {
    if bytes.len() > 65536 || !bytes.starts_with(b"\0asm\x01\0\0\0") {
        return Err("Expected a workflow WASM module up to 64 KiB".into());
    }
    let mut input = &bytes[8..];
    let mut found = None;
    while !input.is_empty() {
        let kind = take(&mut input, 1)?[0];
        let size = number(&mut input)?;
        let mut data = take(&mut input, size)?;
        if kind == 0 {
            let len = number(&mut data)?;
            let name = take(&mut data, len)?;
            if name == SECTION.as_bytes() {
                if found.is_some() {
                    return Err("Duplicate workflow metadata".into());
                }
                found = Some(
                    serde_json::from_slice::<Definition>(data)
                        .map_err(|_| "Invalid workflow metadata")?,
                );
            }
        }
    }
    let def = found.ok_or("No Spotlight workflow metadata")?;
    if compile(&def)? != bytes {
        return Err("Workflow code was modified · open and save it in Workflow Builder".into());
    }
    Ok(def)
}
pub fn plan(bytes: &[u8]) -> Result<Definition, String> {
    let def = decode(bytes)?;
    let mut config = Config::default();
    config
        .consume_fuel(true)
        .set_max_recursion_depth(32)
        .set_max_stack_height(4096);
    let engine = Engine::new(&config);
    let module = Module::new(&engine, bytes).map_err(|_| "Invalid workflow WASM")?;
    let mut store = Store::new(&engine, ());
    store
        .set_fuel(10000)
        .map_err(|_| "Cannot bound workflow execution")?;
    let instance = Linker::<()>::new(&engine)
        .instantiate_and_start(&mut store, &module)
        .map_err(|_| "Workflow imports are not allowed")?;
    let run = instance
        .get_typed_func::<i32, i32>(&store, "workflow_step")
        .map_err(|_| "Workflow entry point missing")?;
    for (n, step) in def.steps.iter().enumerate() {
        if run
            .call(&mut store, n as i32)
            .map_err(|_| "Workflow fuel exhausted")?
            != step.kind.code()
        {
            return Err("Workflow plan mismatch".into());
        }
    }
    if run
        .call(&mut store, def.steps.len() as i32)
        .map_err(|_| "Workflow fuel exhausted")?
        != -1
    {
        return Err("Workflow did not terminate".into());
    }
    Ok(def)
}
pub fn directory() -> PathBuf {
    crate::core::data_dir().join("workflows")
}
fn path(id: &str) -> Result<PathBuf, String> {
    let mut d = Definition::new();
    d.id = id.into();
    d.validate()?;
    Ok(directory().join(format!("{id}.wasm")))
}
pub fn save(def: &Definition) -> Result<PathBuf, String> {
    let bytes = compile(def)?;
    plan(&bytes)?;
    let path = path(&def.id)?;
    let root = directory();
    fs::DirBuilder::new()
        .recursive(true)
        .mode(0o700)
        .create(&root)
        .map_err(|e| e.to_string())?;
    let temp = root.join(format!(".{}.tmp", gtk::glib::uuid_string_random()));
    let result = (|| {
        let mut out = fs::OpenOptions::new()
            .write(true)
            .create_new(true)
            .mode(0o600)
            .open(&temp)
            .map_err(|e| e.to_string())?;
        out.write_all(&bytes)
            .and_then(|_| out.sync_all())
            .map_err(|e| e.to_string())?;
        fs::rename(&temp, &path).map_err(|e| e.to_string())
    })();
    if result.is_err() {
        let _ = fs::remove_file(temp);
    }
    result.map(|_| path)
}
pub fn load(id: &str) -> Result<Definition, String> {
    let mut bytes = Vec::new();
    let file = fs::OpenOptions::new()
        .read(true)
        .custom_flags(libc::O_NOFOLLOW | libc::O_NONBLOCK)
        .open(path(id)?)
        .map_err(|_| "Workflow file could not be opened")?;
    if !file.metadata().is_ok_and(|m| m.is_file()) {
        return Err("Expected a regular workflow file".into());
    }
    file.take(65537)
        .read_to_end(&mut bytes)
        .map_err(|_| "Cannot read workflow")?;
    let def = plan(&bytes)?;
    if def.id != id {
        return Err("Workflow identity mismatch".into());
    }
    Ok(def)
}
pub fn list() -> Vec<Definition> {
    let mut definitions = fs::read_dir(directory())
        .into_iter()
        .flatten()
        .flatten()
        .take(100)
        .filter_map(|e| {
            e.path()
                .file_stem()
                .and_then(|s| s.to_str())
                .and_then(|id| load(id).ok())
        })
        .collect::<Vec<_>>();
    definitions.sort_by(|a, b| a.name.cmp(&b.name));
    definitions
}
pub fn remove(id: &str) -> Result<(), String> {
    fs::remove_file(path(id)?).map_err(|e| e.to_string())
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn real_wasm_plan_and_type_validation() {
        let def = Definition::new();
        let bytes = compile(&def).unwrap();
        assert_eq!(plan(&bytes).unwrap().steps.len(), 4);
        assert!(bytes.starts_with(b"\0asm"));
        let mut modified = bytes.clone();
        *modified.last_mut().unwrap() = 0;
        assert!(plan(&modified).is_err());
        let mut bad = def.clone();
        bad.steps.remove(0);
        assert!(compile(&bad).is_err());
        bad = def.clone();
        bad.steps[2].option = "English; run commands".into();
        assert!(compile(&bad).is_err());
        for n in 0..bytes.len() {
            assert!(decode(&bytes[..n]).is_err());
        }
        let mut bad = def;
        bad.id = "../../outside".into();
        assert!(compile(&bad).is_err());
    }
}
