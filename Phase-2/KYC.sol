pragma solidity ^0.5.9;

contract KYC {
	struct Customer{
    	bytes32 user_name;
    	bytes32 data_hash;
    	address bank_addr;
	}
	struct Bank{
	    bytes32 bank_name;
	    address eth_address;
	    bytes32 reg_number;
	}
	
	Customer[] allCustomers;
	
	Bank[] allBanks;
	
	constructor () public{
    	}
	function checkIfCustomerIsPresent(bytes32 user_name) public view returns (bool){
	    for (uint i=0; i<allCustomers.length;i++){
	        if (allCustomers[i].user_name == user_name)
	            return true;
	    }
	    return false;
	}
	
    function addCustomer(bytes32 user_name, bytes32 data_hash) public payable {
        // if (!checkIfCustomerIsPresent()){
            
        // }
    }
	function removeCustomer() public {
        
    }
    function modifyCustomer() public {
        
    }
    function viewCustomer() public returns (bytes32){
        
    }
    
    // modifier checkIfCustomerIsPresent(bytes32 user_name){
    //     require(!allCustomers[user_name].exists,"Customer already exists...");
    //  _;   
    // }
	
	}
