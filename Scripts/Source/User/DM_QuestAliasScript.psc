Scriptname DM_QuestAliasScript extends ReferenceAlias

import DM_QuestScript

;PROPERTIES
;==================================================
Actor Property PlayerRef Auto mandatory
FollowersScript Property Followers const auto mandatory
ObjectReference Property DM_DeathMarker Auto const mandatory
Quest Property DM_RecoveryQuest const auto mandatory
Activator Property DM_CapsDropACTI Auto const mandatory
Group DifficultyGlobals
	GlobalVariable Property DM_CapsBeforeDeath Auto const mandatory
	GlobalVariable Property DM_Diff_Body Auto const mandatory
	GlobalVariable Property DM_Diff_Respawn Auto const mandatory
	GlobalVariable Property DM_Diff_OldBody Auto const mandatory
	GlobalVariable Property DM_Diff_Tracking Auto const mandatory
	GlobalVariable Property DM_Diff_Saving Auto const mandatory
	GlobalVariable Property DM_Diff_Dismiss Auto const mandatory
endGroup
Group DifficultyChange
	DM_PresetDifficultyChangeScript Property setPresetDM const auto mandatory
	DM_PresetDifficultyChangeScript Property setPresetDL const auto mandatory
	DM_PresetDifficultyChangeScript Property setPresetRI const auto mandatory
	DM_DifficultyChangeScript Property setBody const auto mandatory
	DM_DifficultyChangeScript Property setOldBody  const auto mandatory
	DM_DifficultyChangeScript Property setRespawn const auto mandatory
	DM_DifficultyChangeScript Property setSaving const auto mandatory
	DM_DifficultyChangeScript Property setTracking const auto mandatory
	DM_DifficultyChangeScript Property setDismiss const auto mandatory
EndGroup
Group Startup
	Message Property DM_StartMessage Auto const mandatory
	Message Property DM_EarlyMessage Auto const mandatory
	Holotape Property DM_Holotape Auto const mandatory
	FormList Property DM_StartWorkshopList Auto const mandatory
EndGroup
Group SettlementEffects
	FormList Property DM_SettlementList Auto const mandatory
	WorkshopParentScript Property workshopParent const auto mandatory
	ActorBase Property WorkshopNPC const auto mandatory
	ActorBase Property WorkshopNPCGuard const auto mandatory
EndGroup
Group StartingItems
	ActorValue Property Rads Auto mandatory
	ActorValue Property Health Auto mandatory
	FormList Property DM_OutfitList Auto const mandatory
	MiscObject property Caps001 Auto const mandatory
	Potion property Stimpak Auto const mandatory
	LeveledItem property LL_PipeGun Auto const mandatory
	Ammo property Ammo38Caliber Auto const mandatory
EndGroup
Group DeathAudio
	MusicType Property MUSSpecialDeath const auto mandatory
	SoundCategory Property AudioCategoryVOCGeneral const auto mandatory
	SoundCategory Property AudioCategoryFSTnpc const auto mandatory
	SoundCategory Property AudioCategoryWPNnpc const auto mandatory
EndGroup
;==================================================

;SCRIPT GLOBALS
;==================================================
Form[] playerEquippedArmor
int prevOutfitChoice = -1
;==================================================

