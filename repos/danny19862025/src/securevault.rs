//! Encrypted-at-rest clipboard pins. The JSON envelope contains no plaintext payloads.
use argon2::{Algorithm, Argon2, Params, Version};
use base64::{Engine as _, engine::general_purpose::STANDARD as B64};
use chacha20poly1305::{
    XChaCha20Poly1305, XNonce,
    aead::{Aead, KeyInit, Payload as AeadPayload},
};
use rand_core::{OsRng, RngCore};
use serde::{Deserialize, Serialize};
use std::{
    fs,
    io::{Read, Write},
    os::unix::fs::{DirBuilderExt, OpenOptionsExt},
    path::PathBuf,
    time::{Duration, Instant, SystemTime, UNIX_EPOCH},
};
use zeroize::{Zeroize, ZeroizeOnDrop, Zeroizing};

const LIMIT: u64 = 48 * 1024 * 1024;
pub const LIFETIME: i64 = 3600;
const CHECK: &[u8] = b"Spotlight clipboard vault v1";
#[derive(Serialize, Deserialize, PartialEq, Eq, Zeroize, ZeroizeOnDrop)]
#[serde(tag = "kind", content = "value", rename_all = "snake_case")]
pub enum Payload {
    Text(String),
    Image(Vec<u8>),
}
impl Payload {
    fn validate(&self) -> Result<(), String> {
        match self {
            Self::Text(text) if !text.is_empty() && text.len() <= 65536 => Ok(()),
            Self::Image(bytes) if !bytes.is_empty() && bytes.len() <= 8_388_608 => Ok(()),
            _ => Err("Secure pins accept text up to 64 KiB or PNG images up to 8 MiB".into()),
        }
    }
}
#[derive(Clone, Serialize, Deserialize)]
struct Sealed {
    id: String,
    expires: i64,
    nonce: String,
    ciphertext: String,
}
#[derive(Clone, Serialize, Deserialize)]
struct Envelope {
    version: u32,
    salt: String,
    check: Sealed,
    pins: Vec<Sealed>,
}
pub type OpenPin = (String, i64, Result<Payload, String>);
pub struct Vault {
    next_prune: std::cell::Cell<i64>,
    path: PathBuf,
    key: Option<Zeroizing<[u8; 32]>>,
    salt: Option<String>,
    deadline: Option<Instant>,
}
pub fn now() -> i64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs() as i64
}
fn random<const N: usize>() -> Result<[u8; N], String> {
    let mut bytes = [0; N];
    OsRng
        .try_fill_bytes(&mut bytes)
        .map_err(|_| "Secure random source is unavailable")?;
    Ok(bytes)
}
fn derive(password: &[u8], salt: &str) -> Result<Zeroizing<[u8; 32]>, String> {
    let salt = B64.decode(salt).map_err(|_| "Invalid vault salt")?;
    if salt.len() != 16 || password.is_empty() || password.len() > 65536 {
        return Err("Invalid vault password or salt".into());
    }
    let mut key = Zeroizing::new([0; 32]);
    let params = Params::new(65536, 3, 1, Some(32)).map_err(|_| "Invalid vault KDF parameters")?;
    Argon2::new(Algorithm::Argon2id, Version::V0x13, params)
        .hash_password_into(password, &salt, key.as_mut())
        .map_err(|_| "Could not derive vault key")?;
    Ok(key)
}
fn aad(id: &str, expires: i64) -> String {
    format!("spotlight-vault-v1:{id}:{expires}")
}
fn seal(key: &[u8; 32], id: String, expires: i64, text: &[u8]) -> Result<Sealed, String> {
    let nonce = random::<24>()?;
    let cipher = XChaCha20Poly1305::new(key.into());
    let ciphertext = cipher
        .encrypt(
            XNonce::from_slice(&nonce),
            AeadPayload {
                msg: text,
                aad: aad(&id, expires).as_bytes(),
            },
        )
        .map_err(|_| "Could not encrypt pin")?;
    Ok(Sealed {
        id,
        expires,
        nonce: B64.encode(nonce),
        ciphertext: B64.encode(ciphertext),
    })
}
fn unseal(key: &[u8; 32], sealed: &Sealed) -> Result<Zeroizing<Vec<u8>>, String> {
    let nonce = B64
        .decode(&sealed.nonce)
        .map_err(|_| "Invalid encrypted pin")?;
    if nonce.len() != 24 {
        return Err("Invalid encrypted pin nonce".into());
    }
    let ciphertext = B64
        .decode(&sealed.ciphertext)
        .map_err(|_| "Invalid encrypted pin")?;
    XChaCha20Poly1305::new(key.into())
        .decrypt(
            XNonce::from_slice(&nonce),
            AeadPayload {
                msg: &ciphertext,
                aad: aad(&sealed.id, sealed.expires).as_bytes(),
            },
        )
        .map(Zeroizing::new)
        .map_err(|_| "Wrong master password or damaged vault".into())
}
impl Vault {
    pub fn new(path: PathBuf) -> Self {
        Self {
            next_prune: std::cell::Cell::new(0),
            path,
            key: None,
            salt: None,
            deadline: None,
        }
    }
    pub fn exists(&self) -> bool {
        self.path.exists()
    }
    pub fn unlocked(&self) -> bool {
        self.key.is_some() && self.deadline.is_some_and(|d| Instant::now() < d)
    }
    pub fn lock(&mut self) {
        self.key.take();
        self.salt.take();
        self.deadline.take();
    }
    fn load(&self) -> Result<Option<Envelope>, String> {
        let file = match fs::OpenOptions::new()
            .read(true)
            .custom_flags(libc::O_NOFOLLOW | libc::O_NONBLOCK)
            .open(&self.path)
        {
            Ok(f) => f,
            Err(e) if e.kind() == std::io::ErrorKind::NotFound => return Ok(None),
            Err(_) => return Err("Cannot open encrypted clipboard vault".into()),
        };
        let metadata = file.metadata().map_err(|_| "Cannot read vault metadata")?;
        if !metadata.is_file() || metadata.len() > LIMIT {
            return Err("Vault is not a regular file or exceeds 48 MiB".into());
        }
        let mut bytes = Vec::new();
        file.take(LIMIT + 1)
            .read_to_end(&mut bytes)
            .map_err(|_| "Cannot read vault")?;
        if bytes.len() as u64 > LIMIT {
            return Err("Vault exceeds 48 MiB".into());
        }
        let value: Envelope = serde_json::from_slice(&bytes)
            .map_err(|_| "Encrypted vault is unreadable · it has not been replaced")?;
        if value.version != 1 || value.pins.len() > 50 {
            return Err("Unsupported vault version or entry count".into());
        }
        Ok(Some(value))
    }
    fn save(&self, value: &Envelope) -> Result<(), String> {
        self.next_prune.set(0);
        let bytes = serde_json::to_vec(value).map_err(|_| "Cannot encode encrypted vault")?;
        if bytes.len() as u64 > LIMIT {
            return Err("Encrypted vault exceeds 48 MiB · remove some pins".into());
        }
        let parent = self.path.parent().ok_or("Invalid vault path")?;
        if !parent.exists() {
            fs::DirBuilder::new()
                .recursive(true)
                .mode(0o700)
                .create(parent)
                .map_err(|e| e.to_string())?;
        }
        let temp = parent.join(format!(".vault-{}.tmp", gtk::glib::uuid_string_random()));
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
            fs::rename(&temp, &self.path).map_err(|e| e.to_string())
        })();
        if result.is_err() {
            let _ = fs::remove_file(temp);
        }
        result
    }
    pub fn unlock(&mut self, password: &[u8], create: bool) -> Result<(), String> {
        self.lock();
        let existing = self.load()?;
        let value = if let Some(value) = existing {
            value
        } else {
            if !create {
                return Err("Create the clipboard vault first".into());
            }
            let salt = B64.encode(random::<16>()?);
            let key = derive(password, &salt)?;
            let value = Envelope {
                version: 1,
                salt,
                check: seal(&key, "check".into(), 0, CHECK)?,
                pins: Vec::new(),
            };
            self.save(&value)?;
            value
        };
        let key = derive(password, &value.salt)?;
        if unseal(&key, &value.check)?.as_slice() != CHECK {
            return Err("Wrong master password or damaged vault".into());
        }
        self.key = Some(key);
        self.salt = Some(value.salt);
        self.deadline = Some(Instant::now() + Duration::from_secs(3600));
        self.prune(now())?;
        Ok(())
    }
    fn current(&self) -> Result<Envelope, String> {
        if !self.unlocked() {
            return Err("Unlock the clipboard vault first".into());
        }
        let value = self.load()?.ok_or("Clipboard vault was removed")?;
        if Some(&value.salt) != self.salt.as_ref() {
            return Err("Vault changed · lock and unlock again".into());
        }
        Ok(value)
    }
    pub fn add(&mut self, payload: &Payload, at: i64) -> Result<String, String> {
        self.add_batch(std::slice::from_ref(payload), at)
            .map(|mut ids| ids.remove(0))
    }
    pub fn add_batch(&mut self, payloads: &[Payload], at: i64) -> Result<Vec<String>, String> {
        let mut value = self.current()?;
        value.pins.retain(|p| p.expires > at);
        let mut ids = Vec::new();
        for payload in payloads {
            payload.validate()?;
            let bytes =
                Zeroizing::new(serde_json::to_vec(payload).map_err(|_| "Could not encode pin")?);
            if let Some(index) = value.pins.iter().position(|pin| {
                unseal(self.key.as_ref().unwrap(), pin)
                    .is_ok_and(|old| old.as_slice() == bytes.as_slice())
            }) {
                let id = value.pins[index].id.clone();
                value.pins[index] = seal(
                    self.key.as_ref().unwrap(),
                    id.clone(),
                    at.checked_add(LIFETIME).ok_or("Invalid pin expiry")?,
                    &bytes,
                )?;
                ids.push(id);
                continue;
            }
            if value.pins.len() >= 50 {
                return Err("Secure vault holds at most 50 pins".into());
            }
            let id = gtk::glib::uuid_string_random().to_string();
            let sealed = seal(
                self.key.as_ref().unwrap(),
                id.clone(),
                at.checked_add(LIFETIME).ok_or("Invalid pin expiry")?,
                &bytes,
            )?;
            value.pins.insert(0, sealed);
            ids.push(id);
        }
        self.save(&value)?;
        Ok(ids)
    }
    pub fn read(&self, id: &str, at: i64) -> Result<Payload, String> {
        let value = self.current()?;
        let pin = value
            .pins
            .iter()
            .find(|p| p.id == id && p.expires > at)
            .ok_or("Pin expired or was removed")?;
        serde_json::from_slice(&unseal(self.key.as_ref().unwrap(), pin)?)
            .map_err(|_| "Invalid encrypted pin payload".into())
    }
    pub fn snapshot(&self, at: i64) -> Result<Vec<OpenPin>, String> {
        let value = self.current()?;
        Ok(value
            .pins
            .into_iter()
            .filter(|pin| pin.expires > at)
            .map(|pin| {
                let payload = unseal(self.key.as_ref().unwrap(), &pin).and_then(|bytes| {
                    serde_json::from_slice(&bytes)
                        .map_err(|_| "Invalid encrypted pin payload".into())
                });
                (pin.id, pin.expires, payload)
            })
            .collect())
    }
    #[cfg(test)]
    pub fn entries(&self, at: i64) -> Result<Vec<(String, i64)>, String> {
        Ok(self
            .load()?
            .map(|v| {
                v.pins
                    .into_iter()
                    .filter(|p| p.expires > at)
                    .map(|p| (p.id, p.expires))
                    .collect()
            })
            .unwrap_or_default())
    }
    pub fn remove(&mut self, id: &str) -> Result<(), String> {
        let mut value = self.current()?;
        value.pins.retain(|p| p.id != id);
        self.save(&value)
    }
    pub fn prune(&mut self, at: i64) -> Result<bool, String> {
        let locked = self.deadline.is_some_and(|d| Instant::now() >= d);
        if locked {
            self.lock();
        }
        if at < self.next_prune.get() {
            return Ok(locked);
        }
        let loaded = match self.load() {
            Ok(v) => v,
            Err(e) => {
                self.next_prune.set(at + 60);
                return Err(e);
            }
        };
        let Some(mut value) = loaded else {
            self.next_prune.set(at + 3600);
            return Ok(locked);
        };
        let previous = value.pins.len();
        value.pins.retain(|p| p.expires > at);
        let changed = previous != value.pins.len();
        if changed {
            self.save(&value)?;
        }
        self.next_prune.set(
            value
                .pins
                .iter()
                .map(|p| p.expires)
                .min()
                .unwrap_or(at + 3600),
        );
        Ok(changed || locked)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn encryption_expiry_tampering_and_wrong_password() {
        let folder = std::env::temp_dir().join(format!(
            "spotlight-vault-{}",
            gtk::glib::uuid_string_random()
        ));
        let path = folder.join("vault.json");
        let mut vault = Vault::new(path.clone());
        vault.unlock(b"a long test master password", true).unwrap();
        let at = now();
        let text = Payload::Text("PRIVATE_PIN_FIXTURE".into());
        let id = vault.add(&text, at).unwrap();
        let image = Payload::Image(b"PRIVATE_IMAGE_FIXTURE".to_vec());
        vault.add(&image, at).unwrap();
        let encrypted = fs::read_to_string(&path).unwrap();
        assert!(!encrypted.contains("PRIVATE"));
        assert!(
            matches!(vault.read(&id, at).unwrap(), Payload::Text(ref text) if text == "PRIVATE_PIN_FIXTURE")
        );
        assert!(vault.read(&id, at + 3600).is_err());
        vault.lock();
        assert!(vault.read(&id, at).is_err());
        assert!(vault.unlock(b"wrong", false).is_err());
        assert_eq!(fs::read_to_string(&path).unwrap(), encrypted);
        vault.unlock(b"a long test master password", false).unwrap();
        let mut value: Envelope = serde_json::from_str(&encrypted).unwrap();
        value.pins.iter_mut().find(|p| p.id == id).unwrap().expires += 100;
        fs::write(&path, serde_json::to_vec(&value).unwrap()).unwrap();
        assert!(vault.read(&id, at).is_err());
        fs::write(&path, encrypted).unwrap();
        vault.lock();
        assert!(vault.prune(at + 3600).unwrap());
        assert!(vault.entries(at + 3600).unwrap().is_empty());
        fs::remove_dir_all(folder).unwrap();
    }
}
