// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.8.0;

import "./Box.sol";

/**
 * @title Box Factory
 * @dev Helper contract for creating Boxes
 */
contract BoxFactory {
    event BoxCreated(address indexed owner, address box);    //declared BoxCreated event
    
    //to create box
    function createBox(
      address token_address,
      uint256 goal,
      uint256 mininal_contribution,
      address receiver
    ) public returns (address) {
        address owner = msg.sender;                    //owner of the new instance of the contract box is the one who created this box
        address boxAddress = address(new Box(          //creating a new instance of the contract box (similar to creating and deploying a new contract and getting a new address) 
          token_address,
          goal,
          mininal_contribution,
          receiver,
          owner
        ));
        emit BoxCreated(owner, boxAddress);            //emitted the event
        return boxAddress;                             //returns the address of the box
    }
}