; STATES/EVENTS
;==================================================
auto State WaitingForDeath
	;Reserved for Death Matters Difficulty
	Event OnInit()
		RegisterForCustomEvent(setBody, "DC_Body")
		RegisterForCustomEvent(setOldBody, "DC_OldBody")
		RegisterForCustomEvent(setRespawn, "DC_Respawn")
		RegisterForCustomEvent(setSaving, "DC_Saving")
		RegisterForCustomEvent(setTracking, "DC_Tracking")
		RegisterForCustomEvent(setDismiss, "DC_Dismiss")
		RegisterForCustomEvent(setPresetDM, "Preset_DM")
		RegisterForCustomEvent(setPresetDL, "Preset_DL")
		RegisterForCustomEvent(setPresetRI, "Preset_RI")
	EndEvent

	Event DM_DifficultyChangeScript.DC_Body(DM_DifficultyChangeScript akSender, Var[] akArgs)		
		SetDiffBody(akArgs[0] as int)
		trace(self, "Difficuly setting Body changed to " + akArgs[0])
	EndEvent

	Event DM_DifficultyChangeScript.DC_OldBody(DM_DifficultyChangeScript akSender, Var[] akArgs)
		DM_Diff_OldBody.setValueInt(akArgs[0] as int)
		trace(self, "Difficuly setting OldBody changed to " + akArgs[0])
	EndEvent

	Event DM_DifficultyChangeScript.DC_Respawn(DM_DifficultyChangeScript akSender, Var[] akArgs)
		DM_Diff_Respawn.setValueInt(akArgs[0] as int)
		trace(self, "Difficuly setting Respawn changed to " + akArgs[0])
	EndEvent

	Event DM_DifficultyChangeScript.DC_Dismiss(DM_DifficultyChangeScript akSender, Var[] akArgs)
		DM_Diff_Dismiss.setValueInt(akArgs[0] as int)
		trace(self, "Difficuly setting Dismiss changed to " + akArgs[0])
	EndEvent

	Event DM_DifficultyChangeScript.DC_Saving(DM_DifficultyChangeScript akSender, Var[] akArgs)
		SetDiffSaving(akArgs[0] as int)
		trace(self, "Difficuly setting DisableSaving changed to " + akArgs[0])
	EndEvent

	Event DM_DifficultyChangeScript.DC_Tracking(DM_DifficultyChangeScript akSender, Var[] akArgs)
		DM_Diff_Tracking.setValueInt(akArgs[0] as int)
		trace(self, "Difficuly setting Body changed to " + akArgs[0])
	EndEvent

	Event DM_PresetDifficultyChangeScript.Preset_DM(DM_PresetDifficultyChangeScript akSender, Var[] akArgs)
		SetDiffBody(2)
		SetDiffSaving(2)
		DM_Diff_Dismiss.setValueInt(1)
		DM_Diff_OldBody.setValueInt(1)
		DM_Diff_Respawn.setValueInt(1)
		DM_Diff_Tracking.setValueInt(1)
	EndEvent
	Event DM_PresetDifficultyChangeScript.Preset_DL(DM_PresetDifficultyChangeScript akSender, Var[] akArgs)
		SetDiffBody(4)
		SetDiffSaving(2)
		DM_Diff_Dismiss.setValueInt(2)
		DM_Diff_Respawn.setValueInt(4)
	EndEvent
	Event DM_PresetDifficultyChangeScript.Preset_RI(DM_PresetDifficultyChangeScript akSender, Var[] akArgs)
		SetDiffBody(3)
		SetDiffSaving(1)
		DM_Diff_Dismiss.setValueInt(2)
		DM_Diff_Respawn.setValueInt(3)
		DM_Diff_Tracking.setValueInt(1)
		DM_Diff_OldBody.setValueInt(1)
		trace(self, "Difficuly Preset changed to " + akArgs[0])
	EndEvent

	; Onload verify if DM is enabled or not
	Event OnPlayerLoadGame()
		; If mod still not started check again
		if !isModEnabled()
			if PlayerOwnsSettlement()
				trace(self, "Player owns settlement on later pass")
				DM_StartMessage.Show()
				if PlayerRef.GetItemCount(DM_Holotape) == 0
					PlayerRef.AddItem(DM_Holotape, 1)
				EndIf
				PlayerRef.SetEssential(true)
			else
				trace(self, "Player still missing owned settlement on later pass")
				DM_EarlyMessage.Show()
			endif
		endif
	EndEvent

	;Reserved for "Death Matters" Difficulty
	Event OnPlayerSleepStop(bool abInterrupted, ObjectReference akBed)
		if DM_Diff_Saving.GetValueInt() == 1
			Game.SetInCharGen(false, false, false)
			Game.RequestSave()
			Game.SetInCharGen(true, false, false)
		endif
	EndEvent

	Event OnEnterBleedout()
		GotoState("Respawning")
	EndEvent	
endState

