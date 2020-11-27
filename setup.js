var exec = require('child_process').exec;
function installAPT(){
    const core = require('@actions/core');
    const time = (new Date()).toTimeString();
    core.setOutput("time", time);
    // Time End
    const packages = core.getInput('MOREPACKAGE')
    var aptrepo = exec(`bash ${__dirname}/src/install.sh`, { maxBuffer: Infinity});
    aptrepo.stdout.on('data', function (data) {
        console.log(data);
    });
    aptrepo.on('exit', function (code) {
        if (code == 0) {
            // console.log('Apt Packages Install Sucess')
            console.log('Alt sucess')
        } else {
            core.setFailed('exit with code: '+code);
        }
    });
}
console.log(`Process ${process.cwd()},\n Dirname ${__dirname}\n\n\n`)
var npmi = exec(`cd ${__dirname} && pwd && npm install`, {detached: false,shell: true});
console.log('Node Modules install')
// npmi.stdout.on('data', function (data) {
//     console.log(data)
// });
npmi.on('exit', function (code) {
    if (code == 0) {
        console.log('NPM install Sucess')
        installAPT();
    } else {
        console.log('npm left with an error, code: '+code);
    }
});
