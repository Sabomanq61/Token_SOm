//SPDX-License-Identifier: Som
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol" as IERC20;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./KgToken.sol";

contract Staker is AccessControl, ReentrancyGuard
{
    bytes32 public constant USER_ROLE = "USER";

    struct Stake
    {
        uint256 amount;         // текущее кол-во токенов на счетe
        uint256 lastUpdateTime; // время последнего обновления счета (подсчет вознаграждения)
        uint256 lastClaimTime;  // время когда можно потребовать награду
        uint256 totalReward;    // общая сумма вознаграждения
    }

    uint    private week = 604800; // кол-во секунд в неделе
    uint    private minAmount = 1; // минимальная ставка
    uint8   private percent = 15;  // процент ставки начилсяемый каждую неделю
    uint    private totalStaked;   // ОБщая сумма стейкинга
    uint    private totalDebt;     // Общая сумма вознаграждения
    address private stakeToken;    // адрес токена ставки 
    address private rewardToken;   // адрес токена вознаграждения
    
     
    mapping(address => uint256) private addressToIndex;
    Stake[] private stakes;

    constructor(address ante, address rewardAddr)
    {
        grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        stakeToken = ante;
        rewardToken = rewardAddr;
    }

    function claimCuldown() external view returns(uint)
    {
        return week;
    }

    function minumumStake() external view returns(uint)
    {
        return minAmount;
    }

    function getTotalStaked() external view returns(uint)
    {
        return totalStaked;
    }

    function getTotalDebt() external view returns(uint)
    {
        return totalStaked;
    }

    function getUserStakeInfo() external view returns(Stake memory)
    {
        uint index = addressToIndex[msg.sender];
        require(index != 0, "Account not found.");

        return stakes[index];
    }

    function setInterestRate(uint8 percent) external{
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender));
        // todo посчитать вознаграждения
        percent = percent;
    }

    function stake(uint256 amount) external
    {
        require(amount >= minAmount, "You cant stake less than minimum amount of stake.");
        require(amount <= Som(stakeToken).balanceOf(msg.sender), "Not enough token on balance.");

        uint256 index = addressToIndex[msg.sender];

        if(index == 0)
        {
            uint currentTime = block.timestamp;
            Stake memory newStake = Stake(amount, currentTime, currentTime, 0);
            stakes.push(newStake);
            addressToIndex[msg.sender] = stakes.length - 1;   
        }
        else
        {
            update(index, block.timestamp);
        }

        grantRole(USER_ROLE, msg.sender);
        totalStaked += amount;
        Som(stakeToken).burn(msg.sender, amount); // снять токены со счета
    }

    function unstake(uint amount) external 
    {
        uint index = addressToIndex[msg.sender];
        
        require(index != 0, "Account not found.");
        require(stakes[index].amount >= amount, "There are not enough funds in the account");
        

        update(index, block.timestamp);

        stakes[index].amount -= amount;
        totalStaked -= amount;
        Som(stakeToken).mint(msg.sender, amount); // зачислить токены со счет   
    }

    function claim() external nonReentrant
    {
        uint index = addressToIndex[msg.sender];
        
        require(index != 0, "Account not found.");

        uint currentTime = block.timestamp;
        update(index, block.timestamp);

        require((stakes[index].lastUpdateTime - stakes[index].lastClaimTime) >= week, "It's not time to reward yet");

        // зачислить вознаграждения на счет   
        Som(rewardToken).mint(msg.sender, stakes[index].totalReward); 
        
        // обнуляем вознаграждения
        stakes[index].totalReward = 0;

        // обновляем время последнего вознаграждения 
        stakes[index].lastClaimTime = currentTime; 
    }

    // Функцию подсчета totalReward'a
    function update(uint256 index, uint currentTime) internal
    {
        //todo check does it works
        Stake memory stake  = stakes[index];
        
        // reward = (amount * percent * 10**11 * timePassed) / (weekTime * 100 * 10**11) 
        uint temp =  (percent * 10**11) / 604800; // расчет выражения выше в комменте 
        uint x = stake.amount * (currentTime - stake.lastUpdateTime) * temp;
        uint reward = x / 10**13;

        stake.totalReward += reward;
        totalDebt += reward;
        stake.lastUpdateTime = currentTime;
    }
}












