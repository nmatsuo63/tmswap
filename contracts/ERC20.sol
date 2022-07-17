// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract ERC20 {
    string public name;
    string public symbol;
    uint256 public totalSupply;

    // ユーザが持っているトークンの残高を記録しておく表（マッピング）
    mapping(address => uint256) private balances;
    // 誰がどのアドレスに対してトークン転送の許可をしたかを管理する表（マッピング）
    // 左から、トークンの転送を許可したアドレス、トークンの転送を許可されたアドレス、転送を許可したトークン量
    mapping(address => mapping(address => uint256)) private allowances;

    // トークン転送が正常に完了したことをフロントに伝えるためのイベント
    event Transfer(address _from, address _to, uint256 _value);
    // トークン転送が許可されたことをフロントに伝えるイベント
    // 左から、トークンの持ち主のアドレス_owner、トークン転送を許可されたアドレス_spender、転送を許可されたトークン量_value
    event Approval(address _owner, address _spender, uint256 _value);

    // コンストラクタ（コントラクトがデプロイされたときに一度だけ実行される特別な関数）
    constructor(string memory _name, string memory _symbol, uint256 _totalSupply) {
        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupply;
        // トークンの総供給量_totalSupplyを一旦msg.senderのトークン残高にすべて転送する
        balances[msg.sender] = totalSupply;
    }

    // _ownerのトークン残高をbalancesから取得して返却する
    function balanceOf(address _owner) external view returns (uint256) {
        return balances[_owner];
    }

    // 誰がどのアドレスに対してトークン転送の許可をしたかをコントラクト外から確認するための関数
    function allowance(address _owner, address _spender) public view returns (uint256) {
        // _ownerが_spenderに対して転送許可したトークン量をallowancesマッピングから取得して、返り値とする
        return allowances[_owner][_spender];
    }

    // msg.senderから別のアドレスにトークンを転送する
    // コントラクト外からしか呼び出されないためexternal
    function transfer(address _to, uint256 _value) external returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    // あるアドレスから別のアドレスにトークンを転送する
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool) {
        // アドレス_fromがmsg.senderに対して転送許可したトークン量が_valueを超えていないことを確認
        require(allowances[_from][msg.sender] >= _value, "Transfer ammount exceeds allowance");
        _transfer(_from, _to, _value);
        // トークン転送が完了した後に、転送許可されていたトークン量からすでに転送済みのトークン量_valueを引く
        allowances[_from][msg.sender] -= _value;
        return true;
    }

    // msg.senderがあるアドレスに対してトークンの転送を許可するapprove関数
    function approve(address _spender, uint256 _value) public returns (bool) {
        // 転送を許可したトークン量として_valueを代入し、allowancesマッピングを書き換える
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // transferとtransferFromの重複部分を関数化
    function _transfer(address _from, address _to, uint256 _value) private {
        // 転送するトークン量_valueより、転送元のトークン残高が多いことを確認。少ない場合は残高不足のためNG
        require(_value <= balances[_from], "Insufficient balance");
        // 転送元と転送先のアドレスが同じでないことを確認。同じ場合は転送NG
        require(_from != _to, "from = to ... we can't send");
        // 転送元のトークン残高_fromから転送トークン量_valueを減らす
        balances[_from] -= _value;
        // 転送先のトークン残高_toに転送トークン量_valueを足す
        balances[_to] += _value;
        // イベントの実行
        emit Transfer(_from, _to, _value);
    }
}
