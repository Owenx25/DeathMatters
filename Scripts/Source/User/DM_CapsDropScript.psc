Scriptname DM_CapsDropScript extends ObjectReference
Actor Property PlayerRef Auto Const Mandatory
MiscObject Property Caps001 Auto Const Mandatory
GlobalVariable Property DM_CapsBeforeDeath Auto Const Mandatory

EVENT OnLoad()
	blockActivation()
endEVENT

EVENT OnActivate(ObjectReference akActionRef)
	akActionRef.addItem(Caps001, DM_CapsBeforeDeath.GetValueInt())
	disable()
	delete()
endEVENT