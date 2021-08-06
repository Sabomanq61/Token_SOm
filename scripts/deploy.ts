const hre = require("hardhat");

import { config as dotenvConfig } from 'dotenv';

const ethers = hre.ethers;


var logger4js = require("log4js");

logger4js.configure({
    appenders: { cheese: { type: "file", filename: "kg_contract.log" } },
    categories: { default: { appenders: ["cheese"], level: "trace" } }
});

var logger = logger4js.getLogger();

async function deploy()
{
    const Som = await hre.ethers.getContractFactory("Som");
    const som = await Som.deploy(process.env.TOKEN_NAME, process.env.SYMBOL);

    logger.trace("Deployed Som ", som.address);
}

deploy()
    .then(()=>process.exit(0))
    .catch(error => {logger.console.error(error); process.exit(1)});

