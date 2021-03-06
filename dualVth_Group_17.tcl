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
	#num_path: 209504
	set value 300000
	#set path_list [get_timing_path -to [all_outputs] -nworst $value -max_paths $value]
	#set num_path [sizeof_collection $path_list]
	#set path_slack [list]	
	#foreach_in_collection path $path_list {
		#lappend path_slack  $path_list [get_attribute $path_list slack]
	#}
	#puts $path_slack
	set celle_che_posso_cambiare [list]
	#set wrt_path_collection [get_timing_paths]
	set wrt_path_collection [get_timing_path -to [all_outputs] -nworst $value -max_paths $value]
	foreach_in_collection timing_point [get_attribute $wrt_path_collection points] {
		set cell_name [get_attribute [get_attribute $timing_point object] full_name]
		
		#puts "----------------------------------------------"
		#puts "$cell_name arrival: [get_attribute $timing_point arrival], load: [get_attribute [get_attribute $timing_point object] load]"
		#puts "$cell_name [get_attribute $timing_point capacitance]"
		#puts "$cell_name [get_attribute $timing_point delay]"
		#puts "$cell_name [get_attribute $timing_point delta_delay]"
		#puts "$cell_name [get_attribute $timing_point fanout]"
		#puts "$cell_name [get_attribute $timing_point full_name]"
		#puts "$cell_name [get_attribute $timing_point name]"
		#puts "$cell_name [get_attribute $timing_point object]"
		#puts "$cell_name [get_attribute $timing_point object_class]"
		#puts "$cell_name [get_attribute $timing_point object_name]"
		#puts "$cell_name [get_attribute $timing_point rise_fall]"
		#puts "$cell_name [get_attribute $timing_point transition]"
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
puts "num_path: $num_path"
puts "time execution [expr $timefinish - $timestart]"
puts "period: $clockPeriod"
puts "arrivalTime = $arrivalTime"
puts "criticalPaths = $criticalPaths"
puts "slackWin = $slackWin"
puts "total power: $total_power"

}

#get_lib_cells -of_objects U666
#set leak_L [get_attribute CORE65LPLVT/HS65_LL_NAND3AX6 cell_leakage_power]
#set leak_H [get_attribute CORE65LPHVT/HS65_LH_NAND3AX6 cell_leakage_power] sul server ritorna sempre zero o.O
#set diff [expr leak_L - leak_H]

#leakage_opt -arrivalTime 1 -criticalPaths 300 -slackWin 0.1