State Respawning
	; Use this event to figure out what armor the player is wearing without having to use F4SE
	Event OnItemUnequipped(Form akBaseObject, ObjectReference akReference)
		if akBaseObject as Armor
			playerEquippedArmor.Add(akBaseObject)
		endif
	EndEvent

	Event OnBeginState(string asOldState)
		playerRef.StopCombat()
		playerRef.StopCombatAlarm()
		; Play death music and mute sounds
		MUSSpecialDeath.Add()
		;RadIModFadeIn.Apply(1)
		AudioCategoryVOCGeneral.Mute()
		AudioCategoryFSTnpc.Mute()
		AudioCategoryWPNnpc.Mute()

		trace(self, "Player has entered Bleedout")

		Game.FadeoutGame(true, true, 1, 2, true)
		DM_DeathMarker.Disable()
		DM_DeathMarker.MoveTo(PlayerRef)
		
		; players in power armor need enough time
		; to exit it before all armor is removed
		; this should only happen for ArmorOnly and AllItems
		if PlayerRef.IsInPowerArmor() && (DM_Diff_Body.GetValueInt() == 2 || DM_Diff_Body.GetValueInt() == 3)
			PlayerRef.SwitchToPowerArmor(None)
			utility.wait(10)
		else
			utility.wait(2)
		endif
		Body()
		DismissCompanions()
		Respawn()
		PlayerRef.RestoreValue(Rads, 9999)
		PlayerRef.RestoreValue(Health, 9999) 
		; Fade back in and unmute sounds
		DM_DeathMarker.Enable()
		Game.FadeoutGame(false, false, 2, 2)
		AudioCategoryFSTnpc.Unmute()
		AudioCategoryVOCGeneral.Unmute()
		AudioCategoryWPNnpc.Unmute()

		trace(self, "Player has successfully respawned")

		; Wait a few seconds then trigger Recovery
		utility.wait(5)
		if (!DM_RecoveryQuest.isRunning() && DM_Diff_Tracking.GetValueInt() == 1)
			trace(self, "Starting recovery Quest")
			DM_RecoveryQuest.Start()	
		endif
		GotoState("WaitingForDeath")
	EndEvent

	Function Respawn()
		; Move SettlementList into an objectref array for settlement effects
		ObjectReference[] settlements = new ObjectReference[0]
		int i = DM_SettlementList.GetSize()
		While (i)
			i -= 1
			settlements.Add(DM_SettlementList.GetAt(i) as ObjectReference)	
		EndWhile
		int settlementIndex = FindNearestSettlement(settlements)
		; Determine where player should respawn based on Settings
		if DM_Diff_Respawn.GetValueInt() == 3 ;Random Settlement
			PlayerRef.MoveTo(settlements[Utility.RandomInt(0, settlements.Length - 1)])
		elseif DM_Diff_Respawn.GetValueInt() == 4 ;Nearest Settlement
			PlayerRef.MoveTo(settlements[settlementIndex])
		elseif DM_Diff_Respawn.GetValueInt() == 2 ; Nearest Settlement(Owned)
			WorkshopScript workshopRef = workshopParent.GetWorkshopFromLocation(settlements[settlementIndex].GetCurrentLocation())
			while (!workshopRef.OwnedbyPlayer && settlements.Length)
				settlements.Remove(settlementIndex)
				settlementIndex = FindNearestSettlement(settlements)
				workshopRef = workshopParent.GetWorkshopFromLocation(settlements[settlementIndex].GetCurrentLocation())
			endwhile
			PlayerRef.MoveTo(settlements[settlementIndex])
		else
			EquipPlayer()
			AffectSettlement(settlements, settlementIndex)
		endif
	endFunction

	Function Body()
		; "No Body" doesn't need to do any of this
		if DM_Diff_Body.GetValueInt() == 4
			utility.wait(8)
			return
		; On "Caps Only" a caps container is placed at body
		elseif DM_Diff_Body.GetValueInt() == 1
			DM_CapsBeforeDeath.SetValue(PlayerRef.GetItemCount(Caps001))
			DM_DeathMarker.PlaceAtMe(DM_CapsDropACTI)
			PlayerRef.RemoveItem(Caps001, -1)
			utility.wait(8)
			return
		; Other Difficulties require a clone
		else
			; Delete old Clone if exists and set new clone as linked ref
			Actor clone = DM_DeathMarker.PlaceActorAtMe(PlayerRef.GetActorBase())
			ObjectReference cloneRef = DM_DeathMarker.getLinkedRef()
			if cloneRef && (DM_Diff_OldBody.GetValueInt() == 1) 
				trace(self, "Old clone deleted")
				cloneRef.delete()		
			endif
			DM_DeathMarker.SetLinkedRef(clone)
			clone.RemoveAllItems()
			; Unequip player to figure out what they're wearing
			playerEquippedArmor = new Form[0]
			int BipedSlotindex = 0
			while BipedSlotindex < 29
				playerRef.UnequipItemSlot(BipedSlotindex)
				BipedSlotindex += 1
			endWhile
			; Clone physics get all broken if you don't wait here	
			utility.wait(8)
			trace(self, "Player Equipped Armor has length " + playerEquippedArmor.Length)
			; Equip clone with player's armor	
			while playerEquippedArmor.Length
				PlayerRef.removeItem(playerEquippedArmor[0], 1, true, clone)
				Utility.Wait(0.5)
				clone.EquipItem(playerEquippedArmor[0], true, true)
				playerEquippedArmor.Remove(0)
			endWhile
			; Transfer player's Items to clone
			if DM_Diff_Body.GetValueInt() == 2
				PlayerRef.RemoveAllItems(clone)
			endif	
			; Filthy Synth!
			clone.kill()
			DM_DeathMarker.MoveTo(clone)
			trace(self, "Player Clone killed")
		endif
	endFunction

	Function DismissCompanions()
		if DM_Diff_Dismiss.GetValueInt() == 2
			return
		endif
		trace(self, "Starting to dismiss companions")
		Actor[] playerParty = Game.GetPlayerFollowers()
		int count = playerParty.Length
		While count
			count -= 1
			if (Followers.IsPossibleCompanion(playerParty[count]))
				if playerParty[count].GetRace() == Game.GetCommonProperties().DogmeatRace
					Followers.DismissDogmeatCompanion(ShowLocationAssignmentListIfAvailable = false)
					trace(self, "Dogmeat Dismissed")
				else
					Followers.DismissCompanion(playerParty[count], ShowLocationAssignmentListIfAvailable = false)
					trace(self, "Companion " + playerParty[count] + " Dismissed")
				endif
			endif
		EndWhile
	EndFunction

	Function EquipPlayer()
		; Select a random index from formlist
		; Equip player with that outfit
		; always give player same starting items
		; Reroll if outfit is same as last time
		int choice = utility.RandomInt(0, DM_OutfitList.GetSize() - 1)
		while prevOutfitChoice == choice
			choice = utility.RandomInt(0, DM_OutfitList.GetSize() - 1)
		endWhile
		prevOutfitChoice = choice
		; Give player outfit pieces
		; (Inititially tried this with outfit type but too buggy)
		trace(self, "Outfit " + choice + " chosen for player")
		FormList respawnOutfit = DM_OutfitList.GetAt(choice) as FormList
		int index = respawnOutfit.GetSize()
		while index
			index -= 1
			PlayerRef.AddItem(respawnOutfit.GetAt(index), 1, true)
			PlayerRef.EquipItem(respawnOutfit.GetAt(index), false, true)
		endWhile
		playerRef.AddItem(Caps001, 100, true)
		playerRef.AddItem(Stimpak, 5, true)
		playerRef.AddItem(LL_PipeGun, 1, true)
		playerRef.AddItem(Ammo38Caliber, 100, true)	
	EndFunction

	Function AffectSettlement(ObjectReference[] settlements, int settlementIndex)
		trace(self, "Calculating settlement effects")
		WorkshopScript workshopRef = workshopParent.GetWorkshopFromLocation(settlements[settlementIndex].GetCurrentLocation())
		ObjectReference[] settlementMembers = workshopParent.GetWorkshopActors(workshopRef)
		ObjectReference[] genericSettlers = new ObjectReference[0]
		; Narrow settler list down to generic NPCS
		; Can't use for each loop so need to remember unique indices 
		int index = 0
		while index < settlementMembers.Length
			Actor settler = settlementMembers[index] as Actor
			trace(self, "Checking Actor: " + settler)
			if !settler.GetActorBase().isUnique()
				trace(self, "Actor: " + settler + " is generic")
				genericSettlers.Add(settlementMembers[index])
			endif
			index += 1
		endWhile
		trace(self, "There are " + genericSettlers.Length + " potential settlers to replace")
		
		; The player is respawned at the nearest owned settlement where generic population is > 0
		;  - If nearest settlement has no generic settlers or is unowned the next best settlement is checked and so on...
		;  - If somehow the player has no qualified settlement they are simply respawned at
		;    Sanctuary without any impact to the settlement
		if (genericSettlers.Length > 0 && workshopRef.OwnedbyPlayer)
			trace(self, "Replacing settler at " + workshopRef)
			workshopParent.RemoveActorFromWorkshopPUBLIC(genericSettlers[0] as WorkshopNPCScript)
			genericSettlers[0].Delete()
			PlayerRef.MoveTo(settlements[settlementIndex])
		else
			if (!settlements.Length)
				trace(self, "No owned settlements with population > 0, moving to Santuary")
				PlayerRef.MoveTo(DM_SettlementList.GetAt(0) as ObjectReference)
			else
				trace(self, "Settlement " + settlements[settlementindex] + " invalid, trying next settlement")
				settlements.Remove(settlementindex)
				settlementindex = FindNearestSettlement(settlements)
				AffectSettlement(settlements, settlementindex)
			endif
		endif
	EndFunction

	
