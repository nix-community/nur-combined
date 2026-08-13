//! Ed25519 identity for P2P actions. Fingerprints stay for logs; this proves who sent them.

use ed25519_dalek::{Signature, Signer, SigningKey, VerifyingKey};
use rand::rngs::OsRng;
use std::fs;
use std::io::{self, Write};
use std::path::{Path, PathBuf};

pub const PUBLIC_LEN: usize = 32;
pub const SIGNATURE_LEN: usize = 64;
pub const SEED_LEN: usize = 32;

#[derive(Clone)]
pub struct ActionKey {
    signing: SigningKey,
}

impl ActionKey {
    pub fn generate() -> Self {
        Self {
            signing: SigningKey::generate(&mut OsRng),
        }
    }

    pub fn from_seed(seed: [u8; SEED_LEN]) -> Self {
        Self {
            signing: SigningKey::from_bytes(&seed),
        }
    }

    pub fn public_bytes(&self) -> [u8; PUBLIC_LEN] {
        self.signing.verifying_key().to_bytes()
    }

    pub fn sign(&self, message: &[u8]) -> [u8; SIGNATURE_LEN] {
        self.signing.sign(message).to_bytes()
    }
}

/// Verify `signature` over `message` for `public`. Unknown/short keys fail closed.
pub fn verify_signed(
    public: &[u8],
    message: &[u8],
    signature: &[u8],
) -> bool {
    let Ok(public) = <[u8; PUBLIC_LEN]>::try_from(public) else {
        return false;
    };
    let Ok(signature) = <[u8; SIGNATURE_LEN]>::try_from(signature) else {
        return false;
    };
    let Ok(key) = VerifyingKey::from_bytes(&public) else {
        return false;
    };
    let sig = Signature::from_bytes(&signature);
    key.verify_strict(message, &sig).is_ok()
}

/// `HANGA_PEER_KEY` or `~/.config/hanga/peer.key` (32 raw bytes). Created on first use.
pub fn resolve_peer_key_path(args: &[String]) -> PathBuf {
    if let Some(path) = args.windows(2).find(|w| w[0] == "--peer-key").map(|w| w[1].clone()) {
        return PathBuf::from(path);
    }
    if let Ok(path) = std::env::var("HANGA_PEER_KEY") {
        return PathBuf::from(path);
    }
    let base = std::env::var("XDG_CONFIG_HOME")
        .map(PathBuf::from)
        .or_else(|_| std::env::var("HOME").map(|home| PathBuf::from(home).join(".config")))
        .unwrap_or_else(|_| PathBuf::from("."));
    base.join("hanga").join("peer.key")
}

pub fn load_or_create_key(path: &Path) -> io::Result<ActionKey> {
    match fs::read(path) {
        Ok(bytes) if bytes.len() == SEED_LEN => {
            let mut seed = [0u8; SEED_LEN];
            seed.copy_from_slice(&bytes);
            Ok(ActionKey::from_seed(seed))
        }
        Ok(_) => Err(io::Error::new(
            io::ErrorKind::InvalidData,
            "peer.key must be 32 bytes",
        )),
        Err(err) if err.kind() == io::ErrorKind::NotFound => {
            let key = ActionKey::generate();
            persist_seed(path, &key.signing.to_bytes())?;
            Ok(key)
        }
        Err(err) => Err(err),
    }
}

fn persist_seed(path: &Path, seed: &[u8; SEED_LEN]) -> io::Result<()> {
    if let Some(dir) = path.parent() {
        fs::create_dir_all(dir)?;
    }
    let mut file = fs::File::create(path)?;
    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        file.set_permissions(fs::Permissions::from_mode(0o600))?;
    }
    file.write_all(seed)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn roundtrip_signature() {
        let key = ActionKey::from_seed([7u8; 32]);
        let msg = b"break:4,5,6";
        let sig = key.sign(msg);
        assert!(verify_signed(&key.public_bytes(), msg, &sig));
        assert!(!verify_signed(&key.public_bytes(), b"other", &sig));
        let mut bad = sig;
        bad[0] ^= 1;
        assert!(!verify_signed(&key.public_bytes(), msg, &bad));
    }

    #[test]
    fn other_key_cannot_verify() {
        let a = ActionKey::from_seed([1u8; 32]);
        let b = ActionKey::from_seed([2u8; 32]);
        let sig = a.sign(b"place");
        assert!(!verify_signed(&b.public_bytes(), b"place", &sig));
    }

    #[test]
    fn peer_key_flag_reads_path() {
        let args = vec!["hanga".into(), "--peer-key".into(), "/tmp/peer.key".into()];
        assert_eq!(resolve_peer_key_path(&args), PathBuf::from("/tmp/peer.key"));
    }

    #[test]
    fn persist_and_reload_seed() {
        let dir = std::env::temp_dir().join(format!("hanga-peer-{}", std::process::id()));
        let path = dir.join("peer.key");
        let key = ActionKey::from_seed([9u8; 32]);
        persist_seed(&path, &key.signing.to_bytes()).unwrap();
        let loaded = load_or_create_key(&path).unwrap();
        assert_eq!(loaded.public_bytes(), key.public_bytes());
        let _ = fs::remove_dir_all(&dir);
    }
}
