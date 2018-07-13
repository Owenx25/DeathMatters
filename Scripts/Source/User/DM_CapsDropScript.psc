Scriptname DM_CapsDropScript extends ObjectReference
Actor Property PlayerRef Auto Const Mandatory
MiscObject Property Caps001 Auto Const Mandatory
GlobalVariable Property DM_CapsBeforeDeath Auto Const Mandatory

EVENT OnLoad()
	blockActivation()
endEVENT

EVENT OnActivate(ObjectReference akActionRef)
	int caps = DM_CapsBeforeDeath.GetValueInt()
	while caps > 65000
		PlayerRef.AddItem(Caps001, 65000, true)
		caps -= 65000
	endWhile
	akActionRef.addItem(Caps001, caps, true)
	disable()
	delete()
endEVENT