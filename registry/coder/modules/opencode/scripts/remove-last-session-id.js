#!/usr/bin/env node

const path = require('path');
const fs = require('fs');
const os = require('os');

// Get the working directory from command line argument
const workingDir = process.argv[2];
if (!workingDir) {
    console.error('Usage: remove-last-session-id.js <working-directory>');
    process.exit(1);
}

// OpenCode config directory
const opencodeConfigDir = path.join(os.homedir(), '.config', 'opencode');
const configFile = path.join(opencodeConfigDir, 'config.json');

try {
    if (!fs.existsSync(configFile)) {
        console.log('OpenCode config file does not exist, nothing to clean up');
        process.exit(0);
    }

    const config = JSON.parse(fs.readFileSync(configFile, 'utf8'));
    
    // Remove the last session ID if it exists
    if (config.lastSessionId) {
        delete config.lastSessionId;
        fs.writeFileSync(configFile, JSON.stringify(config, null, 2));
        console.log('Removed last session ID from OpenCode config');
    } else {
        console.log('No last session ID found in OpenCode config');
    }
} catch (error) {
    console.warn('Failed to clean up OpenCode session:', error.message);
    // Don't exit with error as this is not critical
}