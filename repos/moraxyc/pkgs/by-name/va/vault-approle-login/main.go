package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"
)

var version = "dev"

type vaultClient struct {
	address   string
	namespace string
	http      *http.Client
}

type loginResponse struct {
	Auth struct {
		ClientToken string `json:"client_token"`
	} `json:"auth"`
}

type secretIDResponse struct {
	Data struct {
		SecretID string `json:"secret_id"`
	} `json:"data"`
}

type vaultError struct {
	Errors []string `json:"errors"`
}

func main() {
	var (
		address             = flag.String("address", env("VAULT_ADDR"), "Vault address, for example https://vault.example.com")
		authPath            = flag.String("auth-path", "auth/approle/login", "Vault AppRole login API path under /v1")
		namespace           = flag.String("namespace", env("VAULT_NAMESPACE"), "Vault namespace for X-Vault-Namespace")
		roleID              = flag.String("role-id", "", "AppRole role_id")
		roleIDFile          = flag.String("role-id-file", "", "File containing AppRole role_id")
		secretID            = flag.String("secret-id", "", "AppRole secret_id; optional when bind_secret_id=false")
		secretIDFile        = flag.String("secret-id-file", "", "File containing AppRole secret_id")
		wrappedSecretIDPath = flag.String("wrapped-secret-id-path", "", "File containing a Vault response-wrapping token for an AppRole secret_id")
		output              = flag.String("output", "", "Output file; stdout when empty")
		modeString          = flag.String("mode", "0600", "File mode for output file")
		raw                 = flag.Bool("raw", false, "Output only the Vault token")
		showVersion         = flag.Bool("version", false, "Show version")
		timeout             = flag.Duration("timeout", 10*time.Second, "HTTP client timeout")
	)
	flag.Parse()

	if *showVersion {
		fmt.Println(version)
		return
	}

	if err := run(config{
		address:             *address,
		authPath:            *authPath,
		namespace:           *namespace,
		roleID:              *roleID,
		roleIDFile:          *roleIDFile,
		secretID:            *secretID,
		secretIDFile:        *secretIDFile,
		wrappedSecretIDPath: *wrappedSecretIDPath,
		output:              *output,
		modeString:          *modeString,
		raw:                 *raw,
		timeout:             *timeout,
	}); err != nil {
		fatal("%v", err)
	}
}

type config struct {
	address             string
	authPath            string
	namespace           string
	roleID              string
	roleIDFile          string
	secretID            string
	secretIDFile        string
	wrappedSecretIDPath string
	output              string
	modeString          string
	raw                 bool
	timeout             time.Duration
}

func run(c config) error {
	address, err := normalizeAddress(c.address)
	if err != nil {
		return err
	}

	roleID, err := valueOrFile(c.roleID, c.roleIDFile)
	if err != nil {
		return fmt.Errorf("read role_id: %w", err)
	}
	if roleID == "" {
		return errors.New("missing -role-id or -role-id-file")
	}

	secretID, err := valueOrFile(c.secretID, c.secretIDFile)
	if err != nil {
		return fmt.Errorf("read secret_id: %w", err)
	}

	mode, err := parseFileMode(c.modeString)
	if err != nil {
		return fmt.Errorf("invalid -mode %q: %w", c.modeString, err)
	}

	client := vaultClient{
		address:   address,
		namespace: strings.Trim(c.namespace, "/"),
		http:      &http.Client{Timeout: c.timeout},
	}

	if c.wrappedSecretIDPath != "" {
		wrappingToken, err := readFile(c.wrappedSecretIDPath)
		if err != nil {
			return fmt.Errorf("read wrapping token: %w", err)
		}
		secretID, err = client.unwrapSecretID(wrappingToken)
		if err != nil {
			return fmt.Errorf("unwrap secret_id: %w", err)
		}
	}

	token, err := client.login(c.authPath, roleID, secretID)
	if err != nil {
		return fmt.Errorf("login to Vault: %w", err)
	}

	content := token + "\n"
	if !c.raw {
		content = "VAULT_TOKEN=" + shellQuote(token) + "\n"
	}

	if c.output == "" {
		fmt.Print(content)
		return nil
	}
	return writeFile(c.output, content, mode)
}

