const fs = require('fs');
let content = fs.readFileSync('lib/providers/task_provider.dart', 'utf8');
content = content.replace(/_storage/g, '_repository');
content = content.replace(/FirebaseStorageService/g, 'FirebaseTaskRepository');
fs.writeFileSync('lib/providers/task_provider.dart', content);
