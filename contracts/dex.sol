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

    // トークンを売却する関数
    // 売却したいトークンコントラクトのアドレス_tokenAddr、売却したいトークン量_cost、対価として受け取るETHの量_amount
    function sellToken(address _tokenAddr, uint256 _cost, uint256 _amount) external {
        // ERC20という型のtokenを生成し、_tokenAddrをERC20型にキャストしている
        ERC20 token = ERC20(_tokenAddr);
        // DEXコントラクトに売却しようとしているトークンが、msg.senderのトークン残高を超えていないか確認
        require(token.balanceOf(msg.sender) >= _cost, "Insufficient token balance...");
        // 対価としてmsg.senderに支払うETHが、DEXコントラクトのETH残高を超えていないか確認
        // thisとはコントラクトのこと。address(this)はthisを型キャストしている
        require(address(this).balance >= _amount, "Dex does not have enough ETH...");
        // 売却するトークンをmsg.senderからDEXコントラクトに転送
        // tokenが持つtransferFromなので、ERC20.sol内に定義したtransferFromを利用している
        token.transferFrom(msg.sender, address(this), _cost);
        // トークンを売却した対価として、DEXコントラクトからmsg.senderにETHを支払う
        // msg.senderをpayable型アドレスにキャストしている（ETHを受け取れるアドレスに変更している）
        // bool型変数successには、正常に送金された場合はtrue、失敗した場合はfalseが入る
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        // ETHの送金が正常に行われたかを確認
        require(success, "ETH transfer failed");
    }

}
