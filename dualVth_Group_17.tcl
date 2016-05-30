 proc leakage_opt {args} {
	[regexp {-arrivalTime[^\d]*(\d+\.*\d*)} $args void arrivalTime] 
	[regexp {–criticalPaths[^\d]*(\d+)} $args void criticalPaths] 
	[regexp {–slackWin[^\d]*(\d+\.*\d*)} $args void slackWin] 
puts $arrivalTime
puts $criticalPaths
puts $slackWin
}
