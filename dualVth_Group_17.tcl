proc leakage_opt {args} {
set arrivalTime ""
set criticalPaths ""
set slackWin ""
set clockPeriod [get_attribute [get_clock] period]
set slackWC [get_attribute [get_timing_paths  -to [all_outputs]] slack]

set void ""
	[regexp {\-arrivalTime[^\d](\d+\.*\d*) *} $args void arrivalTime] 
	[regexp {\-criticalPaths[^\d](\d+) *} $args void criticalPaths] 
	[regexp {\-slackWin[^\d](\d+\.*\d*) *} $args void slackWin]

	if {$arrivalTime == "" || $criticalPaths == "" || $slackWin == ""} {
		return [list {0 0 0}]
	} 

	if { $clockPeriod - $slackWC < $arrivalTime} {
		return [list {0 0 0}]
	}	

	
	set total_power 0
	foreach_in_collection cell [get_cells] {
		set total_power [expr $total_power + [get_attribute $cell cell_leakage_power]]
	}
	
#set previousLeakage [get_attribute U440 cell_leakage_power]

#puts $wc_slack
puts $clockPeriod
puts $args
puts "arrivalTime = $arrivalTime"
puts "criticalPaths = $criticalPaths"
puts "slackWin = $slackWin"
puts $total_power

}

#leakage_opt -arrivalTime 1 -criticalPaths 300 -slackWin 0.1
