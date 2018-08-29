pragma solidity ^0.4.18;

import "./Owned.sol";
import "./Stoppable.sol";

contract Remittance is Stoppable {
    
    struct Deposit {
        uint amount; // Amount to send 
        uint timeLimit; // Time limit within the amount can be withdraw (not used for now)
    }
    
    mapping(bytes32 => Deposit) public deposits; 
    
    event LogDeposit(address sender, uint amount, bytes32 psw, uint expiringTime);
    event LogWithdraw(address receiver, uint amount, bytes32 key);
    
    constructor () public { }
    
    function depositOnContract( bytes32 puzzle, uint duration) public payable onlyIfRunning  returns(bool success){
        require(msg.value > 0, "Insufficient funds");
        require(msg.sender != address(0), "Address must not be 0x0");
        require(deposits[puzzle].amount == 0, "Puzzle already used!");
        
        uint expiringTime = now + duration; //todo: safemath 
        
        emit LogDeposit(msg.sender, msg.value, puzzle, expiringTime);

        deposits[puzzle] = Deposit({
    	    amount: msg.value,
    	    timeLimit: expiringTime
	});

        return true; 
    }

    function withdraw(bytes32 password1, bytes32 password2, address depositer) public onlyIfRunning returns(bool success){
        
        // you can withdraw coins only if you know the right password and you are the receiver
        bytes32 tmp_password = computeHash(depositer, password1, password2, msg.sender);
        
        uint tmpAmount = deposits[tmp_password].amount;
        require(tmpAmount != 0, "Thou shalt not pass!" ); // Only when both passwords are correct does the contract yield the Ether to Carol.
	deposits[tmp_password].amount = 0;
        
        require( now <= deposits[tmp_password].timeLimit, "Session expired");
        
        emit LogWithdraw(msg.sender,tmpAmount, tmp_password);
        msg.sender.transfer(tmpAmount);
        
        return true;
    }
    
    function withdrawBack(bytes32 password1, bytes32 password2, address receiver) public onlyIfRunning returns(bool success){
        
        // you can withdraw coins only if you know the right password and you are the depositer
        bytes32 tmp_password = computeHash(msg.sender, password1, password2, receiver);
        
        uint tmpAmount = deposits[tmp_password].amount;
        require(tmpAmount != 0, "Thou shalt not pass!" ); // Only when both passwords are correct does the contract yield the Ether to Carol.
	deposits[tmp_password].amount = 0;

        // You can take back money only if the session is expired
        require( now > deposits[tmp_password].timeLimit, "Session expired");
        
        emit LogWithdraw(msg.sender,tmpAmount, tmp_password);
        msg.sender.transfer(tmpAmount);
        
        return true;
    }
    
    
     
    // add a kill switch to the whole contract
    function killSwitch() public onlyOwner {
        selfdestruct(owner);
    }
     
    /* Utils */
        
    // Used only for debugging to compute hash in a fast way 
    function computeHash(address depositer, bytes32 password1, bytes32 password2, address exchanger) public pure returns(bytes32){
        return keccak256(abi.encodePacked(depositer, password1, password2, exchanger));
    }
}  
