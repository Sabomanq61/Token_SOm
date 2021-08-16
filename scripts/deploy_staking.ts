const hre = require("hardhat");

import { config as dotenvConfig } from 'dotenv';

const ethers = hre.ethers;


var logger4js = require("log4js");

logger4js.configure({
    appenders: { cheese: { type: "file", filename: "staking_contract.log" } },
    categories: { default: { appenders: ["cheese"], level: "trace" } }
});

var logger = logger4js.getLogger();


async function deploy()
{
    const Som = await hre.ethers.getContractFactory("Som");
    const stakeToken = await Som.deploy(process.env.STAKE_TOKEN, process.env.STAKE_TOKEN_SYMBOL);

    logger.trace("Deployed Som ", stakeToken.address);

    const rewardToken = await Som.deploy(process.env.REWARD_TOKEN, process.env.REWARD_TOKEN_SYMBOL);

    logger.trace("Deployed Som ", rewardToken.address);

    const StakerFactory = await hre.ethers.getContractFactory("Staker");

    const staker = await StakerFactory.deploy(stakeToken.address, rewardToken.address);

    logger.trace("Deployed Som ", staker.address);
}

deploy()
    .then(()=>process.exit(0))
    .catch(error => {logger.console.error(error); process.exit(1)});

