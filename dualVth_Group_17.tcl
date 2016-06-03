proc leakage_opt {args} {
set arrivalTime ""
set criticalPaths ""
set slackWin ""
set clockPeriod [get_attribute [get_clock] period]
set slackWC [get_attribute [get_timing_paths  -to [all_outputs]] slack]
set epsilon 0.50
set void ""

	#set target_library [lappend target_library [lindex $link_library 4]]

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

	set celle_che_posso_cambiare [list]
	set wrt_path_collection [get_timing_paths]
	foreach_in_collection timing_point [get_attribute $wrt_path_collection points] {
		set cell_name [get_attribute [get_attribute $timing_point object] full_name]
		puts "$cell_name [get_attribute $timing_point arrival]"
		lappend celle_che_posso_cambiare $cell_name 
	}
	
	#set celle_che_non_posso_cambiare [list]
	#set wrt_path_collection [get_timing_paths -slack_lesser_than $epsilon -nworst 5000]
	#foreach_in_collection timing_point [get_attribute $wrt_path_collection points] {
		#set cell_name [get_attribute [get_attribute $timing_point object] full_name]
		#lappend celle_che_non_posso_cambiare $cell_name 
	#}
	
	#puts "celle_che_posso_cambiare: [sizeof_collection $celle_che_posso_cambiare]"
	#puts "celle_che_non_posso_cambiare: [sizeof_collection $celle_che_non_posso_cambiare]"
	
	#foreach_in_collection cell $celle_che_posso_cambiare {
		#set idx [lsearch $celle_che_posso_cambiare $cell]
		#puts $idx
		#set mylist [lreplace $celle_che_posso_cambiare $idx $idx]
		 #puts $cell

	#}
	
	
	set total_power 0
	#foreach_in_collection cell [get_cells] {
		#puts "[get_attribute $cell full_name] [get_attribute $cell cell_leakage_power]"
	#	set total_power [expr $total_power + [get_attribute $cell cell_leakage_power]]
	#}
	
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