endState

;FUNCTIONS
;================================================
; Gives the player a random outfit and starting items
; TODO: Add more outfits
Function EquipPlayer()
	;trace(self, "This should not have been called")
EndFunction

; This function makes the following assumptions:
;	- player has been removed from power armor
;	- DM_DeathMarker is at player
;	- Player is still where they 'died' with all gear
;	- Clone hasn't been spawned
; Create Body based on difficulty setting
Function Body()
EndFunction

; This function makes the following assumptions:
;	- Player is still where they 'died'
;	- Nearest Settlement is unknown
;	- DM_DeathMarker has been moved to player
; Respawn Player based on difficulty setting
Function Respawn()
EndFunction

; Dismisses the players current companions on death
; Not sure what will happen with other/quest-related companions
Function DismissCompanions()
	;trace(self, "This should not have been called")
EndFunction

; This function is for doing settler checks after the player
; dies, figuring out which settler they will replace
; WARNING: THIS FUNCTION WILL BREAK IF PLAYER SPAWN IS OUTSIDE OF WORKSHOP LOCATION
Function AffectSettlement(ObjectReference[] settlements, int settlementIndex)
	;trace(self, "This should not have been called")
EndFunction

;Calculate settlement travel marker closest to player
;and return index in given list
;NOTE: This function returns an index instead of an objectref because
;      AffectSettlement needs to know the settlement index for Removing
int Function FindNearestSettlement(ObjectReference[] settlements)
	trace(self, "Calculate closest settlement")
	ObjectReference settlement = settlements[0]
	float distanceToSettlement = PlayerRef.GetDistance(settlement)
	int closestSettlementIndex = 0
	; Run through list of settlements and find closest one
	int index = 1
	while index < settlements.Length
		settlement = settlements[index]
		if settlement
			if PlayerRef.GetDistance(settlement) < distanceToSettlement
				distanceToSettlement = PlayerRef.GetDistance(settlement)
				closestSettlementIndex = index
			endif
		endif
		index += 1
	endWhile 
	trace(self, "Closest settlement is " + closestSettlementIndex)
	return closestSettlementIndex
