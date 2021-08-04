//SPDX-License-Identifier: Som
pragma solidity ^0.8.4;

contract Som
{
    string name;
    string symbol;
    uint8 decimals;
    
    mapping(address=>uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 totalSupply;

    constructor() {
        name = "Tsu";
        symbol = "TU";
        decimals = 18;
    }


    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );
    
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function transfer(address to, uint256 value) public returns (bool) {
        require(value <= balances[msg.sender]);
        require(to != address(0));

        balances[msg.sender] = balances[msg.sender] - value;
        balances[to] = balances[to] + value;
        
        emit Transfer(msg.sender, to, value);
        
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));

        allowed[msg.sender][spender] = value;
        
        emit Approval(msg.sender, spender, value);
        
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        public
        returns (bool)
    {
        require(value <= balances[from]);
        require(value <= allowed[from][msg.sender]);
        require(to != address(0));

        balances[from] = balances[from] - value;
        balances[to] = balances[to] + value;
        allowed[from][msg.sender] = allowed[from][msg.sender] - value;
        
        emit Transfer(from, to, value);
        
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        require(spender != address(0));

        allowed[msg.sender][spender] = allowed[msg.sender][spender] + addedValue;

        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
        
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {  
        require(subtractedValue <= allowed[msg.sender][spender]);

        allowed[msg.sender][spender] = allowed[msg.sender][spender] + subtractedValue;

        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
        
        return true;
    }
}