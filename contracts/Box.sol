// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.8.0;

contract ERC20 { 
  //balanceOf allows the smart contract to store and return the balance of the address provided (_who)
  function balanceOf(address _who) public view returns (uint256); 
  //transfer lets the owner of the contract send a given amount of the token to another address
  //returns boolean value corresponding to the transaction status
  function transfer(address _to, uint256 _value) public returns (bool);
  //transferFrom allows to automate the transfer process and send a given amount of the token on behalf of the owner
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
}

/**
 * @title Box
 * @dev Box for collecting contributions for a given goal
 */
contract Box {

    bool public active = true;
    bool public finalized = false;

    address public token_address;

    address public creator;               //address of the cretor of the box
    address public receiver;              //address of the receiver of the amount collected in the box
   
    uint256 public goal;                  //goal is the total amount to be collected
    uint256 public minimal_contribution;
  
    uint256 public balance;               //balance is the amount in the box
    uint256 public contributions_count;   //total number of contributions

    address[] public contributors;        //addresses of the contributors
    mapping(address => bool) public unique_contributors; //address mapped to boolean value wheter the contributor is unique or not
    mapping(address => uint256) public contributions;   //addresses mapped to the value of contribution by each address

    modifier isActive() {
        require(active);
        _;
    }

    modifier isComplete() {
        require(complete());
        _;
    }

    modifier creatorOnly() {
        require(msg.sender == creator);
        _;
    }

    modifier receiverOnly() {
        require(msg.sender == receiver);
        _;
    }

    modifier contributorOnly() {
        require(contributions[msg.sender] > 0);
        _;
    }
    
    function complete() private view returns (bool) {
        return balance >= goal;
    }
    
    constructor(
      address _token_address,
      uint256 _goal,
      uint256 _mininal_contribution,
      address _receiver,
      address _creator
    ) public {
        creator = _creator;
        receiver = _receiver;
        token_address = _token_address;
        goal = _goal;
        minimal_contribution = _mininal_contribution;
    }
    
    //contribute to box
    function contribute(uint256 value) public isActive {
        require(value >= minimal_contribution);
        
        ERC20 token = ERC20(token_address);
        //msg.sender is the caller of the function
        //check if the balance of msg.sender's account >= value
        require(token.balanceOf(msg.sender) >= value);
        //if yes transfer the value from the msg.sender's address to the contract's address
        token.transferFrom(msg.sender, address(this), value);
        
        //increase contributions_count
        contributions_count++;     
        
        //not in unique_contributors set true - clarification needed!
        if (!unique_contributors[msg.sender]) {
            unique_contributors[msg.sender] = true;
            //add the address into contributors
            contributors.push(msg.sender);
        }
        //increase the balance with value contributed
        balance += value;    
        //increase the value contributed by the address
        contributions[msg.sender] += value;
    }
    
    function revokeContribution() public contributorOnly {
        uint256 amount = contributions[msg.sender];

        ERC20 token = ERC20(token_address);
        token.transfer(msg.sender, amount);

        contributions[msg.sender] = 0;
        balance -= amount;
    }
    
    function deactivate() public isActive creatorOnly {
        active = false;
    }

    function finalize() public isActive isComplete creatorOnly {
        ERC20 token = ERC20(token_address);
        token.transfer(receiver, balance);

        active = false;
        finalized = true;
    }

    function redeem() public isActive isComplete receiverOnly {
        ERC20 token = ERC20(token_address);
        token.transfer(receiver, balance);

        active = false;
        finalized = true;
    }

    function summary() public view returns(bool, bool, bool, address, uint256, uint256, uint256, uint256, uint256, address, address) {
        return (
            active,
            complete(),
            finalized,
            token_address,
            goal,
            minimal_contribution,
            balance,
            contributions_count,
            contributors.length,
            creator,
            receiver
        );
    }

    function getContributors() public view returns(address[] memory) {
      return contributors;
    }
    
}
