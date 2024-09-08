extends Node2D

@onready var connect_button: Button = $ConnectButton
@onready var anchor_program: AnchorProgram = $AnchorProgram
@onready var line_edit: LineEdit = $LineEdit
@onready var airdropButton: Button = $ConnectButton2
@onready var sol_amount: Label = $SolAmount
@onready var timer: Timer = $SolAmount/Timer
@onready var coins_token_amount: Label = %CoinsTokenAmount

var player;
var token_mint: Pubkey;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SolanaService.wallet.autologin = true;
	token_mint = Pubkey.new_pda(["reward"], anchor_program.get_pid())
	update_sol();
	pass # Replace with function body.

func _on_timer_timeout():
	update_sol();
	timer.start() 

func update_sol() -> void: 
	var wallet_address = SolanaService.wallet.get_pubkey().to_string();
	var balance = await SolanaService.get_balance(wallet_address)
	sol_amount.text = var_to_str(balance) + " sol";
	print("" + sol_amount.text)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func collect_coin() -> void: 
	var instruction:Array[Instruction]
	print(SolanaService.wallet.get_kp().to_string())
	print(SolanaService.wallet.get_pubkey().to_string())
	print("Mint:" + token_mint.to_string())

	var reciever_token_account: Pubkey = await SolanaService.get_associated_token_account(
			SolanaService.wallet.get_pubkey().to_string(), 
			token_mint.to_string()
		);
	#print("reciever_token_account:" + reciever_token_account.to_string())
 
	if reciever_token_account == null:
		reciever_token_account = Pubkey.new_associated_token_address(
			SolanaService.wallet.get_kp(), 
			token_mint.to_string());
		print("Reciever:" + reciever_token_account.to_string())
		var init_ata: Instruction = AssociatedTokenAccountProgram.create_associated_token_account(
			SolanaService.wallet.get_kp(),
			SolanaService.wallet.get_kp(),
			token_mint, 
			SolanaService.token_pid);
		instruction.append(init_ata);


	var collect_coin_ix: Instruction = anchor_program.build_instruction("killEnemy", [
		SolanaService.wallet.get_kp(),
		reciever_token_account,
		token_mint,
		SolanaService.token_pid,
		SolanaService.associated_token_pid,
		SystemProgram.get_pid()
	], null);
	
	instruction.append(collect_coin_ix);
	var tx_data: TransactionData = await SolanaService.transaction_manager.sign_transaction(instruction, TransactionManager.Commitment.CONFIRMED);
	
	print(tx_data.is_successful())
	print(tx_data.get_link())
	print(tx_data.data)
	
	if tx_data.is_successful():
		print("failed")
		push_error("Collect failed")
	
	coins_token_amount.updateTokenAmount();

		
	


func _on_connect_button_pressed() -> void:
	print("Input: " + line_edit.text)
	transfer_coins_to_wallet(line_edit.text)
	pass # Replace with function body.

func transfer_coins_to_wallet( address: String) -> void:
	var instruction:Array[Instruction]

	print("transfer to : " + address)
	var my_token_account: Pubkey = await SolanaService.get_associated_token_account(
		SolanaService.wallet.get_pubkey().to_string(), 
		token_mint.to_string()
	);
	var reciever_token_account: Pubkey = await SolanaService.get_associated_token_account(
		address, 
		token_mint.to_string()
	);
	
	if reciever_token_account == null:
		reciever_token_account = Pubkey.new_associated_token_address(
			address, 
			token_mint.to_string());
		print("Reciever:" + reciever_token_account.to_string())
		var init_ata: Instruction = AssociatedTokenAccountProgram.create_associated_token_account(
			SolanaService.wallet.get_kp(),
			address,
			token_mint, 
			SolanaService.token_pid);
		instruction.append(init_ata);

	var transferIx = await TokenProgram.transfer_checked(
		my_token_account,
		token_mint,
		reciever_token_account,
		SolanaService.wallet.get_kp(),
		20 * pow(10, 9),
		9
	);
	instruction.append(transferIx);
	
	var result = await SolanaService.transaction_manager.sign_transaction(instruction);
	coins_token_amount.updateTokenAmount();
	print(result);
	
	
func _on_airdrop_button_pressed() -> void:	
	OS.shell_open("https://faucet.solana.com/?walletAddress=" + SolanaService.wallet.get_pubkey().to_string() + "&amount=1"); 
	timer.start()
