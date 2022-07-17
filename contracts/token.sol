// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./ERC20.sol";

// Tmcコントラクトを定義し、ERC20コントラクトを継承する
contract Tmc is ERC20 { 
  constructor(string memory _name, string memory _symbol, uint256 _totalSupply) ERC20(_name, _symbol, _totalSupply) {

  }
}
