function removeAll(){
  $(".btn.selectToken").remove();
  $(".dropdown-menu").remove();
  $("span#eth-addon").remove();
}

function sellTokenDisplay(){
  removeAll();
  $(".input-group.top").append(tokenBox);
  $(".input-group.bottom").append(ethBox);
}

function buyTokenDisplay(){
  removeAll();
  $(".input-group.top").append(ethBox);
  $(".input-group.bottom").append(tokenBox);
}

let tokenBox = 
`
<button class="btn btn-outline-secondary selectToken" type="button" data-bs-toggle="dropdown" aria-expanded="false">Select <br> Token</button>
<ul class="dropdown-menu w-30">
  <li><a class="dropdown-item"><img src="assets/images/tmc.png" />&nbsp;&nbsp;TMC</a></li>
</ul>
`

let ethBox = 
`
<span class="input-group-text" id="eth-addon">
  <img src="assets/images/eth.png">&nbsp;ETH
</span>
`