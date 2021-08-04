//SPDX-License-Identifier: Som
pragma solidity ^0.8.0;
import "hardhat/console.sol";

interface InterfaceETC20 {

// Отправка токенов на заданный адрес
function transfer(address _to, uint256 _value) external returns (bool success);

}


contract Som
{
    string _name;
    string _symbol;
    uint8 _decimals;
    mapping(address=>uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowed;
    uint256 _totalSupply;

    constructor() {
        _name = "Tsu";
        _symbol = "TU";
        _decimals = 18;
    }


  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

    function transfer(address to, uint256 value) public returns (bool) {
        require(value <= _balances[msg.sender]);
        require(to != address(0));

        _balances[msg.sender] = _balances[msg.sender] - value;
        _balances[to] = _balances[to] + value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
}