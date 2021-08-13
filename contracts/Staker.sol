//SPDX-License-Identifier: Som
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol" as IERC20;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./KgToken.sol";

contract Staker is AccessControl, ReentrancyGuard
{
    struct Stake
    {
        uint256 amount;        // текущее кол-во токенов на счетe
        uint256 lastUpdateTime;
        uint256 lastClaimTime; // время когда можно потребовать награду
        uint256 totalReward;   // общая сумма вознаграждения
    }

    uint256 minAmount = 1;
    uint8 percent = 15;
    address stakeToken;  // адрес токена ставки 
    address rewardToken; // адрес токена вознаграждения
    
     
    mapping(address => uint256) addressToIndex;
    Stake[] stakes;

    constructor(address ante, address rewardAddr, address owner)
    {
        grantRole(DEFAULT_ADMIN_ROLE, owner);
        stakeToken = ante;
        rewardToken = rewardAddr;
    }

    

    function stake(uint256 amount) external
    {
        require(amount >= minAmount);
        //require(amount <= ERCToken(stakeToken).balanceOf(msg.sender));

        uint256 index = addressToIndex[msg.sender];


        if(index == 0)
        {
            Stake memory newStake = Stake(amount, block.timestamp, block.timestamp, 0);
            stakes.push(newStake);
            addressToIndex[msg.sender] = stakes.length - 1;   
        }
        else
        {
            update(index);
        }
        Som(stakeToken).burn(msg.sender, amount); // снять токены со счет
    }


    function update(uint256 index) internal
    {
        uint256 nowTimeStamp = stakes[index].;
        // todo
    }
}












