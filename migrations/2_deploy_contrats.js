const Tmc = artifacts.require("Tmc");
const Dex = artifacts.require("Dex");

// ETHをweiに換算する関数
// 数字numberをether（ETH）に変換し、それをweiに変換する
const EthToWei = (number) => web3.utils.toWei(web3.utils.toBN(number), 'ether');

// TCCコントラクトをデプロイする
// module.exports =と記述することで、右辺の内容をこのファイルの外部で使用することができる
// deployerはMigrationを使ってデプロイするときに使用するオブジェクト
module.exports = async function(deployer) {
    // TMCコントラクトをデプロイ
    // 左から、name、symbol、totalSupplyを渡す必要がある
    // 今回は10の10乗個のトークンを発行
    await deployer.deploy(Tmc, "TMCoin", "TMC", EthToWei(10**10));
    // デプロイしたTCCコントラクトのインスタンスを取得
    // 下記のインスタンスを取得するには上記のインスタンスのデプロイが完了している必要がある
    const tmc = await Tmc.deployed();
    // DEXコントラクトをデプロイ
    await deployer.deploy(Dex, [tmc.address]);
    // Dex.deployed()でデプロイしたDEXコントラクトのインスタンスを取得するにはひとつ上のデプロイが完了している必要がある
    const dex = await Dex.deployed();
    // 下記でdexを使用するため、上記の定義においてawaitを宣言
    // transfer関数を使い、発行したすべてのTMCトークンをDEXコントラクトに転送
    await tmc.transfer(dex.address, EthToWei(10**10));
  }
  