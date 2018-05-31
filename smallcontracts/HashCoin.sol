pragma solidity ^0.4.21;

contract HashCoin {
    // The keyword "public" makes those variables
    // readable from outside.
    address public minter;
    mapping (address => uint) public balances;
    bytes32 public currentChallenge; // The coin starts with a challenge
    uint public timeOfLastProof; // Variable to keep track of when rewards were given
    uint public difficulty; 


    // Events allow light clients to react on
    // changes efficiently.
    event Sent(address from, address to, uint amount);

    // This is the constructor whose code is
    // run only when the contract is created.
    constructor() public {
        minter = msg.sender;
        difficulty = 10**32;
        timeOfLastProof = now;
        //currentChallenge = 0;
    }

    function mint(address receiver, uint amount) public {
        if (msg.sender != minter) return;
        balances[receiver] += amount;
    }

    function send(address receiver, uint amount) public {
        if (balances[msg.sender] < amount) return;
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Sent(msg.sender, receiver, amount);
    }

    function proofOfWork(uint nonce) public {
    	bytes8 n = bytes8(keccak256(nonce, currentChallenge)); // Generate a random hash based on input
    	require(n >= bytes8(difficulty)); // Check if it's under the difficulty

    	uint timeSinceLastProof = (now - timeOfLastProof); // Calculate time since last reward was given
    	require(timeSinceLastProof >=  5 seconds); // Rewards cannot be given too quickly
    	balances[msg.sender] += timeSinceLastProof / 60 seconds;  // The reward to the winner grows by the minute

    	difficulty = difficulty * 10 minutes / timeSinceLastProof + 1;  // Adjusts the difficulty

    	timeOfLastProof = now; // Reset the counter
    	currentChallenge = keccak256(nonce, currentChallenge, blockhash(block.number - 1));  // Save a hash that will be used as the next proof
    }


}

