const Remittance = artifacts.require("./Remittance.sol");

contract('Remittance', function(accounts){
    let remi; 
    const owner = accounts[0]; 
    const account_A = accounts[1]; 
    const account_B = accounts[2];
    const account_C = accounts[3];
  
    let pass1 = 'b';
    let pass2 = 'b';

    let duration = 150;
    let passHashed;
    
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
	return remi.computeHash(account_A, pass1, pass2, account_C)
	.then( _passHashed => {
		passHashed = _passHashed;
		return remi.depositOnContract(passHashed, duration, {from: account_A, value: web3.toWei(0.0001, "ether")})
	}).then(txObj => {
             assert.equal(txObj.receipt.status, 1, "Deposit fails ");
             assert.equal(txObj.logs.length,1, "Event has not been emitted");
             assert.equal(txObj.logs[0].args.psw, passHashed, "puzzle not set correctly")
        })

    });

    /*Test 2: Deposit storage is correct*/
    it("Testing storage", function() {
        return remi.computeHash(account_A, pass1, pass2, account_C)
	.then( _passHashed => {
		passHashed = _passHashed;
		return remi.depositOnContract(passHashed, duration, {from: account_A, value: web3.toWei(0.0001, "ether")})
	}).then(txObj => {
             assert.equal(txObj.receipt.status, 1, "Deposit fails ");
             assert.equal(txObj.logs.length,1, "Event has not been emitted");
	     assert.equal(txObj.logs[0].args.amount.toString(10), web3.toWei(0.0001, "ether").toString(10), "Amount not set correctly")
	     return remi.deposits(passHashed)
	}).then(dep => {
	     assert.equal(dep[0],web3.toWei(0.0001, "ether"), "Check amount deposited");
	}) 

    }); 


    

    /*Test 3: Withdraw */
    it("Testing withdraw", function() {
        return remi.computeHash(account_A, pass1, pass2, account_C)
	.then( _passHashed => {
		passHashed = _passHashed;
		return remi.depositOnContract(passHashed, duration, {from: account_A, value: web3.toWei(0.0001, "ether")})
	}).then(txObj => {
             assert.equal(txObj.receipt.status, 1, "Deposit fails ");
             assert.equal(txObj.logs.length,1, "Deposit event has not been emitted");
             return remi.withdraw(pass1, pass2, account_A, {from: account_C})
        }).then(txObj => {
            assert.equal(txObj.receipt.status, 1, "Deposit fails ");
            assert.equal(txObj.logs.length,1, "Withdraw event has not been emitted");
	    assert.equal(txObj.logs[0].args.amount,web3.toWei(0.0001, "ether"), "deposited and withdrawn amount is not the same");
		
        })

    });

    /*Test 4: Withdraw: only the exchanger can use this*/
    it("Testing withdraw failure, permission denied", function() {
        return remi.computeHash(account_A, pass1, pass2, account_C)
	.then( _passHashed => {
		passHashed = _passHashed;
		return remi.depositOnContract(passHashed, duration, {from: account_A, value: web3.toWei(0.0001, "ether")})
	}).then(txObj => {
             assert.equal(txObj.receipt.status, 1, "Deposit fails ");
             assert.equal(txObj.logs.length,1, "Deposit event has not been emitted");
	     try{
	     	remi.withdraw(pass1, pass2, account_A, {from: account_B})
	     }catch(err){
		console.log("Expected failure: " + err);
		assert();
		return;
	     }
	})

    }); 


})
