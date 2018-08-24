const Remittance = artifacts.require("./Remittance.sol");

contract('Remittance', function(accounts){
    let contract ; 
    const owner = accounts[0]; 
    const account_A = accounts[1]; 
    const account_B = accounts[2];
    const account_C = accounts[3];
  
    let pass1 = 'b';
    let pass2 = 'b';

    let passHashed = '0xb8a68323ff350f076062861482bede9ffafb1c8dab43874c9558ce36c0da7124';
  
    
    /* Deploy a new contract for each test */
    beforeEach(async function(){
        remi = await Remittance.new({from: owner}); 
    });

    /*Test 1: Contract should be owned by the deployer*/
    it("Testing ownership", function() {
        return remi.owner({from: owner})
        .then(_owner => {
            let tmpOwner = _owner;
            assert.equal(tmpOwner, owner, "The deployer is not the owner!");
        })
    });

    /*Test 2: Deposit creation*/
    it("Testing deposit creation", function() {
        return remi.depositOnContract(account_C, passHashed, {from: account_A, value: web3.toWei(0.001, "ether")})
        .then(txObj => {
             assert.equal(txObj.receipt.status, 1, "Deposit fails ");
             assert.equal(txObj.logs.length,1, "event has not been emitted");
             assert.equal(txObj.logs[0].args.exchanger, account_C, "exchanger not set correctly")
        })

    });

    /*Test 2: Deposit storage is correct*/
    it("Testing storage", function() {
        return remi.depositOnContract(account_C, passHashed, {from: account_A, value: web3.toWei(0.001, "ether")})
        .then(txObj => {
             assert.equal(txObj.receipt.status, 1, "Deposit fails ");
             assert.equal(txObj.logs.length,1, "event has not been emitted");
             assert.equal(txObj.logs[0].args.exchanger, account_C, "exchanger not set correctly")
	     assert.equal(txObj.logs[0].args.amount.toString(10), web3.toWei(0.001, "ether").toString(10), "exchanger not set correctly")
	     return remi.deposits(passHashed)
	}).then(dep => {
	     assert.equal(dep[0],web3.toWei(0.001, "ether"), "amount deposit");
	     assert.equal(dep[2],account_C, "exchanger saved correctly");
	}) 

    });


    

    /*Test 3: Withdraw*/
    it("Testing withdraw", function() {
        return remi.depositOnContract(account_C, passHashed, {from: account_A, value: web3.toWei(0.1, "ether")})
        .then(txObj => {
             assert.equal(txObj.receipt.status, 1, "Deposit fails ");
             assert.equal(txObj.logs.length,1, "deposit event has not been emitted");
             assert.equal(txObj.logs[0].args.exchanger, account_C, "exchanger set correctly")
             return remi.withdraw(pass1, pass2, {from: account_C})
        }).then(txObj => {
            assert.equal(txObj.receipt.status, 1, "Deposit fails ");
            assert.equal(txObj.logs.length,1, "withdraw event has not been emitted");
	    // in progress......
	    assert.equal(txObj.logs[0].args.amount,web3.toWei(0.1, "ether"), "deposited and withdrawn amount is not the same");
		
        })

    });

})
