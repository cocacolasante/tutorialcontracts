// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract TestUSDT is ERC20{
    using SafeERC20 for ERC20;
    address public owner;

    uint256 private _totalSupply;
    uint public maxSupply = 10000000000000000000000000000;

    constructor()ERC20("KonnektVPN", "KPN"){
        owner = msg.sender;
        _mint(msg.sender, 2000000000000000000000000000);
        
    }

    // mints token to owners wallet
    function mint(uint256 amount) external{
        // require(owner == msg.sender, "ERC20: Only contract owner can call function");
        require(_totalSupply + amount <= maxSupply, "ERC20: Over Max Supply Error");
        _totalSupply += amount;
        _mint(msg.sender, amount);
    }

    // public burn function
    function burn(uint256 amount) public {
        require(_totalSupply - amount >= 0, "ERC20: Cannot Burn more than current supply");
        require(balanceOf(msg.sender)>= amount, "ERC20: Cannot burn - balance too low");
        _totalSupply -= amount;
        _burn(msg.sender, amount);
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

}