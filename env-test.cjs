const { execSync } = require('child_process');
console.log('PATH:', process.env.PATH);
try {
  const output = execSync('ls -F /', { encoding: 'utf-8' });
  console.log('Root dir:', output);
} catch (e) {}