func (c vaultClient) login(authPath, roleID, secretID string) (string, error) {
	payload := map[string]string{"role_id": roleID}
	if secretID != "" {
		payload["secret_id"] = secretID
	}

	var resp loginResponse
	if err := c.post(authPath, "", payload, &resp); err != nil {
		return "", err
	}
	if resp.Auth.ClientToken == "" {
		return "", errors.New("Vault response missing auth.client_token")
	}
	return resp.Auth.ClientToken, nil
}

func (c vaultClient) unwrapSecretID(wrappingToken string) (string, error) {
	wrappingToken = strings.TrimSpace(wrappingToken)
	if wrappingToken == "" {
		return "", errors.New("empty wrapping token")
	}

	var resp secretIDResponse
	if err := c.post("sys/wrapping/unwrap", wrappingToken, nil, &resp); err != nil {
		return "", err
	}
	if resp.Data.SecretID == "" {
		return "", errors.New("unwrap response missing data.secret_id")
	}
	return resp.Data.SecretID, nil
}

func (c vaultClient) post(path, token string, payload any, out any) error {
	var body io.Reader
	if payload != nil {
		b, err := json.Marshal(payload)
		if err != nil {
			return err
		}
		body = bytes.NewReader(b)
	}

	req, err := http.NewRequest(http.MethodPost, c.url(path), body)
	if err != nil {
		return err
	}
	req.Header.Set("Accept", "application/json")
	if payload != nil {
		req.Header.Set("Content-Type", "application/json")
	}
	if token != "" {
		req.Header.Set("X-Vault-Token", token)
	}
	if c.namespace != "" {
		req.Header.Set("X-Vault-Namespace", c.namespace)
	}

	resp, err := c.http.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	data, err := io.ReadAll(resp.Body)
	if err != nil {
		return err
	}
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return vaultAPIError(resp.StatusCode, data)
	}
	if out == nil {
		return nil
	}
	if err := json.Unmarshal(data, out); err != nil {
		return fmt.Errorf("decode Vault response: %w", err)
	}
	return nil
}

func (c vaultClient) url(path string) string {
	path = strings.Trim(path, "/")
	path = strings.TrimPrefix(path, "v1/")
	return c.address + "/v1/" + path
}

func normalizeAddress(address string) (string, error) {
	address = strings.TrimRight(strings.TrimSpace(address), "/")
	if address == "" {
		return "", errors.New("missing -address or VAULT_ADDR")
	}
	if !strings.HasPrefix(address, "http://") && !strings.HasPrefix(address, "https://") {
		return "", errors.New("Vault address must start with http:// or https://")
	}
	return address, nil
}

func valueOrFile(value, file string) (string, error) {
	value = strings.TrimSpace(value)
	if value != "" || file == "" {
		return value, nil
	}
	return readFile(file)
}

func readFile(path string) (string, error) {
	b, err := os.ReadFile(path)
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(string(b)), nil
}

func writeFile(path, content string, mode os.FileMode) error {
	f, err := os.OpenFile(path, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, mode)
	if err != nil {
		return err
	}
	if err := f.Chmod(mode); err != nil {
		_ = f.Close()
		return err
	}
	_, writeErr := io.WriteString(f, content)
	closeErr := f.Close()
	if writeErr != nil {
		return writeErr
	}
	return closeErr
}

func parseFileMode(s string) (os.FileMode, error) {
	s = strings.TrimSpace(strings.TrimPrefix(s, "0o"))
	n, err := strconv.ParseUint(s, 8, 32)
	if err != nil {
		return 0, err
	}
	return os.FileMode(n), nil
}

func vaultAPIError(status int, body []byte) error {
	var e vaultError
	if err := json.Unmarshal(body, &e); err == nil && len(e.Errors) > 0 {
		return fmt.Errorf("Vault API returned HTTP %d: %s", status, strings.Join(e.Errors, "; "))
	}
	msg := strings.TrimSpace(string(body))
	if msg == "" {
		msg = http.StatusText(status)
	}
	return fmt.Errorf("Vault API returned HTTP %d: %s", status, msg)
}

func shellQuote(s string) string {
	return "'" + strings.ReplaceAll(s, "'", `'\''`) + "'"
}

func env(name string) string {
	return strings.TrimSpace(os.Getenv(name))
}

func fatal(format string, args ...any) {
	fmt.Fprintf(os.Stderr, "approle-login: "+format+"\n", args...)
	os.Exit(1)
}