EndFunction

; Check if mod is enabled/disabled
bool Function isModEnabled()
	if PlayerRef.GetItemCount(DM_Holotape) == 0
		return false
	else
		return true
	endif
endFunction

; Check if player owns settlement
bool Function PlayerOwnsSettlement()
	int index = DM_StartWorkshopList.GetSize() - 1
		while index
			ObjectReference settlementObj = DM_StartWorkshopList.GetAt(index) as ObjectReference
			workshopscript settlement = settlementObj as workshopscript
			if settlement.OwnedbyPlayer
				return true
			EndIf
			index -= 1
		endWhile
		return false
endFunction

Function SetDiffBody(int newValue)
	DM_Diff_Body.setValueInt(newValue)
	;Disable tracking when no body
	if (newValue == 4)
		DM_Diff_Tracking.setValueInt(2)
	endif
EndFunction

Function SetDiffSaving(int newValue)
	DM_Diff_Saving.setValueInt(newValue)
	if (newValue == 1)
		RegisterForPlayerSleep()
		Game.SetInCharGen(true, false, false)
	else
		UnregisterForPlayerSleep()
		Game.SetInCharGen(false, false, false)
	endif
EndFunction

; Difficulty Change Event Stubs
Event DM_DifficultyChangeScript.DC_Body(DM_DifficultyChangeScript akSender, Var[] akArgs)
EndEvent
Event DM_DifficultyChangeScript.DC_OldBody(DM_DifficultyChangeScript akSender, Var[] akArgs)
EndEvent
Event DM_DifficultyChangeScript.DC_Respawn(DM_DifficultyChangeScript akSender, Var[] akArgs)
EndEvent
Event DM_DifficultyChangeScript.DC_Saving(DM_DifficultyChangeScript akSender, Var[] akArgs)
EndEvent
Event DM_DifficultyChangeScript.DC_Tracking(DM_DifficultyChangeScript akSender, Var[] akArgs)
EndEvent
Event DM_DifficultyChangeScript.DC_Dismiss(DM_DifficultyChangeScript akSender, Var[] akArgs)
EndEvent
Event DM_PresetDifficultyChangeScript.Preset_DM(DM_PresetDifficultyChangeScript akSender, Var[] akArgs)
EndEvent
Event DM_PresetDifficultyChangeScript.Preset_DL(DM_PresetDifficultyChangeScript akSender, Var[] akArgs)
EndEvent
Event DM_PresetDifficultyChangeScript.Preset_RI(DM_PresetDifficultyChangeScript akSender, Var[] akArgs)
EndEvent