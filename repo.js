var exec = require('child_process').exec;
const core = require('@actions/core');
// TIME
const time = (new Date()).toTimeString();
core.setOutput("time", time);
// TIME
// Build
console.log(`Process ${process.cwd()},\n Dirname ${__dirname}\n\n\n`)
var serverstated = exec(`bash ${__dirname}/src/repo.sh`, {detached: false, shell: true, maxBuffer: Infinity});
serverstated.stdout.on('data', function (data) {
    console.log(data)
});
serverstated.on('exit', function (code) {
    if (code == 0) {
        console.log('Sucess')
    } else {
        core.setFailed('Error code: ' + code);
    }
});
