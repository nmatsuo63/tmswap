let buyMode = true;
let token = undefined;
let web3, user, dexInst, tokenInst;
let priceData;
let finalInput, finalOutput;

const tmcAddr = "0x6C3A78ED9955C42f2aF6Ef3dea488b0B7492673f";
const dexAddr = "0x2e027586428CB844313E5119bC07fe86FF82B793";

$(document).on('click', ".dropdown-menu li a", function () {
  let element = $(this);
  let img = element[0].firstElementChild.outerHTML;
  let text = $(this).text();
  token = text.replace(/\s/g, "");
  if(user){
    switch(token){
      case "TMC":
        tokenInst = new web3.eth.Contract(abi.token, tmcAddr, {from : user});
        break;
    }
  }
  $(".input-group .btn").html(img + text);
  $(".input-group .btn").css("color", "#fff");
  $(".input-group .btn").css("font-size", "large");
});


$(document).ready(async () => {
  if(window.ethereum){
    web3 = new Web3(Web3.givenProvider);
  }
  priceData = '0.001';
});


$(".btn.login").click(async () => {
  try {
    const accounts = await window.ethereum.request({
      method: "eth_requestAccounts",
    });
    user = accounts[0];
    dexInst = new web3.eth.Contract(abi.dex, dexAddr, { from: user });
    $(".btn.login").html("Connected");
    $(".btn.swap").html("Enter an amount");
    $("#username").html(user);
  } catch (error) {
    alert(error.message);
  }
});

$("#swap-box").submit(async (e)=>{
  e.preventDefault();
  try {
    buyMode ? await buyToken() : await sellToken()
  } catch (error) {
    alert(error.message);
  }
})

$("#arrow-box h2").click(()=>{
  if(buyMode){
    buyMode = false;
    sellTokenDisplay();
  }else{
    buyMode = true;
    buyTokenDisplay();
  }
});

$("#input").on("input", async function () {
  if(token === undefined){
    return;
  }
  const input = parseFloat($(this).val());
  await updateOutput(input);
});


async function updateOutput(input){
  let output;
  switch(token){
    case "TMC":
      output = buyMode ? input / priceData : input * priceData;
      break;
  }
  const exchangeRate = output / input;
  if (output === 0 || isNaN(output)){
    $("#output").val("");
    $(".rate.value").css("display", "none");
    $(".btn.swap").html("Enter an amount");
    $(".btn.swap").addClass("disabled");
  }else{
    $("#output").val(output.toFixed(7));
    $(".rate.value").css("display", "block");
    if (buyMode) {
      $("#top-text").html("ETH");
      $("#bottom-text").html(" " + token);
      $("#rate-value").html(exchangeRate.toFixed(5));
    } else {
      $("#top-text").html(token);
      $("#bottom-text").html(" ETH");
      $("#rate-value").html(exchangeRate.toFixed(5));
    }
    await checkBalance(input);
    finalInput = web3.utils.toWei(input.toString(), "ether");
    finalOutput = web3.utils.toWei(output.toString(), "ether");
  }
}

async function checkBalance(input){
  const balanceRaw = buyMode 
    ? await web3.eth.getBalance(user) 
    : await tokenInst.methods.balanceOf(user).call()
  const balance = parseFloat(web3.utils.fromWei(balanceRaw, "ether"));

  if(balance >= input){
    $(".btn.swap").removeClass("disabled");
    $(".btn.swap").html("Swap");
  }else {
    $(".btn.swap").addClass("disabled");
    $(".btn.swap").html(`Insufficient ${buyMode ? "ETH" : token} balance`);
  }
}


function buyToken() {
  const tokenAddr = tokenInst._address;
  return new Promise((resolve, reject) => {
    dexInst.methods.buyToken(tokenAddr, finalInput, finalOutput).send({value: finalInput})
      .then((receipt) => {
        const eventData = receipt.events.buy.returnValues;
        const amountDisplay = parseFloat(web3.utils.fromWei(eventData._amount, "ether"));
        const costDisplay = parseFloat(web3.utils.fromWei(eventData._cost, "ether"));
        const tokenAddr = eventData._tokenAddr;
        alert(`
          Swap successful! \n
          Token address: ${tokenAddr} \n
          Amount: ${amountDisplay.toFixed(7)} ${token} \n
          Cost: ${costDisplay.toFixed(7)} ETH
        `)
        resolve();
      })
      .catch((error) => reject(error)); 
  })
}

async function sellToken(){
  const allowance = await tokenInst.methods.allowance(user, dexAddr).call();
  if(parseInt(finalInput) > parseInt(allowance)){
    try {
      await tokenInst.methods.approve(dexAddr, finalInput).send();
    } catch (err){
      throw(err);
    }
  }

  try {
    const tokenAddr = tokenInst._address;
    const sellTx = await dexInst.methods
      .sellToken(tokenAddr, finalInput, finalOutput)
      .send();
      const eventData = sellTx.events.sell.returnValues;
      const amountDisplay = parseFloat(
        web3.utils.fromWei(eventData._amount, "ether")
      );
      const costDisplay = parseFloat(web3.utils.fromWei(eventData._cost, "ether"));
      const _tokenAddr = eventData._tokenAddr;
      alert(`
          Swap successful!\n
          Token Address: ${_tokenAddr} \n
          Amount: ${amountDisplay.toFixed(7)} ETH\n
          Price: ${costDisplay.toFixed(7)} ${token}
        `);
  } catch (err) {
    throw (err);
  }
}