const { execSync } = require('child_process');
try {
  const output = execSync('dart --version', { encoding: 'utf-8' });
  console.log(output);
} catch (e) {
  console.error('Error:', e.message);
  if (e.stdout) console.log('Stdout:', e.stdout);
  if (e.stderr) console.log('Stderr:', e.stderr);
}
