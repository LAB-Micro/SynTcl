proc leakage_opt {args} {
set arrivalTime ""
set criticalPaths ""
set slackWin ""
set clockPeriod [get_attribute [get_clock] period]
set slackWC [get_attribute [get_timing_paths  -to [all_outputs]] slack]

set void ""

	set target_library [lappend target_library [lindex $link_library 4]]

	set timestart [clock seconds]
	
	[regexp {\-arrivalTime[^\d](\d+\.*\d*) *} $args void arrivalTime] 
	[regexp {\-criticalPaths[^\d](\d+) *} $args void criticalPaths] 
	[regexp {\-slackWin[^\d](\d+\.*\d*) *} $args void slackWin]

	if {$arrivalTime == "" || $criticalPaths == "" || $slackWin == ""} {
		return [list {0 0 0}]
	} 

	if { $clockPeriod - $slackWC < $arrivalTime} {
		return [list {0 0 0}]
	}	


	if {$slackWC < $slackWin} {
		set count 0
		foreach_in_collection path [get_timing_paths -to [all_outputs] -nworst $criticalPaths -slack_lesser_than $slackWin] {
			set count [expr $count + 1]
		}
		
		if {$count == $criticalPaths} {
			return [list {0 0 0}] 
		}	
	}

	
	set total_power 0
	foreach_in_collection cell [get_cells] {
		#puts "[get_attribute $cell full_name] [get_attribute $cell cell_leakage_power]"
		set total_power [expr $total_power + [get_attribute $cell cell_leakage_power]]
	}
	
#set previousLeakage [get_attribute U440 cell_leakage_power]

#puts $wc_slack

set timefinish [clock seconds]

puts [expr $timefinish - $timestart]
puts $clockPeriod
puts "arrivalTime = $arrivalTime"
puts "criticalPaths = $criticalPaths"
puts "slackWin = $slackWin"
puts $total_power

}

#leakage_opt -arrivalTime 1 -criticalPaths 300 -slackWin 0.1
