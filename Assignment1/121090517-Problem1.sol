// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// Contract TokenX, used for issuing free Token X.
contract TokenX {
    uint256 public totalSupply;
    mapping(address => uint256) public balances;
    address owner;

    constructor() {
        owner = msg.sender;
    }

    // Mint function: Use the require statement to ensure that only the owner can call it.
    function mint(address to, uint256 amount) public {
        require(owner == msg.sender, "Only owner can mint");
        balances[to] += amount;
        totalSupply += amount;
    }
    // Transfer function: First, check if the caller's balance is sufficient for the transfer. 
    // Then subtract the specified amount from the caller's balance and add this amount to the recipient's balance.
    function transfer(address from, address to, uint256 amount) public {
        require(balances[from] >= amount, "Not enough balance");
        balances[from] -= amount;
        balances[to] += amount;
    }
    // Check balance: Allows anyone to query the token balance of a specified address.
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }
}

// Contract TokenY, for issuing Token Y, requires Token X to mint.
contract TokenY {

    // tokenX is a public instance of the TokenX contract, allowing TokenY to interact with TokenX.
    TokenX public tokenX;

    // The balances mapping stores the balance of each address in the TokenY contract
    mapping(address => uint256) public balances;

    // The totalSupply records the total supply of TokenY.
    uint256 public totalSupply = 0;

    // MAX_SUPPLY defines the maximum supply of TokenY
    uint256 constant MAX_SUPPLY = 10000;

    // owner records the owner of this contract.
    address owner;

    constructor(address _tokenX) {
        // The address that deploys the contract is set as the owner of TokenY.
        tokenX = TokenX(_tokenX);

        owner = msg.sender;
    }

    function mint(address to, uint256 amount) public {
        require(owner == msg.sender,"Only owner can minter");
        require(totalSupply + amount <= MAX_SUPPLY, "Exceeds max supply");
        require(amount >= 0, "amount should not be negative");

        uint256 requiredTokenX;
        if (totalSupply < 1000) {
            if (totalSupply + amount <= 1000){requiredTokenX = 10 * amount;} 
            else if (totalSupply + amount <= 5000){requiredTokenX = 10*(1000-totalSupply)+20*(amount-(1000-totalSupply));}
            else if (totalSupply + amount <= 9000){requiredTokenX = 10*(1000-totalSupply)+20*4000+50*(amount-(1000-totalSupply)-4000);}
            else {requiredTokenX = 10*(1000-totalSupply)+20*4000+50*4000+100*(amount-(1000-totalSupply)-4000-4000);}
        } else if (totalSupply < 5000) {
            if (totalSupply + amount <= 5000){requiredTokenX = 20*amount;}
            else if (totalSupply + amount <= 9000){requiredTokenX = 20*(5000-totalSupply)+50*(amount-(5000-totalSupply));}
            else{requiredTokenX = 20*(5000-totalSupply)+50*4000+100*(amount-(5000-totalSupply)-4000);}
        } else if (totalSupply < 9000) {
            if (totalSupply + amount <= 9000) {requiredTokenX = 50 * amount;}
            else {requiredTokenX = 50*(9000-totalSupply)+100*(amount - (9000-totalSupply));}
        } else {
            requiredTokenX = 100 * amount;
        }

        require(tokenX.balances(to) >= requiredTokenX, "Insufficient Token X balance");
        tokenX.transfer(to, address(this), requiredTokenX);
        balances[to] += amount;
        totalSupply += amount;
    }
    function transfer(address from, address to, uint256 amount) external {
        require(balances[from] >= amount, "Insufficient balance");
        balances[from] -= amount;
        balances[to] += amount;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }
}