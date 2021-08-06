//SPDX-License-Identifier: Som
pragma solidity ^0.8.4;

contract Som
{
    /*Contract data */
    /*private section */
    string private  name_;
    string private  symbol_;
    uint8  private  decimals_ = 18;
    uint256 private totalSupply_ = 10000;
    
    /*public section*/
    mapping (address=>uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowances;

    /*Getters*/
    function name() public view returns (string memory)
    {
        return name_;
    }    

    function symbol() public view returns (string memory) {
        return symbol_;
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    /*Constructor for contract*/
    constructor(string memory tokenName, string memory symbolT) {
        name_ = tokenName;
        symbol_ = symbolT;
        balances[msg.sender] = totalSupply_;
    }

    /*Events*/
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

    /* Functions */
    function balanceOf(address account) public view returns(uint256) {
        require(account != address(0), "Invalid address");

        return balances[account];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(balances[msg.sender] >= value, "Not enough token");
        require(to != address(0), "Invalid address");

        balances[msg.sender] -= value;
        balances[to] += value;
        
        emit Transfer(msg.sender, to, value);
        
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0), "Invalid address");

        allowances[msg.sender][spender] = value;
        
        emit Approval(msg.sender, spender, value);
        
        return true;
    }

    function allowance(address owner, address spender) public view returns(uint256){
        return allowances[owner][spender];
    }

    function transferFrom(address from, address to, uint256 value)
        public
        returns (bool)
    {
        require(to != address(0), "Invalid address");
        require(from != address(0), "Invalid address");
        require(value <= balances[from], "Not enough token on balance");
        require(value <= allowances[from][msg.sender], "Spending limit exceeded");

        balances[from] = balances[from] - value;
        balances[to] = balances[to] + value;
        allowances[from][msg.sender] = allowances[from][msg.sender] - value;
        
        emit Transfer(from, to, value);
        
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        require(spender != address(0), "Invalid address"); 

        allowances[msg.sender][spender] = allowances[msg.sender][spender] + addedValue;

        emit Approval(msg.sender, spender, allowances[msg.sender][spender]);
        
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {  
        require(spender != address(0));
        require(subtractedValue <= allowances[msg.sender][spender]);

        allowances[msg.sender][spender] = allowances[msg.sender][spender] - subtractedValue;

        emit Approval(msg.sender, spender, allowances[msg.sender][spender]);
        

        return true;
    }

    function _mint(address account, uint256 amount) public {
        require(account != address(0));

        totalSupply_ = totalSupply_ + amount;
        balances[account] += amount;
        
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) public {
        require(account != address(0));
        require(amount <= balances[account]);

        totalSupply_ = totalSupply_ - amount;
        balances[account] = balances[account] - amount;

        emit Transfer(account, address(0), amount);
    }
}