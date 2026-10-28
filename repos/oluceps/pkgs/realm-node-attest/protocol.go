package nodeattest

import (
	"bytes"
	"crypto/ed25519"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"regexp"
	"strings"
	"time"

	jose "github.com/go-jose/go-jose/v4"
)

const (
	PluginName      = "http_fqdn"
	PathPrefix      = "/.well-known/spire-node-attestation/v1/"
	DefaultPort     = 18091
	MaxDocumentSize = 8192
	ChallengeTTL    = 120 * time.Second
	proofType       = "spire-http-node-attestation+jws"
)

var labelPattern = regexp.MustCompile(`^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$`)

type AgentConfig struct {
	FQDN           string `json:"fqdn"`
	TrustDomain    string `json:"trust_domain"`
	ControlSocket  string `json:"control_socket"`
	MetricsAddress string `json:"metrics_address,omitempty"`
}

type NodePolicy struct {
	FQDN      string   `json:"fqdn"`
	Addresses []string `json:"addresses"`
}

type ServerConfig struct {
	TrustDomain        string                `json:"trust_domain"`
	Nodes              map[string]NodePolicy `json:"nodes"`
	Port               int                   `json:"port"`
	TrustHTTPTransport bool                  `json:"trust_http_transport"`
	MetricsAddress     string                `json:"metrics_address,omitempty"`
}

type Result struct {
	AgentID        string
	SelectorValues []string
}

type publicJWK struct {
	Kty string `json:"kty"`
	Crv string `json:"crv"`
	X   string `json:"x"`
}

type request struct {
	Version      int       `json:"version"`
	FQDN         string    `json:"fqdn"`
	BootstrapJWK publicJWK `json:"bootstrap_jwk"`
}

type challenge struct {
	Version       int    `json:"version"`
	ID            string `json:"challenge_id"`
	Nonce         string `json:"nonce"`
	FQDN          string `json:"fqdn"`
	TrustDomain   string `json:"trust_domain"`
	ServerID      string `json:"server_id"`
	KeyThumbprint string `json:"bootstrap_key_thumbprint"`
	ExpiresAt     int64  `json:"expires_at"`
}

type ready struct {
	Version int    `json:"version"`
	ID      string `json:"challenge_id"`
}

type proofDocument struct {
	BootstrapJWK publicJWK `json:"bootstrap_jwk"`
	Proof        string    `json:"proof"`
}

func validFQDN(value string) bool {
	if len(value) > 253 || !strings.Contains(value, ".") {
		return false
	}
	for _, label := range strings.Split(value, ".") {
		if !labelPattern.MatchString(label) {
			return false
		}
	}
	return true
}

func serverID(domain string) string { return "spiffe://" + domain + "/spire/server" }

func decodeJSON(data []byte, target any) error {
	if len(data) == 0 || len(data) > MaxDocumentSize {
		return errors.New("invalid document size")
	}
	decoder := json.NewDecoder(bytes.NewReader(data))
	decoder.DisallowUnknownFields()
	if err := decoder.Decode(target); err != nil {
		return errors.New("invalid document")
	}
	var extra any
	if err := decoder.Decode(&extra); err != io.EOF {
		return errors.New("trailing document data")
	}
	return nil
}

func randomValue() (string, error) {
	value := make([]byte, 32)
	if _, err := rand.Read(value); err != nil {
		return "", err
	}
	return base64.RawURLEncoding.EncodeToString(value), nil
}

func validRandom(value string) bool {
	decoded, err := base64.RawURLEncoding.Strict().DecodeString(value)
	return err == nil && len(decoded) == 32 && base64.RawURLEncoding.EncodeToString(decoded) == value
}

func jwkFor(key ed25519.PublicKey) publicJWK {
	return publicJWK{Kty: "OKP", Crv: "Ed25519", X: base64.RawURLEncoding.EncodeToString(key)}
}

