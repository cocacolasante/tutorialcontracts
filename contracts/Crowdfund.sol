// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;


contract Crowdfund {
    // owner variable
    address private _owner;
    // goal 
    uint private _goal;
    // end date
    uint private _enddate;

    // mapping of donations to users
    mapping(address=>Donation) _usersDonations;
    // donations struct
    struct Donation{
        uint ethAmount;
        uint lastDonationTime;
        uint timesDonated;
        
    }

    // internal check function to determine if timeline is met
    modifier CheckEndtime {
        require(block.timestamp >= _enddate, "CAMPAIGN IS OVER");
        _;
    }
    // constructor -initializing 
    // owner, end date, goal
    constructor(uint enddate_, uint goal_){
        _owner = msg.sender;
        _enddate = enddate_;
        _goal = goal_;
    }
    // donate eth function -receive function
    function donate() public CheckEndtime payable{
        require(msg.value > 0, "CANNOT DONATE ZERO");
        if(_usersDonations[msg.sender].ethAmount == 0){
            _usersDonations[msg.sender] = Donation(msg.value, block.timestamp, 1);
        }
        Donation memory tempDonation = _usersDonations[msg.sender];
        tempDonation.ethAmount += msg.value;
        tempDonation.lastDonationTime = block.timestamp;
        tempDonation.timesDonated++;
        _usersDonations[msg.sender] = tempDonation;
    }

    // withdrawal function
    function withdrawal() public returns(bool){
        require(block.timestamp >= _enddate, "CAMPAIGN IS NOT OVER");
        require(address(this).balance >= _goal,"goal not met");

        (bool success, ) = _owner.call{value: address(this).balance}("");
        return success;
    }

    function refund() public returns(bool){
        require(address(this).balance < _goal, "goal was met");
        require(block.timestamp >= _enddate, "campaign not over");
        uint refundAmount = _usersDonations[msg.sender].ethAmount;
        _usersDonations[msg.sender].ethAmount = 0;

        (bool success, ) = msg.sender.call{value: refundAmount}("");
        return success;
    }
   
    // getter functions
    function owner() public view returns(address){
        return _owner;
    }
    
    function enddate() public view returns(uint){
        return _enddate;
    }

    function goal() public view returns(uint){
        return _goal;
    }

    function getUsersDonation(address target) public view returns(Donation memory){
        return _usersDonations[target];
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }
}