/*compile script*/

const path = require('path');
const solc = require('solc');   //solidity compiler
const fs = require('fs-extra');    //file system

const buildPath = path.resolve(__dirname,'build'); //set path to ./build
//__dirname-> current working directory
fs.removeSync(buildPath); //delete the entire 'build' folder

const campapignPath = path.resolve(__dirname,'contracts','Campaign.sol');
//read Campaign.sol

const source = fs.readFileSync(campapignPath,'utf8');
const output = solc.compile(source,1).contracts;
//output cotains two objects (one from campaign,one from campaignFactory)
//1 activates the optimizer


fs.ensureDirSync(buildPath);
//create build folder if does not exist

//take each contract in output and write it to build directory
for(let contract in output){
    fs.outputJSONSync(  //write out json file
        path.resolve(buildPath,contract.replace(':','') +'.json'),
        output[contract]
    );
}
// contract is preceded by ':' that why we replace ':' by '';
//creates Campaign.json and CampaignFactory.json

