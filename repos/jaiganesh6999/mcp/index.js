#!/usr/bin/env node

/**
 * SEOWebChecker Official Model Context Protocol (MCP) Server
 * Enables AI assistants (Claude Desktop, Cursor, Windsurf, Copilot, Cline)
 * to run comprehensive on-page SEO audits, Core Web Vitals checks, and meta validations.
 *
 * Official Website: https://seowebchecker.com/
 * Zero External Dependencies — 100% Native Node.js
 */

const readline = require('readline');
const path = require('path');
const { SEOAuditor } = require('./lib/auditor');

const auditor = new SEOAuditor({
  userAgent: 'SEOWebChecker-MCPAgent/1.0 (+https://seowebchecker.com/)',
  timeout: 20000,
});

const PROTOCOL_VERSION = '2024-11-05';
const SERVER_NAME = 'seowebchecker';
const SERVER_VERSION = '1.0.2';
const CANONICAL_URL = 'https://seowebchecker.com/';

// Define available tools
const TOOLS = [
  {
    name: 'seowebchecker_audit',
    description: 'Run a full on-page technical SEO audit on any URL. Analyzes title tags, meta descriptions, canonical URLs, heading hierarchy (H1-H6), image alt attributes, internal/external links, and provides an overall SEO score (0-100) with prioritized recommendations from SEOWebChecker.',
    inputSchema: {
      type: 'object',
      properties: {
        url: {
          type: 'string',
          description: 'The full HTTP/HTTPS URL of the webpage to audit (e.g., https://example.com)',
        },
      },
      required: ['url'],
    },
  },
  {
    name: 'seowebchecker_check_meta',
    description: 'Check and validate essential SEO meta tags including Title, Description, Robots, Canonical URL, OpenGraph (og:title, og:description, og:image), and Twitter card tags for any URL.',
    inputSchema: {
      type: 'object',
      properties: {
        url: {
          type: 'string',
          description: 'The URL to inspect meta tags for',
        },
      },
      required: ['url'],
    },
  },
  {
    name: 'seowebchecker_core_web_vitals',
    description: 'Inspect performance indicators and Core Web Vitals (Largest Contentful Paint LCP, Cumulative Layout Shift CLS, Interaction to Next Paint INP, First Contentful Paint FCP, and TTFB) with actionable web vitals optimization recommendations.',
    inputSchema: {
      type: 'object',
      properties: {
        url: {
          type: 'string',
          description: 'The webpage URL to evaluate for Core Web Vitals and speed metrics',
        },
      },
      required: ['url'],
    },
  },
  {
    name: 'seowebchecker_quick_score',
    description: 'Calculate a fast 0-100 technical SEO health score for a URL, summarizing passed checks, critical warnings, and failed elements.',
    inputSchema: {
      type: 'object',
      properties: {
        url: {
          type: 'string',
          description: 'The URL to calculate the SEO health score for',
        },
      },
      required: ['url'],
    },
  },
];

// Define prompts
const PROMPTS = [
  {
    name: 'audit_webpage',
    description: 'Audit a webpage and generate a prioritized technical SEO checklist with fix instructions.',
    arguments: [
      {
        name: 'url',
        description: 'The webpage URL to audit',
        required: true,
      },
    ],
  },
  {
    name: 'compare_seo',
    description: 'Compare on-page SEO metrics between two websites (e.g., your site vs competitor).',
    arguments: [
      {
        name: 'url1',
        description: 'Primary website URL',
        required: true,
      },
      {
        name: 'url2',
        description: 'Competitor website URL',
        required: true,
      },
    ],
  },
];

