pragma solidity ^0.4.18;

import "./Owned.sol";
import "./Stoppable.sol";

contract Remittance is Stoppable {
    
    bool isActive; 
    
    struct deposit {
        uint amount; // Amount to send 
        uint timeLimit; // Time limit within the amount can be withdraw
        address exchanger; 
        
    }
    
    
    
    //store balances
    mapping(address => uint) public balances;
    //store psw 
    //mapping(address => bytes32) public passwords;
    // store deposits
    mapping(bytes32 => deposit) public deposits; 
    
    
    event LogDeposit(address sender, address exchanger, address receiver, uint amount, bytes32 psw);
    event LogWithdraw(address receiver , address exchanger, uint amount, bytes32 psw);
    
    constructor() public {
        isActive = true;
    }
    
    function setIsActive(bool newState) public onlyOwner onlyIfRunning returns(bool success) {
        isActive = newState;
        return true;
    }
    
    /*
    *   Function to load ether on contract. Once it is loaded the amount can 
    *   be withdraw only to whom who knows the complete password 
    */
      function depositOnContract(address receiver, bytes32 puzzle) onlyIfRunning onlyOwner public payable returns(bool success){
        require(msg.value > 0, "Insufficient funds");
        require(msg.sender != address(0), " address must not be 0x0");
        require(deposits[puzzle].amount == 0, "Puzzle already used!");
      
        balances[msg.sender] += msg.value;
        
        deposits[puzzle] = deposit(msg.value, now, this);
        emit LogDeposit(msg.sender, this, receiver, msg.value, puzzle);
        
        
        balances[this] += msg.value;
        
        return true; 
        }
        
        
     /**
        *    Function to load ether on contract. Once it is loaded the amount can 
        *    be withdraw only to whom who knows the complete password. This 
        *    version allow to set a specific address fot the ttp. 
        */
      function depositOnContractPlus(address exchanger, address receiver, bytes32 puzzle) onlyIfRunning onlyOwner public payable returns(bool success){
        require(msg.value > 0, "Insufficient funds");
        require(msg.sender != address(0), " address must not be 0x0");
        require(deposits[puzzle].amount == 0, "Puzzle already used!");
        
        balances[msg.sender] += msg.value;
        
        deposits[puzzle] = deposit(msg.value, now, exchanger);
        emit LogDeposit(msg.sender, exchanger, receiver, msg.value, puzzle);
        
        balances[exchanger] += msg.value;
        
        return true; 
        } 
           
     
        
     function withdraw(address receiver, string password1, string password2) public onlyIfRunning returns(bool success){
        // you can withdraw coins only if you know the right password
        bytes32 tmp_password = computeHash(password1, password2);
        require(deposits[tmp_password].amount != 0, "You shall not pass!" );
        require(balances[msg.sender] - deposits[tmp_password].amount > 0, "Insufficient funds");
        
        // and only within a limited amount of time 
        //require(deposits[tmp_password].timeLimit == now, "Session expired");
        
        // transfer the coins to the receiver
        receiver.transfer(deposits[tmp_password].amount);
        
        balances[receiver] += deposits[tmp_password].amount;
        balances[this] -= deposits[tmp_password].amount;
        
        emit LogWithdraw(receiver,this,deposits[tmp_password].amount,tmp_password);
        
        // Avoiding double spending problem
        balances[this] = 0;
        balances[msg.sender] = 0;
        
        return true;
     }
     
     function withdrawPlus(address exchanger, address receiver, string password1, string password2) public onlyIfRunning returns(bool success){
        // you can withdraw coins only if you know the right password
        bytes32 tmp_password = computeHash(password1, password2);
        require(deposits[tmp_password].amount != 0, "You shall not pass!" );
        // and only within a limited amount of time 
        //require(deposits[tmp_password].timeLimit == now, "Session expired");
        
        // transfer the coins to the receiver
        receiver.transfer(deposits[tmp_password].amount);
        
        balances[receiver] += deposits[tmp_password].amount;
        balances[exchanger] -= deposits[tmp_password].amount;
        
        emit LogWithdraw(receiver,exchanger,deposits[tmp_password].amount,tmp_password);
        
        // Avoiding double spending problem
        balances[exchanger] = 0;
        balances[msg.sender] = 0;
        
        return true;
     }
     
     
    /* Utils */
        
    /*Function to get the balance of a given address*/    
    function getBalance(address addr) public view returns(uint) {
        return balances[addr];
    }
    
    /*Function to get the balance of a given address*/    
    function getContractBalance() public view returns(uint) {
        return address(this).balance;
    }
    
    /*Function to get the balance of a given address*/    
    function getContractAddress() public view returns(address) {
        return this;
    } 
    
    function computeHash(string password1, string password2) public pure returns(bytes32){
        return keccak256(abi.encodePacked(password1,password2));
    }
}
    
