#!/usr/bin/env node

const path = require('path'),
  chalk = require('chalk');

(async () => {
  // Remove node + ssgjs binaries from arguments
  const args = process.argv.slice(2);

  // Handle help flag
  if (args.includes('--help') || args.includes('-h')) {
    console.log('Help'); // TODO
    process.exit(0);
  }

  // Handle version flag
  if (args.includes('--version') || args.includes('-v')) {
    var packageJson = require(path.join(__dirname, './package.json'));
    console.log('NativeKit CLI version ' + packageJson.version);
    process.exit(0);
  }

  // Handle build command
  if (args.length > 0 && args[0] == 'build') {
    try {
      await require('./build.cmd.js')(process.cwd());
      process.exit(0);
    } catch (err) {
      console.error(chalk.red('[BUILD ERROR]:', err.stack));
      process.exit(1);
    }
  }

  // Handle no valid command being found
  console.log(
    chalk.red("Invalid arguments. Please check '--help' for more details!")
  );
})().catch(console.error);