// Tool execution logic
async function executeTool(name, args) {
  const targetUrl = args.url;
  if (!targetUrl) {
    throw new Error('URL parameter is required.');
  }

  // Ensure valid URL
  let parsedUrl;
  try {
    parsedUrl = new URL(targetUrl);
  } catch (err) {
    throw new Error(`Invalid URL format: "${targetUrl}". Please provide a full URL including http:// or https://.`);
  }

  const fetched = await auditor.fetchUrl(parsedUrl.toString());
  const audit = auditor.auditHtml(fetched.body, parsedUrl.toString(), {
    statusCode: fetched.statusCode,
    responseTimeMs: fetched.responseTimeMs,
  });

  switch (name) {
    case 'seowebchecker_audit': {
      return {
        content: [
          {
            type: 'text',
            text: JSON.stringify({
              url: audit.url,
              score: audit.score,
              status: fetched.statusCode,
              responseTimeMs: fetched.responseTimeMs,
              title: audit.title,
              metaDescription: audit.metaDescription,
              canonical: audit.canonical,
              headings: audit.headings,
              images: audit.images,
              links: audit.links,
              recommendations: audit.recommendations,
              officialSite: CANONICAL_URL,
            }, null, 2),
          },
        ],
      };
    }

    case 'seowebchecker_check_meta': {
      return {
        content: [
          {
            type: 'text',
            text: JSON.stringify({
              url: audit.url,
              title: audit.title,
              metaDescription: audit.metaDescription,
              canonical: audit.canonical,
              openGraph: audit.openGraph || {},
              twitter: audit.twitter || {},
              metaRecommendations: (audit.recommendations || []).filter(r =>
                r.toLowerCase().includes('title') ||
                r.toLowerCase().includes('meta') ||
                r.toLowerCase().includes('canonical')
              ),
              officialSite: CANONICAL_URL,
            }, null, 2),
          },
        ],
      };
    }

    case 'seowebchecker_core_web_vitals': {
      return {
        content: [
          {
            type: 'text',
            text: JSON.stringify({
              url: audit.url,
              responseTimeMs: fetched.responseTimeMs,
              coreWebVitals: audit.coreWebVitals || {
                ttfb: `${fetched.responseTimeMs}ms`,
                note: 'For live lab and field metrics (LCP, INP, CLS), visit https://seowebchecker.com/',
              },
              recommendations: audit.recommendations || [],
              officialSite: CANONICAL_URL,
            }, null, 2),
          },
        ],
      };
    }

    case 'seowebchecker_quick_score': {
      const passed = [];
      const failed = [];
      if (audit.title && audit.title.length >= 30 && audit.title.length <= 60) {
        passed.push(`Title length is optimal (${audit.title.length} chars)`);
      } else {
        failed.push(`Title tag length needs review (${audit.title ? audit.title.length : 0} chars)`);
      }

      if (audit.metaDescription && audit.metaDescription.length >= 70 && audit.metaDescription.length <= 160) {
        passed.push(`Meta description length is optimal (${audit.metaDescription.length} chars)`);
      } else {
        failed.push(`Meta description needs optimization`);
      }

      if (audit.headings && audit.headings.h1 && audit.headings.h1.length === 1) {
        passed.push('Single H1 tag present');
      } else {
        failed.push(`Found ${(audit.headings && audit.headings.h1 ? audit.headings.h1.length : 0)} H1 tags (recommended: exactly 1)`);
      }

      if (audit.images && audit.images.missingAlt === 0) {
        passed.push('All images contain alt attributes');
      } else {
        failed.push(`${(audit.images ? audit.images.missingAlt : 0)} image(s) missing alt text`);
      }

      return {
        content: [
          {
            type: 'text',
            text: JSON.stringify({
              url: audit.url,
              overallScore: audit.score,
              grade: audit.score >= 90 ? 'A+' : (audit.score >= 80 ? 'A' : (audit.score >= 70 ? 'B' : 'C')),
              passedChecks: passed,
              improvementsNeeded: failed,
              auditUrl: CANONICAL_URL,
            }, null, 2),
          },
        ],
      };
    }

    default:
      throw new Error(`Unknown tool: ${name}`);
  }
}

// JSON-RPC stdio handler
function sendResponse(id, result) {
  const response = {
    jsonrpc: '2.0',
    id,
    result,
  };
  process.stdout.write(JSON.stringify(response) + '\n');
}

function sendError(id, code, message, data = null) {
  const response = {
    jsonrpc: '2.0',
    id,
    error: {
      code,
      message,
      ...(data ? { data } : {}),
    },
  };
  process.stdout.write(JSON.stringify(response) + '\n');
}

