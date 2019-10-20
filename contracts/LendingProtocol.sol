/// pot.sol -- Dai Savings Rate

// Copyright (C) 2018 Rain <rainbreak@riseup.net>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity >=0.4.22 <0.6.0;

import "./lib.sol";

/*
   "Savings Dai" is obtained when Dai is deposited into
   this contract. Each "Savings Dai" accrues Dai interest
   at the "Dai Savings Rate".
   This contract does not implement a user tradeable token
   and is intended to be used with adapters.
         --- `save` your `dai` in the `pot` ---
   - `dsr`: the Dai Savings Rate
   - `pie`: user balance of Savings Dai
   - `join`: start saving some dai
   - `exit`: remove some dai
   - `drip`: perform rate collection
*/

contract Pot is DSNote {
    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address guy) external note auth { wards[guy] = 1; }
    function deny(address guy) external note auth { wards[guy] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    // --- Data ---
    mapping (address => uint256) public pie;  // user Savings Dai

    uint256 public Pie;  // total Savings Dai
    uint256 public dsr;  // the Dai Savings Rate
    uint256 public chi;  // the Rate Accumulator

    address public vow;  // debt engine
    uint256 public rho;  // time of last drip

    uint256 public live;  // Access Flag

    // --- Init ---
    constructor() public {
        wards[msg.sender] = 1;
        dsr = ONE;
        chi = ONE;
        rho = now;
        live = 1;
    }

    // --- Math ---
    uint256 constant ONE = 10 ** 27;
    function rpow(uint x, uint n, uint base) internal pure returns (uint z) {
        assembly {
            switch x case 0 {switch n case 0 {z := base} default {z := 0}}
            default {
                switch mod(n, 2) case 0 { z := base } default { z := x }
                let half := div(base, 2)  // for rounding.
                for { n := div(n, 2) } n { n := div(n,2) } {
                    let xx := mul(x, x)
                    if iszero(eq(div(xx, x), x)) { revert(0,0) }
                    let xxRound := add(xx, half)
                    if lt(xxRound, xx) { revert(0,0) }
                    x := div(xxRound, base)
                    if mod(n,2) {
                        let zx := mul(z, x)
                        if and(iszero(iszero(x)), iszero(eq(div(zx, x), z))) { revert(0,0) }
                        let zxRound := add(zx, half)
                        if lt(zxRound, zx) { revert(0,0) }
                        z := div(zxRound, base)
                    }
                }
            }
        }
    }

    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = mul(x, y) / ONE;
    }

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    // --- Administration ---
    function file(bytes32 what, uint256 data) public note auth {
        require(live == 1);
        require(now == rho);
        if (what == "dsr") dsr = data;
        else revert();
    }

    function file(bytes32 what, address addr) public note auth {
        if (what == "vow") vow = addr;
        else revert();
    }

    function cage() public note auth {
        live = 0;
        dsr = ONE;
    }
    
    
    function depositUsingParameter(uint256 deposit) public payable returns(uint256) {  //deposit ETH using a parameter
        require(msg.value == deposit);
        deposit = msg.value;
        return deposit;
    }

    // --- Savings Rate Accumulation ---
    function drip() public note {
        require(now >= rho);
        uint chi_ = sub(rmul(rpow(dsr, now - rho, ONE), chi), chi);
        chi = add(chi, chi_);
        rho = now;
        //vat.suck(address(vow), address(this), mul(Pie, chi_));
        uint256 m = mul(Pie, chi_);
        depositUsingParameter(m);
    }

    // --- Savings Dai Management ---
    function join(uint wad) public payable note{
        require(now == rho);
        pie[msg.sender] = add(pie[msg.sender], wad);
        Pie             = add(Pie,             wad);
        // vat.move(msg.sender, address(this), mul(chi, wad));
        uint256 m = mul(chi,wad);
        depositUsingParameter(m);
    }

    function exit(uint wad) public payable note {
        pie[msg.sender] = sub(pie[msg.sender], wad);
        Pie             = sub(Pie,             wad);
        // vat.move(address(this), msg.sender, mul(chi, wad));
        uint256 m = mul(chi,wad);
        msg.sender.transfer(address(this).balance);
    }
    
    function getContractBalance() public view returns (uint256) { //view amount of DAI the contract contains
        return address(this).balance;
    }
    function() external payable {
    // this function enables the contract to receive funds
    }
}