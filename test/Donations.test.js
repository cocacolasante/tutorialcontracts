const { expect } = require("chai");
const hre =  require("hardhat")

describe("Donations", () =>{
    let Donations, deployer, user1, user2, tx, res, USDT

    beforeEach(async () =>{
        [deployer, user1, user2] = await hre.ethers.getSigners()
        Donations = await hre.ethers.deployContract("Donations")
        await Donations.waitForDeployment()
        USDT = await hre.ethers.deployContract("TestUSDT")
        await USDT.waitForDeployment()
        // console.log(`Donations deployed to ${USDT.target} by deployer: ${deployer.address}`)
    })
    describe("Deployment", () =>{
        it("checks the owner is the deployer", async () =>{
            expect(await Donations.owner()).to.equal(deployer.address)
        })
        it("checks the balance is zero", async () =>{
            expect(await Donations.getBalance()).to.equal(hre.ethers.parseEther("0"))
        })
    })
    describe("Eth donations", () =>{
        describe("Success using call method", () =>{
            beforeEach(async () =>{
                tx = await user1.sendTransaction({
                    to: Donations.target,
                    value: hre.ethers.parseEther("1")
                })
                res = await tx.wait()
            })
            it("checks the ether was sent to the smart contract", async () =>{
                expect(await Donations.getBalance()).to.equal(hre.ethers.parseEther("1"))
            })
            it("checks donor mapping for user 1 is true", async () =>{
                
                const user1bool = await Donations.getDonor(user1.address)
                expect(user1bool).to.equal(true)
            })
            it("checks event was emitted", async () =>{
                expect(await user1.sendTransaction({
                    to: Donations.target,
                    value: hre.ethers.parseEther("1")
                })).to.emit("Donated").withArgs(user1.address, hre.ethers.parseEther("1"), true)
            })
        })
        describe("Failure", () =>{})
    })
    describe("Token Donation",()=>{
        beforeEach(async () =>{
            tx = await USDT.connect(deployer).transfer(user1.address, 1000000000)
            res = await tx.wait()
            tx = await USDT.connect(user1).approve(Donations.target, 500)
            res = await tx.wait()
            tx = await Donations.connect(user1).donate(USDT.target, 500)
            res = await tx.wait()
        })
        it("checks the balance of the tokens in the smart contract", async () =>{
            expect(await Donations.getTokenBalance(USDT.target)).to.equal(500)
        })
        it("checks the token address was added to the stored tokens array")
        it("checks the donation status for the address was set to true", async () =>{
            expect(await Donations.getDonor(user1.address)).to.equal(true)
        })
    })
})