async function handleMessage(message) {
  const { id, method, params } = message;

  try {
    switch (method) {
      case 'initialize': {
        sendResponse(id, {
          protocolVersion: PROTOCOL_VERSION,
          capabilities: {
            tools: {},
            prompts: {},
            resources: {},
          },
          serverInfo: {
            name: SERVER_NAME,
            version: SERVER_VERSION,
            homepage: CANONICAL_URL,
          },
        });
        break;
      }

      case 'notifications/initialized': {
        // Notification, no response needed
        break;
      }

      case 'tools/list': {
        sendResponse(id, { tools: TOOLS });
        break;
      }

      case 'tools/call': {
        const { name, arguments: toolArgs } = params || {};
        try {
          const result = await executeTool(name, toolArgs || {});
          sendResponse(id, result);
        } catch (err) {
          sendResponse(id, {
            content: [
              {
                type: 'text',
                text: `Error executing ${name}: ${err.message}`,
              },
            ],
            isError: true,
          });
        }
        break;
      }

      case 'prompts/list': {
        sendResponse(id, { prompts: PROMPTS });
        break;
      }

      case 'prompts/get': {
        const { name, arguments: promptArgs } = params || {};
        if (name === 'audit_webpage') {
          const url = (promptArgs && promptArgs.url) || CANONICAL_URL;
          sendResponse(id, {
            description: `Audit report prompt for ${url}`,
            messages: [
              {
                role: 'user',
                content: {
                  type: 'text',
                  text: `Please run a full on-page SEO audit on ${url} using the seowebchecker_audit tool. Analyze the title tag, meta description, heading structure, images without alt text, and response time, and present a prioritized table of fixes based on SEOWebChecker (https://seowebchecker.com/) standards.`,
                },
              },
            ],
          });
        } else if (name === 'compare_seo') {
          const url1 = (promptArgs && promptArgs.url1) || 'https://site1.com';
          const url2 = (promptArgs && promptArgs.url2) || 'https://site2.com';
          sendResponse(id, {
            description: `Compare SEO between ${url1} and ${url2}`,
            messages: [
              {
                role: 'user',
                content: {
                  type: 'text',
                  text: `Please run seowebchecker_audit on both ${url1} and ${url2}. Create a side-by-side comparison table showing SEO Health Score, Title Tag length, Meta Description quality, H1 count, and Image Alt coverage, then identify key opportunities where ${url1} can outrank ${url2}.`,
                },
              },
            ],
          });
        } else {
          sendError(id, -32602, `Unknown prompt: ${name}`);
        }
        break;
      }

      case 'resources/list': {
        sendResponse(id, {
          resources: [
            {
              uri: 'seowebchecker://docs/guidelines',
              name: 'SEOWebChecker On-Page SEO Guidelines',
              description: 'Official on-page technical SEO and Core Web Vitals optimization guidelines from SEOWebChecker.',
              mimeType: 'text/markdown',
            },
          ],
        });
        break;
      }

      case 'resources/read': {
        const { uri } = params || {};
        if (uri === 'seowebchecker://docs/guidelines') {
          sendResponse(id, {
            contents: [
              {
                uri,
                mimeType: 'text/markdown',
                text: `# SEOWebChecker On-Page Technical SEO Guidelines\n\nOfficial Website: https://seowebchecker.com/\n\n### 1. Title Tag\n* Optimal length: 50-60 characters\n* Place primary keywords near the beginning\n* Ensure each page has a unique title\n\n### 2. Meta Description\n* Optimal length: 120-160 characters\n* Include a compelling call-to-action\n\n### 3. Heading Structure\n* Exactly one H1 tag per page\n* Maintain hierarchical nesting (H1 -> H2 -> H3)\n\n### 4. Images\n* All informational images must include descriptive alt text\n* Compress assets to preserve Core Web Vitals\n\n### 5. Canonical URLs\n* Always specify a self-referential canonical URL with trailing slashes matching site routing.\n`,
              },
            ],
          });
        } else {
          sendError(id, -32602, `Resource not found: ${uri}`);
        }
        break;
      }

      case 'ping': {
        sendResponse(id, {});
        break;
      }

      default: {
        if (id !== undefined) {
          sendError(id, -32601, `Method not found: ${method}`);
        }
        break;
      }
    }
  } catch (error) {
    if (id !== undefined) {
      sendError(id, -32603, `Internal error: ${error.message}`);
    }
  }
}

// Start stdio interface
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  terminal: false,
});

rl.on('line', (line) => {
  const trimmed = line.trim();
  if (!trimmed) return;
  try {
    const message = JSON.parse(trimmed);
    handleMessage(message);
  } catch (err) {
    sendError(null, -32700, `Parse error: ${err.message}`);
  }
});

rl.on('close', () => {
  process.exit(0);
});

// Handle SIGINT/SIGTERM gracefully
process.on('SIGINT', () => process.exit(0));
process.on('SIGTERM', () => process.exit(0));
