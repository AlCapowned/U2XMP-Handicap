class HandicapReplicationInfo extends ReplicationInfo;

/**
  * returns true if P1 should be sorted before P2
  */
simulated function bool InOrder( PlayerReplicationInfo P1, PlayerReplicationInfo P2 )
{
	// spectators are sorted last
    if( P1.bOnlySpectator )
    {
		return P2.bOnlySpectator;
    }
    else if ( P2.bOnlySpectator )
	{
		return true;
	}

	// sort by Score
    if( P1.Score < P2.Score )
	{
		return false;
	}
    if( P1.Score == P2.Score )
    {
		// if score tied, use deaths to sort
		if ( P1.Deaths > P2.Deaths )
			return false;

		// keep local player highest on list
		//if ( (P1.Deaths == P2.Deaths) && (PlayerController(P2.Owner) != None) && (LocalPlayer(PlayerController(P2.Owner).Player) != None) )
		if ( (P1.Deaths == P2.Deaths) && (PlayerController(P2.Owner) != None) )
			return false;
	}
    return true;
}

simulated function SortPRIArray()
{
    local int i,j;
    local PlayerReplicationInfo tmp;

    for (i=0; i<Level.Game.GameReplicationInfo.PRIArray.Length-1; i++)
    {
	for (j=i+1; j<Level.Game.GameReplicationInfo.PRIArray.Length; j++)
	{
	    if( !InOrder( Level.Game.GameReplicationInfo.PRIArray[i], Level.Game.GameReplicationInfo.PRIArray[j] ) )
	    {
			tmp = Level.Game.GameReplicationInfo.PRIArray[i];
			Level.Game.GameReplicationInfo.PRIArray[i] = Level.Game.GameReplicationInfo.PRIArray[j];
			Level.Game.GameReplicationInfo.PRIArray[j] = tmp;
	    }
	}
    }
}

defaultproperties
{

}
