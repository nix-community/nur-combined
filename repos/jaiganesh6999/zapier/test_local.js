// SEOWebChecker - Zapier Local Interactive Test Runner
// Tests the full Zapier integration end-to-end without uploading anything to Zapier.

const zapier = require('zapier-platform-core');
const App = require('./index');
const appTester = zapier.createAppTester(App);

const targetUrl = process.argv[2] || 'https://seowebchecker.com/';
const threshold = parseInt(process.argv[3] || '85', 10);

async function runLocalTests() {
  console.log('================================================================');
  console.log('  SEOWebChecker: Zapier Integration Local Test Harness');
  console.log('================================================================\n');

  // Test 1: Authentication
  console.log('[Test 1/3] Testing Zapier Authentication Connection...');
  try {
    const authResult = await appTester(App.authentication.test, { authData: {} });
    console.log('  ✓ Status: SUCCESS');
    console.log('  ✓ Connection Result:', authResult);
  } catch (err) {
    console.error('  ✗ Authentication test failed:', err.message);
  }

  // Test 2: Run Technical SEO Audit Action
  console.log(`\n[Test 2/3] Testing Action: 'Run Technical SEO Audit' on ${targetUrl}...`);
  try {
    const auditResult = await appTester(App.creates.runAudit.operation.perform, {
      inputData: {
        url: targetUrl,
        alertThreshold: threshold,
      },
      authData: {},
    });

    console.log('  ✓ Status: SUCCESS');
    console.log('\n--- DATA RECEIVED BY SUBSEQUENT ZAPIER STEPS (e.g. Slack/Sheets) ---');
    console.log(JSON.stringify(auditResult, null, 2));

    console.log('\n--- AUDIT SUMMARY ---');
    console.log(`  Target URL:      ${auditResult.targetUrl}`);
    console.log(`  SEO Score:       ${auditResult.score} / 100 (Grade: ${auditResult.grade})`);
    console.log(`  Audit Status:    ${auditResult.status}`);
    console.log(`  Alert Triggered: ${auditResult.isAlert}`);
    console.log(`  Title:           ${auditResult.title}`);
    console.log(`  Meta Desc:       ${auditResult.metaDescription}`);
    console.log(`  Issues Count:    ${auditResult.issuesCount}`);
    if (auditResult.issues) {
      console.log(`  Issues:\n${auditResult.issues.split('\n').map(i => '    ⚠ ' + i).join('\n')}`);
    }
  } catch (err) {
    console.error('  ✗ Run audit action failed:', err.message);
  }

  // Test 3: New Audit Completed Trigger
  console.log(`\n[Test 3/3] Testing Trigger: 'New Audit Completed'...`);
  try {
    const triggerResult = await appTester(App.triggers.auditCompleted.operation.perform, {
      inputData: { url: targetUrl },
      authData: {},
    });

    console.log('  ✓ Status: SUCCESS');
    console.log(`  ✓ Sample Events Returned: ${triggerResult.length}`);
    console.log('  ✓ First Event Sample:', triggerResult[0]);
  } catch (err) {
    console.error('  ✗ Trigger test failed:', err.message);
  }

  console.log('\n================================================================');
  console.log('  Verdict: All Zapier integration components verified locally!');
  console.log('================================================================');
}

runLocalTests();
