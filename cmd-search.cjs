const { execSync } = require('child_process');
const commands = ['flutter', 'dart', 'npm', 'node'];
commands.forEach(cmd => {
  try {
    const loc = execSync(`which ${cmd}`, { encoding: 'utf-8' }).trim();
    console.log(`${cmd}: ${loc}`);
    const ver = execSync(`${cmd} --version`, { encoding: 'utf-8' }).trim();
    console.log(`${cmd} version: ${ver}`);
  } catch (e) {
    console.log(`${cmd}: NOT FOUND`);
  }
});
