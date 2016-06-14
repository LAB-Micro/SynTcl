proc leakage_opt {args} {
set arrivalTime ""
set criticalPaths ""
set slackWin ""
set clockPeriod [get_attribute [get_clock] period]

set epsilon 0.5
set void ""
array set celle_da_cambiare {}
array set celle_cambiate {}
set index 0
set maxIndex 100

	#set target_library [lappend target_library [lindex $link_library 4]]

	set timestart [clock seconds]
	
	[regexp {\-arrivalTime[^\d](\d+\.*\d*) *} $args void arrivalTime] 
	[regexp {\-criticalPaths[^\d](\d+) *} $args void criticalPaths] 
	[regexp {\-slackWin[^\d](\d+\.*\d*) *} $args void slackWin]
	
	set epsilon $slackWin

	if {$arrivalTime == "" || $criticalPaths == "" || $slackWin == ""} {
		return [list {0 0 0}]
	} 
	
	set slackWC [expr [get_attribute [get_timing_paths  -to [all_outputs]] slack] + ($clockPeriod - $arrivalTime)]

	if { $clockPeriod - $slackWC > $arrivalTime} {
		return [list {0 0 0}]
	}	
	
	
	#if { $clockPeriod - $arrivalTime < $slackWC } {
	#	return [list {0 0 0}]
	#}	

	
	
	if {$slackWC < $slackWin} {

		if {[sizeof_collection [get_timing_paths -to [all_outputs] -nworst $criticalPaths -slack_lesser_than $slackWin]] == $criticalPaths} {
			return [list {0 0 0}] 
		}	
	}
	#num_path: 209504
	set value 300000
	set value2 30
	set tot_cells [sizeof_collection [get_cells]]
	set pin_name ""

	array set celle_che_posso_cambiare {}
	
	# numeropath quello che ci ha dato
	# indice per evitare infinito
	# % leak saved (OPT)
	
	while { $index < $maxIndex || [sizeof_collection [get_timing_paths -to [all_outputs] -nworst $criticalPaths -slack_lesser_than $slackWin]] <= $criticalPaths} {
		set wrt_path_collection [get_timing_paths -slack_greater_than $epsilon -max_paths $value -nworst $value2 ]
		#set wrt_path_collection [get_timing_paths -slack_greater_than $epsilon -max_paths $value ]

		#dobbiamo verificare che non siano LH FATTO
		
		set num_celle_che_posso_cambiare 0
		foreach_in_collection timing_point [get_attribute $wrt_path_collection points] {

			set pin_name_temp [get_attribute [get_attribute $timing_point object] full_name]
			[regexp {(U\d+).*} $pin_name_temp void pin_name]
			set cell_name  [get_attribute $pin_name ref_name]
			#dobbiamo verificare che non siano LH FATTO
			if {[regexp {LL} $cell_name]} {
				if {[regexp {U\d+.*} $pin_name_temp]} {
					if {[regexp {\/[^Z].*} $pin_name_temp]} {
						set starttime [get_attribute $timing_point arrival]
					} else {
						set incrtime [expr [get_attribute $timing_point arrival] - $starttime]
			
						if {![info exists celle_che_posso_cambiare($pin_name,ref)]} {
							set celle_che_posso_cambiare($pin_name,ref) $cell_name
							set celle_che_posso_cambiare($pin_name,incL) [list $incrtime]
							set num_celle_che_posso_cambiare [expr $num_celle_che_posso_cambiare + 1]
						} else {
							set celle_che_posso_cambiare($pin_name,incL) [lsort -unique [lappend $celle_che_posso_cambiare($pin_name,incL) $incrtime]]
						}
					}
				}
			}
		}
	
		puts "----------------------------------------------------------------------------------"
		puts "VELOCI----------------------------------------------------------------------------"
		parray celle_che_posso_cambiare
		puts ""
	

		array set celle_che_non_posso_cambiare {}

		set wrt_path_collection [get_timing_paths -slack_lesser_than $epsilon -max_paths $value -nworst $value2]
		#set wrt_path_collection [get_timing_paths -slack_lesser_than $epsilon -max_paths $value]
		
		
		#dobbiamo verificare che non siano LH FATTO
		set num_celle_che_non_posso_cambiare 0
		foreach_in_collection timing_point [get_attribute $wrt_path_collection points] {

			set pin_name_temp [get_attribute [get_attribute $timing_point object] full_name]
		            [regexp {(U\d+).*} $pin_name_temp void pin_name]
		            set cell_name  [get_attribute $pin_name ref_name]
		            puts "celle_che_non_posso_cambiare: $pin_name"
		            #dobbiamo verificare che non siano LH FATTO
		            if {[regexp {LL} $cell_name]} {
				        if {[regexp {U\d+.*} $pin_name_temp]} {
				                if {![regexp {\/[^Z].*} $pin_name_temp]} {
		 
				                        if {![info exists celle_che_non_posso_cambiare($pin_name,ref)]} {
				                                set celle_che_non_posso_cambiare($pin_name,ref) $cell_name
							set num_celle_che_non_posso_cambiare [expr $num_celle_che_non_posso_cambiare + 1]
				                        } 
				                }
				        }
					}
		}

		    puts "----------------------------------------------------------------------------------"
		puts "LENTE-----------------------------------------------------------------------------"

		parray celle_che_non_posso_cambiare





		foreach_in_collection cell [get_cells] {
			set cell_name  [get_attribute $cell ref_name]
			if {![info exists celle_da_cambiare($cell,ref)]} {
				set nlist [split $cell_name "_"]
				set newname [lindex $nlist 0]
				append newname "_"
				if {[regexp {LLS} [lindex $nlist 1]]} {
					append newname "LHS"
				} else {
					append newname "LH"
				}
		
		
				append newname "_"
				append newname [lindex $nlist 2]
				#puts "$cell	[lindex $nlist 2]	$cell_name	$newname"
				size_cell $cell CORE65LPHVT/$newname
				}
		}
	
		puts "ho sostituito tutte in LH"
	
		#set wrt_path_collection [get_timing_paths -slack_greater_than $epsilon -max_paths $value -nworst $value2 ]
		set wrt_path_collection [get_timing_paths -slack_greater_than $epsilon -max_paths $value ]

		set num_celle_che_posso_cambiare 0
		foreach_in_collection timing_point [get_attribute $wrt_path_collection points] {

			set pin_name_temp [get_attribute [get_attribute $timing_point object] full_name]
			[regexp {(U\d+).*} $pin_name_temp void pin_name]
			set cell_name  [get_attribute $pin_name ref_name]
			if {[regexp {U\d+.*} $pin_name_temp]} {
				if {[regexp {\/[^Z].*} $pin_name_temp]} {
					set starttime [get_attribute $timing_point arrival]
				} else {
					set incrtime [expr [get_attribute $timing_point arrival] - $starttime]
			
					if {![info exists celle_che_posso_cambiare($pin_name,incH)]} {
						set celle_che_posso_cambiare($pin_name,incH) [list $incrtime]
						set num_celle_che_posso_cambiare [expr $num_celle_che_posso_cambiare + 1]
					} else {
						set celle_che_posso_cambiare($pin_name,incH) [lsort -unique [lappend $celle_che_posso_cambiare($pin_name,incH) $incrtime]]
					}
				}
			}
		}
	
	
		puts "----------------------------------------------------------------------------------"
		puts "LENTE dopo che ho aggiunto incH-----------------------------------------------------------------------------"

		parray celle_che_posso_cambiare
	
	
	
		#Questo for each deve essere fatto per get_cells - cambiate
		#fatto nel primo if
		
		
		foreach_in_collection cell [get_cells] {
			if {![info exists celle_cambiate($cell)]} {
				set cell_name  [get_attribute $cell ref_name]
				if {![info exists celle_da_cambiare($cell,ref)]} {
					set nlist [split $cell_name "_"]
					set newname [lindex $nlist 0]
					append newname "_"
		
		
					if {[regexp {LHS} [lindex $nlist 1]]} {
						append newname "LLS"
					} else {
						append newname "LL"
					}
		
		
		
					append newname "_"
					append newname [lindex $nlist 2]
					puts "$cell	[lindex $nlist 2]	$cell_name	$newname"
					size_cell $cell CORE65LPLVT/$newname
					}
				}
		}	
	
		puts "ho risostituito tutte in LL"




		puts ""
		puts "----------------------------------------------------------------------------------"
		puts "QUESTE SONO QUELLE REALMENTE CAMBIABILI ------------------------------------------"

		#array set celle_da_cambiare {}
		set num_celle_da_cambiare 0
		foreach id [array names celle_che_posso_cambiare] {
			if {![info exists celle_che_non_posso_cambiare($id)]} {
				#set celle_da_cambiare($id) $celle_che_posso_cambiare($id)
				#set num_celle_da_cambiare [expr $num_celle_da_cambiare + 1]
				if {[regexp {ref} $id]} {
					[regexp {(.*),ref} $id void pin_name]
					#get_lib_cells -of_objects $pin_name
					#set leak_L [get_attribute CORE65LPLVT/$celle_da_cambiare($id) cell_leakage_power]
				
					set nlist [split $celle_che_posso_cambiare($id) "_"]
					set newname [lindex $nlist 0]
					append newname "_"
					
					if {[regexp {LLS} [lindex $nlist 1]]} {
						append newname "LHS"
					} else {
						append newname "LH"
					}
		
					append newname "_"
					append newname [lindex $nlist 2]
					#puts "$newname:	[get_attribute CORE65LPHVT/$newname cell_leakage_power]"
					if {[get_attribute CORE65LPHVT/$newname cell_leakage_power] != "" && [info exists celle_che_posso_cambiare($pin_name,incH)]} {
						#puts "Entrato:	$newname"
						set celle_da_cambiare($id) $celle_che_posso_cambiare($id)
				        set num_celle_da_cambiare [expr $num_celle_da_cambiare + 1]
		     	        
		     	        set leak_L [get_attribute CORE65LPLVT/$celle_da_cambiare($id) cell_leakage_power]      
						set leak_H [get_attribute CORE65LPHVT/$newname cell_leakage_power]
					
						set diff [expr $leak_L - $leak_H]
						set celle_da_cambiare($pin_name,savLeak) $diff  
						set celle_da_cambiare($pin_name,refH) $newname
						#puts "$pin_name, $leak_H"
						set celle_da_cambiare($pin_name,k) [expr $diff / ([lindex $celle_che_posso_cambiare($pin_name,incH)  0] - [lindex $celle_che_posso_cambiare($pin_name,incL)  0]) ]
					}
				}
			} 
		}

		parray celle_da_cambiare


		set initial_power [compute_power]
		set initial_slack [get_attribute [get_timing_paths  -to [all_outputs]] slack]

		puts ""
		puts "----------------------------------------------------------------------------------"
		puts "ALGHORITM"


		set ll {}
		foreach id [array names celle_da_cambiare] {
			if {[regexp {(.*),refH} $id void pin_name]} {
				lappend ll " $pin_name $celle_da_cambiare($pin_name,ref)  $celle_da_cambiare($pin_name,refH) $celle_da_cambiare($pin_name,k) "
			}
		}
		set ll [lsort -real -decreasing  -index 3 $ll]
		puts "$ll"

		set num_celle_sost 0
		foreach elem $ll {
			set pin_name [lindex $elem 0]
			size_cell $pin_name CORE65LPHVT/[lindex $elem 2]
			#set num_celle_sost [expr $num_celle_sost + 1]
			set num_celle_sost [expr $num_celle_sost + 1]
			 puts "num path in SlachWin: [sizeof_collection [get_timing_paths -to [all_outputs] -nworst $criticalPaths -slack_lesser_than $slackWin]], slack: [get_attribute [get_timing_paths  -to [all_outputs]] slack]"
			if {[get_attribute [get_timing_paths  -to [all_outputs]] slack] < 0 || [sizeof_collection [get_timing_paths -to [all_outputs] -nworst $criticalPaths -slack_lesser_than $slackWin]] > $criticalPaths} {
				puts "dentro"
				size_cell $pin_name CORE65LPLVT/[lindex $elem 1]
				set num_celle_sost [expr $num_celle_sost - 1]
			} else {
				#Appendo in cambiate
				set celle_cambiate($pin_name) [lindex $elem 2]
			}
		}



	


	set after_power [compute_power]
	set after_slack [get_attribute [get_timing_paths  -to [all_outputs]] slack]
	puts "----------------"
	puts "tot celle: $tot_cells"
	puts "number of celle che posso cambiare: $num_celle_che_posso_cambiare"
	puts "number of celle che posso NON cambiare: $num_celle_che_non_posso_cambiare"
	puts "number of celle da cambiare: $num_celle_da_cambiare"
	puts "number of celle cambiate finora: [array size num_celle_cambiate]"
	#puts "number of celle cambiate finora: [array size $num_celle_cambiate]"
	set timefinish [clock seconds]
	#puts "num_path: $num_path"
	puts "time execution sec: [expr $timefinish - $timestart]"
	puts "time execution min: [expr ($timefinish - $timestart) / 60]"
	puts "period: $clockPeriod"
	puts "arrivalTime = $arrivalTime"
	puts "criticalPaths = $criticalPaths"
	puts "slackWin = $slackWin"
	puts "initial power: $initial_power"
	puts "after power: $after_power"
	puts "number of cell subst: $num_celle_sost"
	puts "POWER SAVE: [expr ($initial_power - $after_power) / $initial_power]"
	puts "initial slack: $initial_slack"
	puts "after slack: $after_slack"
	#leakage_opt -arrivalTime 1 -criticalPaths 300 -slackWin 0.1
	
	
	
	
	}
}

proc compute_power {} {
	set total_power 0

	foreach_in_collection cell [get_cells] {
			set total_power [expr $total_power + [get_attribute $cell cell_leakage_power]]
		}
	return $total_power
}

leakage_opt -arrivalTime 1 -criticalPaths 300 -slackWin 0.1
