/**
 * Cloud API Client for SEOWebChecker (https://seowebchecker.com/)
 */

const https = require('https');
const http = require('http');
const { URL } = require('url');

class SeoWebCheckerClient {
  constructor(options = {}) {
    this.apiKey = options.apiKey || null;
    this.baseUrl = (options.baseUrl || 'https://seowebchecker.com/api/v1').replace(/\/$/, '');
    this.timeout = options.timeout || 30000;
  }

  request(method, endpoint, data = null) {
    return new Promise((resolve, reject) => {
      const fullUrl = `${this.baseUrl}/${endpoint.replace(/^\//, '')}`;
      const parsed = new URL(fullUrl);
      const client = parsed.protocol === 'https:' ? https : http;

      const postBody = data ? JSON.stringify(data) : null;
      const headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'SEOWebChecker-Node-SDK/1.0.0 (+https://seowebchecker.com/)',
      };
      if (this.apiKey) {
        headers['Authorization'] = `Bearer ${this.apiKey}`;
        headers['X-API-Key'] = this.apiKey;
      }
      if (postBody) {
        headers['Content-Length'] = Buffer.byteLength(postBody);
      }

      const req = client.request(fullUrl, {
        method: method.toUpperCase(),
        headers,
        timeout: this.timeout,
      }, (res) => {
        let body = '';
        res.on('data', chunk => body += chunk);
        res.on('end', () => {
          try {
            const parsedJson = JSON.parse(body);
            if (res.statusCode >= 200 && res.statusCode < 300) {
              resolve(parsedJson);
            } else {
              reject(new Error(parsedJson.message || parsedJson.error || `HTTP ${res.statusCode}`));
            }
          } catch (e) {
            if (res.statusCode >= 200 && res.statusCode < 300) {
              resolve({ raw: body });
            } else {
              reject(new Error(`HTTP ${res.statusCode}: ${body}`));
            }
          }
        });
      });

      req.on('timeout', () => {
        req.destroy();
        reject(new Error(`Timeout connecting to SEOWebChecker API`));
      });
      req.on('error', reject);

      if (postBody) {
        req.write(postBody);
      }
      req.end();
    });
  }

  audit(url, options = {}) {
    return this.request('POST', 'audit', { url, ...options });
  }

  getAudit(auditId) {
    return this.request('GET', `audit/${auditId}`);
  }

  getHistory(limit = 10) {
    return this.request('GET', `audits?limit=${limit}`);
  }
}

module.exports = { SeoWebCheckerClient };
