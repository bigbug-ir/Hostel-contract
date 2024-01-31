const {expect} = require("chai");
const {time,loadFixture ,helper} = require("@nomicfoundation/hardhat-network-helpers");
const {ethers} = require("hardhat");

describe("Hostel",()=>{
  async function runEveryTime(){
    const Hostel =await ethers.getContractFactory("Hostel");
    const hostel =await Hostel.deploy();
    const [landlord,otherAcounts] = await ethers.getSigners();
    await hostel.waitForDeployment();
    return{hostel,landlord,otherAcounts};
  }
  describe("Deployment",()=>{
    it("Should set right lnadlord",async ()=>{
      const {hostel,landlord} = await loadFixture(runEveryTime);
      expect(await hostel.landlord()).to.equal(landlord);
    });
  });
  describe("Add Room",()=>{
    it("Should call this function by landlord",async ()=>{
    const {hostel,otherAcounts} = await loadFixture(runEveryTime);
    await expect(hostel.connect(otherAcounts).addRoom("sweet",
    "first",
    ethers.parseUnits('0.0000000000000100',"ether"),
    ethers.parseUnits('0.00000000000000100',"ether")
    )).to.be.revertedWith("only landlord can call this function");
    });
    it("Should increase number of rooms",async ()=>{
      const {hostel , landlord} = await loadFixture(runEveryTime);
      let numberOfRooms = 0;
      await hostel.addRoom("sweet",
      "first",
      ethers.parseUnits('0.0000000000000100',"ether"),
      ethers.parseUnits('0.00000000000000100',"ether")
      );
      numberOfRooms++;
      expect(await hostel.numberOfRooms()).to.equal(numberOfRooms);
    });
    it("Should add room",async()=>{
      const {hostel , landlord} = await loadFixture(runEveryTime);
      let numberOfRooms = 0;
      numberOfRooms++;
      expect(hostel.addRoom("sweet",
      "first",
      ethers.parseUnits('0.0000000000000100',"ether"),
      ethers.parseUnits('0.00000000000000100',"ether"))).not.to.be.reverted;
    })
  })
  describe("Sign Agreemnt",()=>{
    it("Should not be landrod",async()=>{
      const {hostel , landlord,otherAcounts} = await loadFixture(runEveryTime);
      let numberOfRooms = 0;
      await hostel.addRoom("sweet",
      "first",
      ethers.parseUnits('0.0000000000000100',"ether"),
      ethers.parseUnits('0.00000000000000100',"ether")
      );
      numberOfRooms++;
      await expect(hostel.signAgreement(1))
      .to.be.revertedWith("Only Tenant can access this function")
    });
    it("Should have enough ether for pay agreement fee",async ()=>{
      const {hostel , landlord,otherAcounts} = await loadFixture(runEveryTime);
      let numberOfRooms = 0;
      await hostel.addRoom("sweet",
      "first",
      ethers.parseUnits('0.0000000000000100',"ether"),
      ethers.parseUnits('0.00000000000000100',"ether")
      );
      numberOfRooms++;
      await expect(hostel.connect(otherAcounts).signAgreement(1))
      .to.be.revertedWith("Not enough Ether in your wallet.")
    });
    it("Should sign agreement",async ()=>{
      const {hostel , landlord,otherAcounts} = await loadFixture(runEveryTime);
      let numberOfRooms = 0;
      await hostel.addRoom("sweet",
      "first",
      ethers.parseUnits('0.0',"ether"),
      ethers.parseUnits('0.0',"ether")
      );
      numberOfRooms++;
      await expect(hostel.connect(otherAcounts).signAgreement(1))
      .not.to.be.reverted;
    });
  });
  describe("Agreement Completed",()=>{
    it("Sould only landlord call this funcion",async()=>{
      const {hostel,otherAcounts} = await loadFixture(runEveryTime);
      let numberOfRooms = 0;
      await hostel.addRoom("sweet",
      "first",
      ethers.parseUnits('0.0',"ether"),
      ethers.parseUnits('0.0',"ether")
      );
      numberOfRooms++;
      await hostel.connect(otherAcounts).signAgreement(1);
      // newTime= await time.increaseTo((hostel.RoomByNumber(1)).timestamp)
      await expect(hostel.connect(otherAcounts).agreementCompleted(1))
      .to.be.revertedWith("Only landlord can access this function")
    });
    it("Should Time left",async()=>{
      const {hostel} = await loadFixture(runEveryTime);
      let numberOfRooms = 0;
      await hostel.addRoom("sweet",
      "first",
      ethers.parseUnits('0.0',"ether"),
      ethers.parseUnits('0.0',"ether")
      );
      numberOfRooms++;
      // newTime= await time.increaseTo((hostel.RoomByNumber(1)).timestamp)
      await expect(hostel.agreementCompleted(1))
      .to.be.revertedWith("Time is left for contract to end")
    });
  });
  describe("Room detail ",()=>{
    it("Should only landlord access this function",async()=>{
        const {hostel,otherAcounts} = await loadFixture(runEveryTime);
        let numberOfRooms = 0;
        await hostel.addRoom("sweet",
        "first",
        ethers.parseUnits('0.0',"ether"),
        ethers.parseUnits('0.0',"ether")
        );
        numberOfRooms++;
        await expect(hostel.connect(otherAcounts).roomDetail(1))
        .to.be.revertedWith("Only landlord can access this function")
    })
  })
});