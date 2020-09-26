pragma solidity ^0.5.0;

contract Hospital{
	struct Room{
    	//complete the struct
    	bytes32 room_name;
    	string occ_name;
    	bool isFree;
	}
	Room[] public rooms;
    
	constructor (bytes32[] memory names) public{
    	//complete the constructor       	 
    	}
	}
	function assignRoom(bytes32 roomName, string memory patientName) public returns(string memory){
    	//complete the function
           	 	
    	}
    
}