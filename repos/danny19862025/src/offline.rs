use crate::{
    boosters::{self, Entry, Operation},
    core,
};
use std::{
    fs,
    io::{BufRead, BufReader, Read, Seek, SeekFrom, Write},
    net::{SocketAddr, TcpStream},
    path::PathBuf,
    process::{Command, Stdio},
    sync::mpsc,
    time::{Duration, Instant},
};
#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub struct Query {
    pub database: Option<String>,
    pub word: String,
}
pub fn parse(text: &str) -> Option<Query> {
    let (head, rest) = text.split_once(char::is_whitespace).unwrap_or((text, ""));
    if !["translate", "offline", "dictionaries"].contains(&head.to_ascii_lowercase().as_str()) {
        return None;
    }
    let rest = rest.trim();
    let mut parts = rest.splitn(3, char::is_whitespace);
    let first = parts.next().unwrap_or("");
    let second = parts.next().unwrap_or("");
    let third = parts.next().unwrap_or("");
    let (database, word) = if lang(first).is_some() && lang(second).is_some() {
        (
            Some(format!(
                "{}-{}",
                lang(first).unwrap(),
                lang(second).unwrap()
            )),
            third.trim(),
        )
    } else if (first.starts_with('@')
        || first
            .split_once('-')
            .is_some_and(|(a, b)| lang(a).is_some() && lang(b).is_some()))
        && first
            .trim_start_matches('@')
            .bytes()
            .all(|b| b.is_ascii_alphanumeric() || b"-_.".contains(&b))
    {
        (
            Some(pair(first.trim_start_matches('@'))),
            rest.get(first.len()..).unwrap_or("").trim(),
        )
    } else {
        (None, rest)
    };
    Some(Query {
        database,
        word: word.into(),
    })
}
fn lang(s: &str) -> Option<&'static str> {
    Some(match s {
        "en" | "eng" => "eng",
        "es" | "spa" => "spa",
        "fr" | "fra" | "fre" => "fra",
        "de" | "deu" | "ger" => "deu",
        "it" | "ita" => "ita",
        "pt" | "por" => "por",
        "ja" | "jpn" => "jpn",
        "zh" | "zho" => "zho",
        "ko" | "kor" => "kor",
        "ru" | "rus" => "rus",
        "ar" | "ara" => "ara",
        _ => return None,
    })
}
fn pair(s: &str) -> String {
    if let Some((a, b)) = s.split_once('-')
        && let (Some(a), Some(b)) = (lang(a), lang(b))
    {
        format!("{a}-{b}")
    } else {
        s.into()
    }
}
#[derive(Clone)]
struct Database {
    name: String,
    index: PathBuf,
    data: PathBuf,
    compressed: bool,
}
fn databases() -> Vec<Database> {
    let mut roots = vec![
        core::data_dir().join("dictionaries"),
        gtk::glib::user_data_dir().join("dictd"),
        "/usr/share/dictd".into(),
        "/usr/local/share/dictd".into(),
        "/usr/share/dict".into(),
    ];
    let mut files = Vec::new();
    let mut visited = 0;
    while let Some(root) = roots.pop() {
        visited += 1;
        if visited > 300 {
            break;
        }
        for e in fs::read_dir(root).into_iter().flatten().flatten() {
            let Ok(ty) = e.file_type() else { continue };
            if ty.is_symlink() {
                continue;
            }
            let path = e.path();
            if ty.is_dir() {
                roots.push(path);
                continue;
            }
            if path.extension().is_none_or(|s| s != "index") {
                continue;
            }
            let base = path.with_extension("dict");
            let zipped = path.with_extension("dict.dz");
            let gz = path.with_extension("dict.gz");
            let (data, compressed) = if base.is_file() {
                (base, false)
            } else if zipped.is_file() {
                (zipped, true)
            } else if gz.is_file() {
                (gz, true)
            } else {
                continue;
            };
            files.push(Database {
                name: path
                    .file_stem()
                    .unwrap_or_default()
                    .to_string_lossy()
                    .into(),
                index: path,
                data,
                compressed,
            });
            if files.len() >= 64 {
                return files;
            }
        }
    }
    files.sort_by(|a, b| a.name.cmp(&b.name));
    files
}
pub fn fetch(query: &Query) -> Result<Vec<Entry>, String> {
    if query.word.len() > 256 || query.word.chars().any(|c| c.is_control()) {
        return Err(
            "Use a word or short phrase without control characters (up to 256 bytes)".into(),
        );
    }
    let databases = databases();
    let mut rows = Vec::new();
    if query.word.is_empty() {
        rows.push(boosters::hint(
            "Offline dictionary / translator",
            "translate hello · translate en es hello · offline word · dictionary files stay local",
        ));
        for db in &databases {
            rows.push(Entry {
                title: db.name.clone(),
                detail: "Installed dictd dictionary · select then append a word".into(),
                badge: "Offline",
                operation: Some(Operation::Query(format!("translate @{} ", db.name))),
            });
        }
        if databases.is_empty() {
            rows.push(boosters::hint("No local dictionary files found","Add .index and .dict/.dict.dz files under ~/.local/share/spotlight/dictionaries, or run dictd on localhost:2628. See docs/OFFLINE.md."));
        }
        return Ok(rows);
    }
    let started = Instant::now();
    for db in databases
        .iter()
        .filter(|db| {
            query
                .database
                .as_ref()
                .is_none_or(|name| db.name == *name || db.name.ends_with(&format!("-{name}")))
        })
        .take(16)
    {
        if started.elapsed() > Duration::from_secs(5) {
            break;
        }
        for definition in lookup(db, &query.word)? {
            rows.push(definition_row(&query.word, &db.name, definition));
            if rows.len() >= 20 {
                return Ok(rows);
            }
        }
    }
    if !rows.is_empty() {
        return Ok(rows);
    }
    let response = server_lookup(query);
    if let Ok(definitions) = response {
        for (db, text) in definitions {
            rows.push(definition_row(&query.word, &db, text));
        }
    }
    if rows.is_empty() {
        rows.push(boosters::hint(format!("No offline entry for “{}”",query.word),if databases.is_empty(){"Install a dictionary or start local dictd · no query was sent to the internet · docs/OFFLINE.md"}else{"Try the dictionary's exact headword, choose another language pair, or install a fuller dictionary"}));
    }
    Ok(rows)
}
fn definition_row(word: &str, db: &str, text: String) -> Entry {
    Entry {
        title: format!("{word} · {db}"),
        detail: text
            .lines()
            .find(|s| !s.trim().is_empty())
            .unwrap_or("")
            .chars()
            .take(160)
            .collect(),
        badge: "Offline",
        operation: Some(Operation::Preview {
            title: format!("{word} · {db}"),
            text: format!("{text}\n\nLocal dictionary: {db}"),
            open: None,
        }),
    }
}
fn number(text: &str) -> Option<u64> {
    let mut n = 0u64;
    for c in text.bytes() {
        let d = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
            .iter()
            .position(|b| *b == c)? as u64;
        n = n.checked_mul(64)?.checked_add(d)?;
    }
    Some(n)
}
fn lookup(db: &Database, word: &str) -> Result<Vec<String>, String> {
    if fs::metadata(&db.index).map_err(|e| e.to_string())?.len() > 33_554_432 {
        return Err(format!(
            "Dictionary index is larger than 32 MiB: {}",
            db.name
        ));
    }
    let file = fs::File::open(&db.index).map_err(|e| e.to_string())?;
    let mut entries = Vec::new();
    for line in BufReader::new(file).lines().map_while(Result::ok) {
        let mut cols = line.split('\t');
        let Some(key) = cols.next() else { continue };
        if key.to_lowercase() != word.to_lowercase() {
            continue;
        }
        let Some(offset) = cols.next().and_then(number) else {
            continue;
        };
        let Some(length) = cols.next().and_then(number) else {
            continue;
        };
        if length > 65536 || offset > 268_435_456 {
            continue;
        }
        if let Ok(bytes) = read_definition(db, offset, length) {
            entries.push(String::from_utf8_lossy(&bytes).into_owned());
        }
        if entries.len() >= 5 {
            break;
        }
    }
    Ok(entries)
}
fn read_definition(db: &Database, offset: u64, length: u64) -> Result<Vec<u8>, String> {
    if !db.compressed {
        let mut file = fs::File::open(&db.data).map_err(|e| e.to_string())?;
        file.seek(SeekFrom::Start(offset))
            .map_err(|e| e.to_string())?;
        let mut bytes = vec![0; length as usize];
        file.read_exact(&mut bytes).map_err(|e| e.to_string())?;
        return Ok(bytes);
    }
    let mut child = Command::new("gzip")
        .args(["-d", "-c", "--"])
        .arg(&db.data)
        .stdin(Stdio::null())
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .spawn()
        .map_err(|_| "Compressed dictionaries require gzip")?;
    let mut pipe = child.stdout.take().unwrap();
    let (tx, rx) = mpsc::channel();
    std::thread::spawn(move || {
        let result = (|| {
            let copied = std::io::copy(&mut pipe.by_ref().take(offset), &mut std::io::sink())?;
            if copied != offset {
                return Err(std::io::Error::from(std::io::ErrorKind::UnexpectedEof));
            }
            let mut bytes = vec![0; length as usize];
            pipe.read_exact(&mut bytes)?;
            Ok(bytes)
        })();
        let _ = tx.send(result);
    });
    let result = rx
        .recv_timeout(Duration::from_secs(3))
        .map_err(|_| "Dictionary decompression timed out".to_string())
        .and_then(|r| r.map_err(|e| e.to_string()));
    let _ = child.kill();
    let _ = child.wait();
    result
}
fn server_lookup(query: &Query) -> Result<Vec<(String, String)>, String> {
    let addresses = [
        "127.0.0.1:2628".parse::<SocketAddr>().unwrap(),
        "[::1]:2628".parse().unwrap(),
    ];
    let socket = addresses
        .into_iter()
        .find_map(|address| TcpStream::connect_timeout(&address, Duration::from_millis(150)).ok())
        .ok_or("Local dictd is not running")?;
    read_server(socket, query)
}
fn read_server(mut socket: TcpStream, query: &Query) -> Result<Vec<(String, String)>, String> {
    socket
        .set_read_timeout(Some(Duration::from_secs(2)))
        .map_err(|e| e.to_string())?;
    socket
        .set_write_timeout(Some(Duration::from_secs(1)))
        .map_err(|e| e.to_string())?;
    let reader = socket.try_clone().map_err(|e| e.to_string())?;
    let mut reader = BufReader::new(reader);
    fn line(reader: &mut BufReader<TcpStream>) -> Result<String, String> {
        let mut bytes = Vec::new();
        reader
            .by_ref()
            .take(16385)
            .read_until(b'\n', &mut bytes)
            .map_err(|e| e.to_string())?;
        if bytes.len() > 16384 || bytes.is_empty() {
            return Err("Invalid local DICT response".into());
        }
        Ok(String::from_utf8_lossy(&bytes)
            .trim_end_matches(['\r', '\n'])
            .into())
    }
    if !line(&mut reader)?.starts_with("220 ") {
        return Err("Local DICT server is unavailable".into());
    }
    let db = query.database.as_deref().unwrap_or("*");
    if db != "*"
        && !db
            .bytes()
            .all(|b| b.is_ascii_alphanumeric() || b"-_.".contains(&b))
    {
        return Err("Invalid dictionary name".into());
    }
    let word = query.word.replace('\\', "\\\\").replace('"', "\\\"");
    write!(socket, "DEFINE {db} \"{word}\"\r\n").map_err(|e| e.to_string())?;
    let mut results = Vec::new();
    let started = Instant::now();
    let mut total = 0;
    loop {
        if started.elapsed() > Duration::from_secs(4) || total > 262144 {
            return Err("Local DICT response limit reached".into());
        }
        let header = line(&mut reader)?;
        total += header.len();
        if header.starts_with("250 ") || header.starts_with("552 ") || header.starts_with("550 ") {
            break;
        }
        if header.starts_with("151 ") {
            let name = header
                .split('"')
                .nth(2)
                .and_then(|s| s.split_whitespace().next())
                .unwrap_or(db)
                .to_string();
            let mut body = String::new();
            loop {
                if started.elapsed() > Duration::from_secs(4) {
                    return Err("Local DICT response timed out".into());
                }
                let value = line(&mut reader)?;
                if value == "." {
                    break;
                }
                total += value.len();
                if total > 262144 {
                    return Err("Local DICT response too large".into());
                }
                body.push_str(
                    value
                        .strip_prefix('.')
                        .filter(|_| value.starts_with(".."))
                        .unwrap_or(&value),
                );
                body.push('\n');
            }
            results.push((name, body));
            if results.len() >= 10 {
                break;
            }
        } else if !header.starts_with("150 ") {
            return Err("Unexpected local DICT response".into());
        }
    }
    let _ = socket.write_all(b"QUIT\r\n");
    Ok(results)
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn pairs_and_index_offsets() {
        assert_eq!(
            parse("translate en es hello").unwrap().database.as_deref(),
            Some("eng-spa")
        );
        assert_eq!(parse("translate en-es hello").unwrap().word, "hello");
        assert_eq!(number("BA"), Some(64));
        assert!(number("../").is_none());
        let root = std::env::temp_dir().join(format!("spotlight-dict-{}", std::process::id()));
        fs::create_dir_all(&root).unwrap();
        let db = Database {
            name: "eng-spa".into(),
            index: root.join("eng-spa.index"),
            data: root.join("eng-spa.dict"),
            compressed: false,
        };
        fs::write(&db.index, "hello\tA\tF\n").unwrap();
        fs::write(&db.data, "hola\n").unwrap();
        assert_eq!(lookup(&db, "HELLO").unwrap(), vec!["hola\n"]);
        let zipped = Command::new("gzip")
            .arg("-c")
            .arg(&db.data)
            .output()
            .unwrap();
        assert!(zipped.status.success());
        let compressed = Database {
            data: root.join("eng-spa.dict.dz"),
            compressed: true,
            ..db.clone()
        };
        fs::write(&compressed.data, zipped.stdout).unwrap();
        assert_eq!(lookup(&compressed, "hello").unwrap(), vec!["hola\n"]);
        fs::remove_dir_all(root).unwrap();
    }
    #[test]
    fn loopback_protocol_and_dot_unescaping() {
        use std::net::TcpListener;
        let listener = TcpListener::bind("127.0.0.1:0").unwrap();
        let address = listener.local_addr().unwrap();
        let thread = std::thread::spawn(move || {
            let (mut socket, _) = listener.accept().unwrap();
            socket.write_all(b"220 local dict\r\n").unwrap();
            let mut request = String::new();
            BufReader::new(socket.try_clone().unwrap())
                .read_line(&mut request)
                .unwrap();
            assert_eq!(request, "DEFINE eng-spa \"hello\"\r\n");
            socket.write_all(b"150 1 definitions\r\n151 \"hello\" eng-spa \"English-Spanish\"\r\nhola\r\n..literal\r\n.\r\n250 ok\r\n").unwrap();
        });
        let rows = read_server(
            TcpStream::connect(address).unwrap(),
            &Query {
                database: Some("eng-spa".into()),
                word: "hello".into(),
            },
        )
        .unwrap();
        assert_eq!(rows[0], ("eng-spa".into(), "hola\n.literal\n".into()));
        thread.join().unwrap();
    }
}
