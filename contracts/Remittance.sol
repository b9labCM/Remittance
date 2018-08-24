pragma solidity ^0.4.18;

import "./Owned.sol";
import "./Stoppable.sol";

contract Remittance is Stoppable {
    
    
    struct Deposit {
        uint amount; // Amount to send 
        uint timeLimit; // Time limit within the amount can be withdraw (not used for now)
        address exchanger; 
        
    }
    
    
    mapping(bytes32 => Deposit) public deposits; 
    
    event LogDeposit(address sender, address exchanger, uint amount, bytes32 psw);
    event LogWithdraw(address exchanger, address receiver, uint amount);
    
    constructor () public { }
    
    
     // Function to load ether on contract. Once it is loaded the amount can 
     //  be withdraw only to whom who knows the complete password 
    
    function depositOnContract(address exchanger, bytes32 puzzle) public payable onlyIfRunning  returns(bool success){
        require(msg.value > 0, "Insufficient funds");
        require(msg.sender != address(0), " address must not be 0x0");
        require(deposits[puzzle].amount == 0, "Puzzle already used!");
      
        emit LogDeposit(msg.sender, exchanger, msg.value, puzzle);
        deposits[puzzle] = Deposit({
    				amount: msg.value,
    				timeLimit: now,
    				exchanger: exchanger
				});
        return true; 
    }


        
    function withdraw(string password1, string password2) public onlyIfRunning returns(bool success){
        // you can withdraw coins only if you know the right password 
        bytes32 tmp_password = computeHash(password1, password2);
        
        uint tmpAmount = deposits[tmp_password].amount;
        require(tmpAmount != 0, "Thou shalt not pass!" ); // Only when both passwords are correct does the contract yield the Ether to Carol.
	deposits[tmp_password].amount = 0;
	
	address tmpExchanger = deposits[tmp_password].exchanger;
	require(msg.sender == tmpExchanger); // Carol submits both passwords to Alice's remittance contract (Only Carol can withdraw funds)
        
        emit LogWithdraw(tmpExchanger, msg.sender,tmpAmount);
        msg.sender.transfer(tmpAmount);
        
        return true;
    }
     
    // add a kill switch to the whole contract
    function killSwitch() public onlyOwner {
        selfdestruct(owner);
    }
     
    /* Utils */
        
    // Used only for debugging to compute hash in a fast way 
    function computeHash(string password1, string password2) public pure returns(bytes32){
        return keccak256(abi.encodePacked(password1,password2));
    }
}  
