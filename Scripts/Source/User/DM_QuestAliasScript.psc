Scriptname DM_QuestAliasScript extends ReferenceAlias

import DM_QuestScript

;PROPERTIES
;==================================================
Actor Property PlayerRef Auto mandatory
FollowersScript Property Followers const auto mandatory
ObjectReference Property DM_DeathMarker Auto const mandatory
Quest Property DM_RecoveryQuest const auto mandatory
Message Property DM_RespawnMessage Auto const mandatory
;ImageSpaceModifier Property RadIModFadeIn Auto const mandatory
Group Startup
	Keyword Property DM_EnabledKeyword Auto const mandatory
	Keyword Property DM_DisabledKeyword Auto const mandatory
	Message Property DM_StartMessage Auto const mandatory
	Message Property DM_EarlyMessage Auto const mandatory
	Holotape Property DM_Holotape Auto const mandatory
EndGroup
Group SettlementEffects
	FormList Property DM_SettlementList Auto const mandatory
	WorkshopParentScript Property workshopParent const auto mandatory
	ActorBase Property WorkshopNPC const auto mandatory
	ActorBase Property WorkshopNPCGuard const auto mandatory
EndGroup
Group StartingItems
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
	; Onload verify if DM is enabled or not
	Event OnPlayerLoadGame()	
		; If the player previously was missing sanctuary check again
		if PlayerRef.HasKeyword(DM_DisabledKeyword)
			ObjectReference SanctuaryID = Game.GetForm(0x000250FE) as ObjectReference
			workshopscript SanctuaryRef
			; Mod shouldn't start until player gets sanctuary settlement
			SanctuaryRef = SanctuaryID as workshopscript
			if SanctuaryRef
				if SanctuaryRef.OwnedbyPlayer
					trace(self, "Player owns sanctuary on later pass")
					PlayerRef.RemoveKeyword(DM_DisabledKeyword)
					PlayerRef.AddKeyword(DM_EnabledKeyword)
					StartupDM()
				else
					trace(self, "Player still missing sanctuary on later pass")
					DM_EarlyMessage.Show()
				endif
			endif
		endif
	EndEvent

	Event OnEnterBleedout()
		GotoState("Respawning")
	EndEvent

	Function StartupDM()
		DM_StartMessage.Show()
		if (PlayerRef.GetItemCount(DM_Holotape) == 0)
			PlayerRef.AddItem(DM_Holotape, 1)
		endif
		PlayerRef.SetEssential(true)
	EndFunction
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
		utility.wait(2)

		SpawnandEquipClone()
		EquipPlayer()
		DismissCompanions()
		DetermineSettlementCost()

		; Fade back in and unmute sounds
		DM_DeathMarker.Enable()
		Game.FadeoutGame(false, false, 2, 2)
		AudioCategoryFSTnpc.Unmute()
		AudioCategoryVOCGeneral.Unmute()
		AudioCategoryWPNnpc.Unmute()

		trace(self, "Player has successfully respawned")

		DM_RespawnMessage.Show()
		; Wait a few seconds then trigger Recovery
		utility.wait(5)
		if (!DM_RecoveryQuest.isRunning())
			trace(self, "Starting recovery Quest")
			DM_RecoveryQuest.Start()	
		endif
		GotoState("WaitingForDeath")
	EndEvent

	Function DismissCompanions()
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

	; Spawn a clone of the player wearing their armor and items
	Function SpawnandEquipClone()
		trace(self, "Spawning Player Clone")
		; Delete old Clone if exists and set new clone as linked ref
		Actor clone = DM_DeathMarker.PlaceActorAtMe(PlayerRef.GetActorBase())
		ObjectReference cloneRef = DM_DeathMarker.getLinkedRef()
		if cloneRef
			trace(self, "Old clone deleted")
			cloneRef.delete()		
		endif
		DM_DeathMarker.SetLinkedRef(clone)

		; Remove default vault outfit from clone
		clone.UnequipAll()
		
		; Unequip player to figure out what they're wearing
		playerEquippedArmor = new Form[20]
		int BipedSlotindex = 0
		while BipedSlotindex < 20
			playerRef.UnequipItemSlot(BipedSlotindex)
			BipedSlotindex = BipedSlotindex + 1
		endWhile

		; Transfer players Items to clone
		PlayerRef.RemoveAllItems(clone)
		
		; Clone physics get all broken if you don't wait here	
		utility.wait(8)
		
		; Equip clone with player's armor	
		BipedSlotindex = playerEquippedArmor.Length
		while BipedSlotindex
			BipedSlotindex -= 1
			clone.EquipItem(playerEquippedArmor[BipedSlotindex], true, true)
		endWhile
		
		; Filthy Synth!
		clone.kill()
		trace(self, "Player Clone killed")
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
		int index = DM_OutfitList.GetSize()
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

	Function DetermineSettlementCost()
		; Move SettlementList into an objectref array for settlement effects
		ObjectReference[] settlements = new ObjectReference[0]
		int i = DM_SettlementList.GetSize()
		While (i)
			i -= 1
			settlements.Add(DM_SettlementList.GetAt(i) as ObjectReference)	
		EndWhile

		; Find closest settlement and respawn player there
		; Player doesn't actually get moved until AffectSettlement() runs
		int settlementIndex = FindNearestSettlement(settlements)
		AffectSettlement(settlements, settlementIndex)
		utility.wait(1)
	EndFunction

	Function AffectSettlement(ObjectReference[] settlements, int settlementIndex)
		trace(self, "Calculating settlement effects")
		WorkshopScript workshopRef = workshopParent.GetWorkshopFromLocation(settlements[settlementIndex].GetCurrentLocation())
		ObjectReference[] settlementMembers = workshopParent.GetWorkshopActors(workshopRef)
		; Narrow settler list down to generic NPCS
		int index = 0
		while index < settlementMembers.Length
			Actor settler = settlementMembers[index] as Actor
			if (settler.GetActorBase().isUnique())
				settlementMembers.Remove(index)
			endif
			index += 1
		endWhile
		trace(self, "There are " + settlementMembers.Length + " potential settlers to replace")
		
		; The player is respawned at the nearest owned settlement where generic population is > 0
		;  - If nearest settlement has no generic settlers or is unowned the next best settlement is checked and so on...
		;  - If somehow the player has no qualified settlement they are simply respawned at
		;    Sanctuary without any impact to the settlement
		;	 (this will probably happen more if player is early game but should stop once player gets
		;	  more settlements)
		if (settlementMembers.Length > 0 && workshopRef.OwnedbyPlayer)
			trace(self, "Replacing settler at " + workshopRef)
			workshopParent.RemoveActorFromWorkshopPUBLIC(settlementMembers[0] as WorkshopNPCScript)
			settlementMembers[0].Delete()
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
endState


;FUNCTIONS
;================================================
; Startup mod
Function StartupDM()
	;trace(self, "This should not have been called")
endFunction

; Gives the player a random outfit and starting items
; TODO: Add more outfits
Function EquipPlayer()
	;trace(self, "This should not have been called")
EndFunction

; Dismisses the players current companions on death
; Not sure what will happen with other/quest-related companions
Function DismissCompanions()
	;trace(self, "This should not have been called")
EndFunction

; Spawn a clone of the player wearing their armor and items
Function SpawnandEquipClone()
	;trace(self, "This should not have been called")
EndFunction

Function DetermineSettlementCost()
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
	;trace(self, "This should not have been called")
	return 0
EndFunction
