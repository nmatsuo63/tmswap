// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./ERC20.sol";

contract Dex {

    // 購入完了をフロントに伝えるイベント
    event buy(address _buyer, address _tokenAddr, uint256 _cost, uint256 _amount);

    // トークンを購入する関数
    // 購入したいトークンコントラクトのアドレス_tokenAddr、トークン購入のためにに支払う必要のあるETH_cost、購入したいトークン量_amount
    // DEXコントラクトにETHを送金するため、payable修飾子をつける
    function  buyToken(address _tokenAddr, uint256 _cost, uint256 _amount) external payable {
        // ERC20コントラクトを継承したトークンコントラクトのアドレスに、_tokenAddrを型キャストして格納
        ERC20 token = ERC20(_tokenAddr);
        // ユーザが支払ったETHがトークンを購入するためのcost以上かを確認
        require(msg.value >= _cost, "Insufficient ETH");
        // ユーザが購入するトークンがDEXコントラクト内に十分存在するかを確認
        require(token.balanceOf(address(this)) >= _amount, "Token sold out");
        // msg.senderに対し、トークンを_amountだけ転送
        token.transfer(msg.sender, _amount);
        // イベント実行
        emit buy(msg.sender, _tokenAddr, _cost, _amount);
    }

}
