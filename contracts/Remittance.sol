pragma solidity ^0.4.18;

import "./Owned.sol";
import "./Stoppable.sol";

contract Remittance is Stoppable {
    
    
    struct deposit {
        uint amount; // Amount to send 
        uint timeLimit; // Time limit within the amount can be withdraw
        address exchanger; 
        
    }
    
    
    mapping(bytes32 => deposit) public deposits; 
    
    
    event LogDeposit(address sender, address exchanger, uint amount, bytes32 psw);
    event LogWithdraw(address exchanger, uint amount, bytes32 psw);
    
    constructor() public {
        
    }
    
    
    
    /*
    *   Function to load ether on contract. Once it is loaded the amount can 
    *   be withdraw only to whom who knows the complete password 
    */
      function depositOnContract(bytes32 puzzle) onlyIfRunning public payable returns(bool success){
        require(msg.value > 0, "Insufficient funds");
        require(msg.sender != address(0), " address must not be 0x0");
        require(deposits[puzzle].amount == 0, "Puzzle already used!");
      
        emit LogDeposit(msg.sender, this, msg.value, puzzle);
        deposits[puzzle] = deposit(msg.value, now, this);
        return true; 
        }
        
        
   
        
     function withdraw(string password1, string password2) public onlyIfRunning returns(bool success){
        // you can withdraw coins only if you know the right password
        bytes32 tmp_password = computeHash(password1, password2);
        
        uint tmpAmount = deposits[tmp_password].amount;
        require(tmpAmount != 0, "Thou shalt not pass!" );
        
        emit LogWithdraw(this,deposits[tmp_password].amount,tmp_password);
        msg.sender.transfer(deposits[tmp_password].amount);
        
        return true;
     }
     
     
     
     
    /* Utils */
        
    
    // Used only for debugging to compute hash in a fast way 
    function computeHash(string password1, string password2) public pure returns(bytes32){
        return keccak256(abi.encodePacked(password1,password2));
    }
}
    
