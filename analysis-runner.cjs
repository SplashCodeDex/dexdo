const { execSync } = require('child_process');
try {
  console.log('Running dart analyze...');
  const output = execSync('dart analyze', { encoding: 'utf-8' });
  console.log(output);
} catch (e) {
  console.error('Analysis failed:');
  if (e.stdout) console.log(e.stdout);
  if (e.stderr) console.error(e.stderr);
  process.exit(e.status || 1);
}
