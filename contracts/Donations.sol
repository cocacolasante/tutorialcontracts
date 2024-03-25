// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Donations {
    address private _owner;

    mapping(address=>uint) _tokenAmounts;
    // mapping of addresses to boolean of has donated
    mapping(address=>bool) donors;
    address[] _storedTokens;

    event Donated(address indexed donor, uint amount, bool success);

    // receive function to receive ether donations
    receive() external payable{
        
        if(donors[msg.sender] == false){
            donors[msg.sender] = true;
        }

        emit Donated(msg.sender, msg.value, true);
    }
    // reverting fallback function to avoid unknown contract calls
    fallback() external payable{
        revert();
    }
    
    constructor(){
        _owner = msg.sender;
    }

    function donate(address _tokenAddy, uint _amount) public returns(bool){
        if(_tokenAmounts[_tokenAddy]==0){
            _storedTokens.push(_tokenAddy);
        }
        if(donors[msg.sender] == false){
            donors[msg.sender] == true;
        }
    
        _tokenAmounts[_tokenAddy]+= _amount;
        bool success = IERC20(_tokenAddy).transferFrom(msg.sender, address(this), _amount);

        emit Donated(msg.sender, _amount, success);
        return success;
    }

    function withdrawal(address target) public returns(bool){
        require(msg.sender == _owner, "ONLY OWNER");
        uint amount = _tokenAmounts[target];

        bool success = IERC20(target).transfer(_owner, amount);

        return success;

    }
    


    // getter functions
    function getAllStoredTokensAddress() public view returns(address[] memory){
        return _storedTokens;
    }

    function getTokenBalance(address target) public view returns(uint){
        return _tokenAmounts[target];
    }

    function owner() public view returns(address){
        return _owner;
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function getDonor(address target) public view returns(bool){
        return donors[target];
    }

}