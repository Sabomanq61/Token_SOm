const hre = require("hardhat");
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
    const som = await Som.deploy("Som", "Kg");

    logger.trace("Deployed Som ", som.address);
}

deploy();
