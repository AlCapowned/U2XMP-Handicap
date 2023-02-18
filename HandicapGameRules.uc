class HandicapGameRules extends GameRules;

var HandicapMutator myMut;

function int NetDamage( int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
{
	local float adjust;
	local int injuredKills, instigatedByKills, killDiff;
	local ScoreKeeper keeper;


	if( XMPGame(Level.Game).ScoreKeeper? )
		keeper = XMPGame(Level.Game).ScoreKeeper;

	adjust=1.0;
	killDiff = 0;

	if( (keeper != None) && (InstigatedBy != None) && (InstigatedBy.PlayerReplicationInfo != None) && (Injured != None && Injured.PlayerReplicationInfo != None))
	{
       
		injuredKills = GetFrags(injured, keeper);
		instigatedByKills = GetFrags(InstigatedBy, keeper);

		killDiff = ABS(injuredKills - instigatedByKills);
		//log("killDiff: "$killDiff);
		if (instigatedByKills > 0 && injuredKills > instigatedByKills && killDiff >= myMut.KillDifferenceForDamageChange)
		{
			//log("Injured has more kills than instigator - take more damage");
			adjust = 1.0 * FMin(float(injuredKills / instigatedByKills),myMut.MaxDamageIncreasePct);
		}
		else if (injuredKills > 0 && instigatedByKills > 0 && injuredKills < instigatedByKills && killDiff >= myMut.KillDifferenceForDamageChange)
		{
			//log("Injured has fewer kills than instigator - take less damage");
			adjust = 1.0 * FMax(float(injuredKills / instigatedByKills),myMut.MaxDamageReductionPct);
		}
		else if (injuredKills == 0 && killDiff >= myMut.KillDifferenceForDamageChange )
		{
			adjust = myMut.MaxDamageReductionPct;
		}
		
        }


	return Super.NetDamage(OriginalDamage, Damage*Adjust, Injured, instigatedBy, Hitlocation, Momentum, damageType);
}

function int GetFrags( pawn P, Scorekeeper K )
{
	local int i;
	local Controller C;

	C = P.Controller;
	for( i=0; i < K.ScoreProfiles.Length; i++ )
		if( K.ScoreProfiles[i].PlayerID == C.PlayerReplicationInfo.PlayerID )
			return K.ScoreProfiles[i].ScoreFreq[6];
	return -1;
}


//
// server querying
//
function GetServerDetails( out GameInfo.ServerResponseLine ServerState )
{
	// append the gamerules name- only used if mutator adds me and deletes itself.
	local int i;
	i = ServerState.ServerInfo.Length;
	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "Mutator";
	ServerState.ServerInfo[i].Value = GetHumanReadableName();
}

defaultproperties
{
}
