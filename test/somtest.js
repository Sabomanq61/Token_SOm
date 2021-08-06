const { assert } = require("chai");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Token Som Test contract", function () {
    
    beforeEach(async function () {
        // Get the ContractFactory and Signers here.
        Token = await ethers.getContractFactory("Som");
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    
        hardhatToken = await Token.deploy("Som", "Kg");
    });

    describe("Transactions", function(){
        it("check owner balance", async function(){
            const ownerBalance = await hardhatToken.balanceOf(owner.address);
            console.log(" Check balance %s", ownerBalance);
        });

        it("Transfer between accounts", async function(){
            await hardhatToken.transfer(addr1.address, 5000);
            const addr1Balance = await hardhatToken.balanceOf(addr1.address);
            expect(addr1Balance).to.equal(5000);
            
            const ownerBalance = await hardhatToken.balanceOf(owner.address);
            expect(ownerBalance).to.be.equal(5000);  
            
            await hardhatToken.connect(addr1).transfer(addr2.address, 2500);
            const addr2Balance = await hardhatToken.balanceOf(addr2.address);
            expect(addr2Balance).to.equal(2500);
        });

        it("Transfer to should fail if sender dont have enough token", async function(){
            const addr1Balance = await hardhatToken.balanceOf(addr1.address);  
            const ownerBalance = await hardhatToken.balanceOf(owner.address);
            console.log("Check balance addr1 %s", addr1Balance);
            console.log("Check balance owner %s", ownerBalance);
            

            await expect(
                hardhatToken.connect(addr1).transfer(owner.address, 2700)
            ).to.be.revertedWith("Not enough token");
        
            // Owner balance shouldn't have changed.
            expect(await hardhatToken.balanceOf(owner.address)).to.equal(ownerBalance);
        })

        it("Approve, transferFrom test", async function(){
            await expect(hardhatToken.approve(addr1.address, 3000));

            allowance = await hardhatToken.allowance(owner.address, addr1.address);
            expect(allowance).to.be.equal(3000);

            const addr2Balance = await hardhatToken.balanceOf(addr2.address);
            await hardhatToken.connect(addr1).transferFrom(owner.address, addr2.address, 2000);
            const addr2NewBalance = await hardhatToken.balanceOf(addr2.address);
            expect(addr2Balance + 2000).to.be.equal(addr2NewBalance);
            
            /*Check allowance < amount to send*/
            await expect(hardhatToken.connect(addr1).transferFrom(owner.address, addr2.address, 2000))
                .to.be.revertedWith("Spending limit exceeded");

            /*Check token to send > balance*/
            await hardhatToken.increaseAllowance(addr1.address, 10000);
            await expect(hardhatToken.connect(addr1).transferFrom(owner.address, addr2.address, 9000))
                .to.be.revertedWith("Not enough token on balance");
            
            allowance = await hardhatToken.allowance(owner.address, addr1.address);
            expect(allowance).to.be.equal(11000);
            
            await hardhatToken.decreaseAllowance(addr1.address, 10000);
            
            allowance = await hardhatToken.allowance(owner.address, addr1.address);
            expect(allowance).to.be.equal(1000);
        });

        it("Mint burn test",  async function(){
            await hardhatToken._mint(owner.address, 4000);
            ownerBalance = await hardhatToken.balanceOf(owner.address);

            expect(await hardhatToken.totalSupply()).to.be.equal(14000);
            expect(ownerBalance).to.be.equal(await hardhatToken.totalSupply());    

            await hardhatToken._burn(owner.address, 6000);
            ownerBalance = await hardhatToken.balanceOf(owner.address);

            expect(await hardhatToken.totalSupply()).to.be.equal(8000);
            expect(ownerBalance).to.be.equal(await hardhatToken.totalSupply());    
        });
    }); 
});