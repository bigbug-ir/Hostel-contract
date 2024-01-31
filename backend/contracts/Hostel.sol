// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.0;



contract Hostel{

    address payable public landlord;
    address payable public tenant;

    uint public numberOfRooms=0;
    uint public numberOfAgreement = 0;
    uint public numberOfRent = 0;

    struct Room{
        uint roomId;
        uint agreementId;
        string roomName;
        string roomAddress;
        uint rentPerMonth;
        uint securityDeposit;
        uint timestamp;
        bool vacant;
        address payable landlord;
        address payable currentTenant;
    }

    mapping(uint =>Room) public RoomByNumber;

    struct RoomAgreement{
        uint roomId;
        uint agreementId;
        string roomName;
        string roomAddress;
        uint rentPerMonth;
        uint securityDeposit;
        uint timestamp;
        uint lockInPeriod;
    }

    mapping (uint => RoomAgreement) public RoomAgreementByNumber;
    
    struct Rent{
        uint rentId;
        uint roomId;
        uint agreementId;
        string roomName;
        string roomAddress;
        uint rentPerMonth;
        uint timestamp;
        address payable  tenantAddress;
        address payable  landlordAddress;
    }

    mapping(uint => Rent) public RentByNumber;

    modifier OnlyLandLord(uint _index){
        require(msg.sender==RoomByNumber[_index].landlord,"Only landlord can access this function");
        _;
    }
    modifier NotLandlord(uint _index){
        require(msg.sender != RoomByNumber[_index].landlord,"Only Tenant can access this function");
        _;
    }
    modifier OnlyWhileVacant(uint _index){
        require(RoomByNumber[_index].vacant== true,"Room is currently Occupid.");
        _;
    }
    modifier OnlyWhileOccupid(uint _index){
        require(RoomByNumber[_index].vacant== false,"Room is currently Vacent.");
        _;
    }
    modifier EnoughRent(uint _index){
        require(msg.value>=uint(RoomByNumber[_index].rentPerMonth),"Not enough Ether in your wallet.");
        _;
    }
    modifier EnoughAgreementFee(uint _index){
       require(msg.value>=uint(uint(RoomByNumber[_index].rentPerMonth)+uint(RoomByNumber[_index].securityDeposit)) ,"Not enough Ether in your wallet.");
       _;
    }
    modifier SameTenant(uint _index){
        require(msg.sender == RoomByNumber[_index].currentTenant,"No previous agreement found whith you & landlord");
        _;
    }
    modifier AgreementTimesLeft(uint _index){
        uint _agreementNumber = RoomByNumber[_index].agreementId;
        uint time = RoomAgreementByNumber[_agreementNumber].timestamp + RoomAgreementByNumber[_agreementNumber].lockInPeriod;
        require(block.timestamp< time,"Agreement already Ended");
        _;
    }
    modifier AgreementTimesUp(uint _index){
        uint _agreementNumber = RoomByNumber[_index].agreementId;
        uint time = RoomAgreementByNumber[_agreementNumber].timestamp + RoomAgreementByNumber[_agreementNumber].lockInPeriod;
        require(block.timestamp > time,"Time is left for contract to end");
        _;
    }
    modifier RentTimesUp(uint _index){
        uint time = RoomByNumber[_index].timestamp + 30 days;
        require(block.timestamp >= time, "Time left to pay Rent.");
        _;
    }
    constructor(){
        landlord=payable(msg.sender);
    }
    function addRoom(
        string memory _roomName,
        string memory _roomAddress,
        uint _rentCost,
        uint _securityDeposit)public{
            require(msg.sender!=address(0) && msg.sender == landlord,"only landlord can call this function");
            numberOfRooms++;
            bool _vacancy =true;
            RoomByNumber[numberOfRooms] = Room(numberOfRooms,
            0,
             _roomName,
             _roomAddress,
             _rentCost,
             _securityDeposit,
             0,
             _vacancy,
             payable( msg.sender),
             payable(address(0)));
    }
    function signAgreement(uint _index)public payable NotLandlord(_index)EnoughAgreementFee(_index) OnlyWhileVacant(_index){
        require(msg.sender!=address(0));
        address payable _landlord;
        RoomByNumber[_index].landlord;
        uint totalFee=RoomByNumber[_index].rentPerMonth + RoomByNumber[_index].securityDeposit;
        _landlord.transfer(totalFee);
        numberOfAgreement++;
        RoomByNumber[_index].currentTenant= payable(msg.sender);
        RoomByNumber[_index].vacant=false;
        RoomByNumber[_index].timestamp=block.timestamp;
        RoomByNumber[_index].agreementId = numberOfAgreement;
        RoomAgreementByNumber[numberOfAgreement]=RoomAgreement(_index,
        numberOfAgreement,
        RoomByNumber[_index].roomName,
        RoomByNumber[_index].roomAddress,
        RoomByNumber[_index].rentPerMonth,
        RoomByNumber[_index].securityDeposit,
        RoomByNumber[_index].timestamp,
        30 days);
    }
    function payRent(uint _index) public payable SameTenant(_index) RentTimesUp(_index) EnoughRent(_index){
        require(msg.sender!=address(0));
        address payable _landlord = RoomByNumber[_index].landlord;
        uint _rent = RoomByNumber[_index].rentPerMonth;
        _landlord.transfer(_rent);
        RoomByNumber[_index].currentTenant=payable(msg.sender);
        RoomByNumber[_index].vacant = false;
        numberOfRent++;
        RentByNumber[numberOfRent] = Rent(numberOfRent,
        _index,
        RoomByNumber[_index].agreementId,
        RoomByNumber[_index].roomName,
        RoomByNumber[_index].roomAddress,
        _rent,
        block.timestamp,
        payable(msg.sender),
        _landlord
        );
    } 
    function agreementCompleted(uint _index) public payable OnlyLandLord(_index) AgreementTimesUp(_index) OnlyWhileOccupid(_index){
        require(msg.sender!=address(0));
        RoomByNumber[_index].vacant =true;
        address payable _tenant = RoomByNumber[_index].currentTenant;
        uint _securityDposit = RoomByNumber[_index].securityDeposit;
        _tenant.transfer(_securityDposit);
    }
    function agreementTerminated(uint _index) public OnlyLandLord(_index) AgreementTimesLeft(_index){
        require(msg.sender!=address(0));
        RoomByNumber[_index].vacant=true;
    }
    function roomDetail(uint _index) public view OnlyLandLord(_index) returns(Room memory){
      return(RoomByNumber[_index]);
    }
} 