func (j publicJWK) key() (ed25519.PublicKey, error) {
	if j.Kty != "OKP" || j.Crv != "Ed25519" {
		return nil, errors.New("unsupported bootstrap key")
	}
	key, err := base64.RawURLEncoding.Strict().DecodeString(j.X)
	if err != nil || len(key) != ed25519.PublicKeySize || base64.RawURLEncoding.EncodeToString(key) != j.X {
		return nil, errors.New("invalid bootstrap key")
	}
	return ed25519.PublicKey(key), nil
}

func (j publicJWK) thumbprint() string {
	// RFC 7638 requires these members in lexicographic order.
	canonical, _ := json.Marshal(struct {
		Crv string `json:"crv"`
		Kty string `json:"kty"`
		X   string `json:"x"`
	}{j.Crv, j.Kty, j.X})
	hash := sha256.Sum256(canonical)
	return base64.RawURLEncoding.EncodeToString(hash[:])
}

func validateChallenge(c challenge, now time.Time) error {
	if c.Version != 1 || !validRandom(c.ID) || !validRandom(c.Nonce) || !validFQDN(c.FQDN) || !validFQDN(c.TrustDomain) ||
		c.ServerID != serverID(c.TrustDomain) || !validRandom(c.KeyThumbprint) {
		return errors.New("invalid challenge")
	}
	if c.ExpiresAt <= now.Unix() || c.ExpiresAt > now.Add(ChallengeTTL).Unix() {
		return errors.New("challenge outside validity window")
	}
	return nil
}

func signProof(key ed25519.PrivateKey, rawChallenge []byte) ([]byte, error) {
	signer, err := jose.NewSigner(jose.SigningKey{Algorithm: jose.EdDSA, Key: key}, (&jose.SignerOptions{}).WithType(proofType))
	if err != nil {
		return nil, err
	}
	object, err := signer.Sign(rawChallenge)
	if err != nil {
		return nil, err
	}
	compact, err := object.CompactSerialize()
	if err != nil {
		return nil, err
	}
	return json.Marshal(proofDocument{BootstrapJWK: jwkFor(key.Public().(ed25519.PublicKey)), Proof: compact})
}

func verifyProof(data []byte, expectedKey publicJWK) ([]byte, error) {
	var document proofDocument
	if err := decodeJSON(data, &document); err != nil {
		return nil, err
	}
	if document.BootstrapJWK != expectedKey {
		return nil, errors.New("bootstrap key mismatch")
	}
	key, err := expectedKey.key()
	if err != nil {
		return nil, err
	}
	if strings.Count(document.Proof, ".") != 2 {
		return nil, errors.New("compact JWS required")
	}
	object, err := jose.ParseSigned(document.Proof, []jose.SignatureAlgorithm{jose.EdDSA})
	if err != nil || len(object.Signatures) != 1 {
		return nil, errors.New("invalid JWS")
	}
	if object.Signatures[0].Protected.ExtraHeaders[jose.HeaderKey("typ")] != proofType {
		return nil, errors.New("invalid proof type")
	}
	payload, err := object.Verify(key)
	if err != nil {
		return nil, errors.New("invalid proof signature")
	}
	if len(payload) > MaxDocumentSize {
		return nil, errors.New("proof payload too large")
	}
	return payload, nil
}

func parseProof(data []byte, fqdn string, now time.Time) (challenge, error) {
	var document proofDocument
	if err := decodeJSON(data, &document); err != nil {
		return challenge{}, err
	}
	payload, err := verifyProof(data, document.BootstrapJWK)
	if err != nil {
		return challenge{}, err
	}
	var c challenge
	if err := decodeJSON(payload, &c); err != nil {
		return challenge{}, err
	}
	if err := validateChallenge(c, now); err != nil {
		return challenge{}, err
	}
	if c.FQDN != fqdn || c.KeyThumbprint != document.BootstrapJWK.thumbprint() {
		return challenge{}, fmt.Errorf("proof does not match responder")
	}
	return c, nil
}
