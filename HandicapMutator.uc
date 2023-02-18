//Heavy modifications for XMP by AlCapowned

class HandicapMutator extends Mutator
	config(HandicapConfig);

var() config float JumpJetCostReductionPct, JumpJetAfterDodgeCostReductionPct, 
	ReplenishRateIncreasePct, SprintCostReductionPct, HackRateIncreasePct; 
var() config int BonusReviveHealth, DeployProtectionIncrease; 
var() config float MaxDamageIncreasePct, MaxDamageReductionPct; 
var() config int KillDifferenceForDamageChange; //How large should the difference in frags be for damage to be adjusted?
var() config float CloseScoreThreshold, HackRateScoreThreshold, ReplenishRateScoreThreshold, 
	JumpJetScoreThreshold, SprintScoreThreshold, ReviveHealthScoreThreshold,
	DeployProtectionScoreThreshold;


function PostBeginPlay()
{
	local GameRules G;

	Super.PostBeginPlay();
	G = spawn(class'HandicapGameRules');
	HandicapGameRules(G).myMut = self;
	if ( Level.Game.GameRulesModifiers == None )
		Level.Game.GameRulesModifiers = G;
	else
		Level.Game.GameRulesModifiers.AddGameRules(G);

}

function ModifyPlayer(Pawn Other)
{
	local HandicapReplicationInfo hri, foundHRI;
	local U2Pawn P;
	local int HandicapNeed;


	//log("Handicap: Other is: "$Other);
	P = U2Pawn(Other);

	if (P == None || Other.Controller.PlayerReplicationInfo == None) return;

	foreach AllActors(class'HandicapReplicationInfo', foundHRI)
	{
		if (foundHRI.Owner == Other.Controller)
			hri = foundHRI;
	}	

	if (hri == None)
		hri = Spawn(class'HandicapReplicationInfo', Other.Controller);

	HandicapNeed = GetHandicapNeed(Other, hri);

	//log("HandicapNeed: "$handicapneed);



	if (HandicapNeed >= HackRateScoreThreshold)
	{
		P.HackRate += (P.HackRate * HackRateIncreasePct);
	}

	if (HandicapNeed >= ReplenishRateScoreThreshold)
	{
		if (ClassIsChildOf(Other.Class,class'Pawns.Ranger'))
			Ranger(Other).HealingRate += (Ranger(Other).HealingRate * ReplenishRateIncreasePct);
		else if (ClassIsChildOf(Other.Class,class'Pawns.Tech'))
			Tech(Other).RepairingRate += (Tech(Other).RepairingRate * ReplenishRateIncreasePct);
		else if (ClassIsChildOf(Other.Class,class'Pawns.Gunner'))
			Gunner(Other).EquippingRate += (Gunner(Other).EquippingRate * ReplenishRateIncreasePct);
	}
	
	if (HandicapNeed >= JumpJetScoreThreshold)
	{
		P.JumpJetCost -= (P.JumpJetCost * JumpJetCostReductionPct);
		P.JumpJetAfterDodgeCost -= (P.JumpJetAfterDodgeCost * JumpJetAfterDodgeCostReductionPct);
	}

	if (HandicapNeed >= SprintScoreThreshold)
	{

		P.SprintCost -= (P.SprintCost * SprintCostReductionPct);
	}

	if (HandicapNeed >= ReviveHealthScoreThreshold)
	{
		P.RevivedHealth += BonusReviveHealth;
	}

	if (HandicapNeed >= DeployProtectionScoreThreshold)
	{
		P.DeployProtectionTime += DeployProtectionIncrease;
		P.InitDeployProtection();
	}
}

/** return a value based on how much this pawn needs help - looks at opposite team */
function int GetHandicapNeed(Pawn Other, HandicapReplicationInfo hri)
{
	local float ScoreDiff;
	local int i;

	if ( Other.PlayerReplicationInfo == None )
	{
		return 0;
	}

	// base handicap on how far pawn is behind top scorer of the opposite team
	hri.SortPRIArray(); //Sorts from highest to lowest
    	for (i=0; i<Level.Game.GameReplicationInfo.PRIArray.Length-1; i++)
    	{
		if (Level.Game.GameReplicationInfo.PRIArray[i].Team.TeamIndex != Other.PlayerReplicationInfo.Team.TeamIndex)
		{
			ScoreDiff = Level.Game.GameReplicationInfo.PriArray[i].Score - Other.PlayerReplicationInfo.Score;
			break;
		}
	}
	//ScoreDiff = Level.Game.GameReplicationInfo.PriArray[0].Score - Other.PlayerReplicationInfo.Score;

	if ( ScoreDiff < CloseScoreThreshold )
	{
		// ahead or close
		return 0;
	}
	return ScoreDiff;// /3;
}

defaultproperties
{
	FriendlyName="Handicap"
	Description="Adjusts player damage based on kill ratio and grants various equalizers to worse-off players."
	JumpJetCostReductionPct=0.5
	JumpJetAfterDodgeCostReductionPct=0.3
	SprintCostReductionPct=0.5
	HackRateIncreasePct=0.4
	MaxDamageIncreasePct=1.75
	MaxDamageReductionPct=0.5
	ReplenishRateIncreasePct=0.75
	BonusReviveHealth=25
	DeployProtectionIncrease=4.0
	KillDifferenceForDamageChange=3
	CloseScoreThreshold=400
	HackRateScoreThreshold=1000
	ReplenishRateScoreThreshold=1000
	JumpJetScoreThreshold=2000
	SprintScoreThreshold=3000
	ReviveHealthScoreThreshold=2500
	DeployProtectionScoreThreshold=4000
	
}
