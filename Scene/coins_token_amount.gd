extends Label

@onready var coins_token_amount: Label = $"."
@onready var anchor_program: AnchorProgram = $"../../SolanaManager/AnchorProgram"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	updateTokenAmount();
	
func updateTokenAmount() -> void: 
	print("update token");
	var wallet_address = SolanaService.wallet.get_pubkey().to_string();
	#account_address.text = wallet_address
	var token_mint = Pubkey.new_pda(["reward"], anchor_program.get_pid());

	var balance:float; 
	balance = await SolanaService.get_balance(wallet_address,token_mint.to_string())
			
	coins_token_amount.text = "You have a total of " + str(balance) + " coins.";

	
