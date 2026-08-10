const http = require('node:http')
const path = require('node:path')
const express = require('express')
const proxy = require('express-http-proxy')

const app = express()
const backendHost = process.env.MOVIEPILOT_BACKEND_HOST || '127.0.0.1'
const backendPort = Number(process.env.PORT || 3001)
const frontendPort = Number(process.env.NGINX_PORT || 3000)
const backendHealthPath = '/api/v1/system/global?token=moviepilot'
const backendHealthTimeoutMs = Number(process.env.MOVIEPILOT_FRONTEND_HEALTH_TIMEOUT_MS || 3000)
const backendHealthIntervalMs = Number(process.env.MOVIEPILOT_FRONTEND_HEALTH_INTERVAL_MS || 15000)
const backendMaxFailures = Math.max(
  Number(process.env.MOVIEPILOT_FRONTEND_MAX_FAILURES || 4),
  1
)

function sleep (ms) {
  return new Promise(resolve => setTimeout(resolve, ms))
}

function checkBackendHealth () {
  return new Promise(resolve => {
    const request = http.request(
      {
        host: backendHost,
        port: backendPort,
        path: backendHealthPath,
        method: 'GET',
        timeout: backendHealthTimeoutMs
      },
      response => {
        let body = ''
        response.setEncoding('utf8')
        response.on('data', chunk => {
          body += chunk
        })
        response.on('end', () => {
          if (response.statusCode !== 200) {
            resolve(false)
            return
          }

          try {
            const payload = JSON.parse(body)
            resolve(payload?.success !== false)
          } catch (error) {
            resolve(true)
          }
        })
      }
    )

    request.on('timeout', () => {
      request.destroy(new Error('backend health check timeout'))
    })
    request.on('error', () => {
      resolve(false)
    })
    request.end()
  })
}

async function waitForBackendReady () {
  for (let attempt = 1; attempt <= backendMaxFailures; attempt += 1) {
    if (await checkBackendHealth()) {
      return true
    }

    if (attempt < backendMaxFailures) {
      await sleep(1000)
    }
  }
  return false
}

function startBackendWatchdog (server) {
  let consecutiveFailures = 0
  let checking = false

  const timer = setInterval(async () => {
    if (checking) {
      return
    }

    checking = true
    try {
      const healthy = await checkBackendHealth()
      if (healthy) {
        consecutiveFailures = 0
        return
      }

      consecutiveFailures += 1
      console.warn(
        `Backend health check failed (${consecutiveFailures}/${backendMaxFailures})`
      )

      if (consecutiveFailures < backendMaxFailures) {
        return
      }

      clearInterval(timer)
      console.error('Backend is unavailable, stopping frontend service')
      server.close(() => process.exit(1))
      setTimeout(() => process.exit(1), 1000).unref()
    } finally {
      checking = false
    }
  }, backendHealthIntervalMs)

  timer.unref()

  const shutdown = signal => {
    clearInterval(timer)
    console.log(`Received ${signal}, shutting down frontend service`)
    server.close(() => process.exit(0))
    setTimeout(() => process.exit(0), 1000).unref()
  }

  process.on('SIGINT', () => shutdown('SIGINT'))
  process.on('SIGTERM', () => shutdown('SIGTERM'))
}

app.use(express.static(__dirname))

app.use(
  '/api',
  proxy(`${backendHost}:${backendPort}`, {
    proxyReqPathResolver: req => `/api${req.url}`
  })
)

app.use(
  '/cookiecloud',
  proxy(`${backendHost}:${backendPort}`, {
    proxyReqPathResolver: req => `/cookiecloud${req.url}`
  })
)

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'))
})

app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'))
})

async function bootstrap () {
  const backendReady = await waitForBackendReady()
  if (!backendReady) {
    console.error('Backend is unavailable, skip starting frontend service')
    process.exit(1)
  }

  const server = app.listen(frontendPort, () => {
    console.log(`Server is running on port ${frontendPort}`)
  })

  startBackendWatchdog(server)
}

bootstrap().catch(error => {
  console.error(`Failed to start frontend service: ${error?.message || error}`)
  process.exit(1)
})
