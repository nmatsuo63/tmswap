// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./ERC20.sol";

contract Dex {

    // トークンを購入する関数
    // 購入したいトークンコントラクトのアドレス_tokenAddr、トークン購入のためにに支払う必要のあるETH_cost、購入したいトークン量_amount
    // DEXコントラクトにETHを送金するため、payable修飾子をつける
    function  buyToken(address _tokenAddr, uint256 _cost, uint256 _amount) external payable {
        ERC20 token = ERC20(_tokenAddr);
        require(msg.value >= _cost, "Insufficient ETH");
        require(token.balanceOf(address(this)) >= _amount, "Token sold out");
        token.transfer(msg.sender, _amount);
    }

}
