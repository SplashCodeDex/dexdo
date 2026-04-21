const https = require('https');
require('dotenv').config();

const TOKEN = process.env.GITHUB_TOKEN;
const REPO = 'SplashCodeDex/dexdo';

const req = https.request({
  hostname: 'api.github.com',
  path: `/repos/${REPO}`,
  method: 'GET',
  headers: {
    'Authorization': `token ${TOKEN}`,
    'User-Agent': 'NodeJS-App',
    'Accept': 'application/vnd.github.v3+json'
  }
}, res => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => console.log('Status:', res.statusCode, 'Body:', data));
});
req.end();
