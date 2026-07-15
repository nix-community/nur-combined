import puppeteer from 'puppeteer';
import http from 'http';
import fs from 'fs';
import path from 'path';

const mimeTypes = {
  '.html': 'text/html',
  '.js': 'text/javascript',
  '.css': 'text/css',
};

const server = http.createServer((req, res) => {
  let filePath = './dist' + req.url;
  if (filePath === './dist/') filePath = './dist/index.html';
  const extname = String(path.extname(filePath)).toLowerCase();
  const contentType = mimeTypes[extname] || 'application/octet-stream';

  fs.readFile(filePath, (error, content) => {
    if (error) {
      res.writeHead(404);
      res.end('Not found');
    } else {
      res.writeHead(200, { 'Content-Type': contentType });
      res.end(content, 'utf-8');
    }
  });
});

server.listen(8080, async () => {
  console.log('Server running');
  const browser = await puppeteer.launch({ headless: true, args: ['--no-sandbox'] });
  const page = await browser.newPage();
  
  page.on('console', msg => console.log('PAGE LOG:', msg.text()));
  page.on('pageerror', error => console.log('PAGE ERROR:', error.message));

  await page.goto('http://localhost:8080');
  await new Promise(r => setTimeout(r, 1000)); //(1000);
  
  console.log('Clicking localhost...');
  // Find the div containing 'localhost' and click it
  await page.evaluate(() => {
    const els = Array.from(document.querySelectorAll('div'));
    const localHostBtn = els.find(el => el.textContent.includes('localhost') && el.textContent.includes('→'));
    if (localHostBtn) localHostBtn.click();
  });

  await new Promise(r => setTimeout(r, 1000)); //(1000);
  console.log('Done waiting. Checking terminal...');
  
  const termText = await page.evaluate(() => {
    return document.querySelector('.xterm-rows') ? document.querySelector('.xterm-rows').textContent : 'NO TERMINAL';
  });
  console.log('Terminal text:', termText);

  await browser.close();
  server.close();
});
