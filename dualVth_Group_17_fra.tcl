proc leakage_opt {args} {
set arrivalTime ""
set criticalPaths ""
set slackWin ""
set clockPeriod [get_attribute [get_clock] period]

#set epsilon 0.5
set void ""
array set celle_cambiate {}
set index 0
set min_percentage 0.005
set flag_second 0
set constantIncr 5
set incrSlaWin 1
set maxCP 5000


	#set target_library [lappend target_library [lindex $link_library 4]]

	set timestart [clock seconds]
	
	[regexp {\-arrivalTime[^\d](\d+\.*\d*) *} $args void arrivalTime] 
	[regexp {\-criticalPaths[^\d](\d+) *} $args void criticalPaths] 
	[regexp {\-slackWin[^\d](\d+\.*\d*) *} $args void slackWin]
	set cp_user $criticalPaths
	set slackWin_user $slackWin
	
	set slackWin [expr $slackWin - ($arrivalTime - $clockPeriod)]

	if {$arrivalTime == "" || $criticalPaths == "" || $slackWin == ""} {
		return [list {0 0 0 0}]
	} 
	
	if {$arrivalTime == 0 || $slackWin == 0} {
		return [list {0 0 0 0}]
	} 


	set slackWC [expr [get_attribute [get_timing_paths  -to [all_outputs]] slack]]
	if { $arrivalTime < $clockPeriod - $slackWC } {
		return [list {0 0 0 0}]
	}

	set slackWC [expr [get_attribute [get_timing_paths  -to [all_outputs]] slack] + ($arrivalTime - $clockPeriod)]
	
	if {[sizeof_collection [get_timing_paths -to [all_outputs] -nworst $criticalPaths -slack_lesser_than $slackWin]] == $criticalPaths} {
			return [list {0 0 0 0}] 
		}	
		
	#num_path: 209504
	set value 300000
	set value2 30
	set tot_cells [sizeof_collection [get_cells]]
	set pin_name ""

	
	# numeropath quello che ci ha dato
	# indice per evitare infinito
	# % leak saved (OPT)
	
	set diff_percentage 10
	set initial_power [compute_power]
	set initial_slack [expr [get_attribute [get_timing_paths  -to [all_outputs]] slack] + ($arrivalTime - $clockPeriod)]
	set after_power [expr [compute_power] ]
	
	
	
	
	
	# puts "starting from incrSlaWin = $incrSlaWin, -slack_greater_than [expr $clockPeriod - $slackWin_user*$incrSlaWin]"

	
	set incrSlaWin 1
	while { [sizeof_collection [get_timing_paths -slack_greater_than [expr $clockPeriod - $slackWin_user*$incrSlaWin] -nworst $criticalPaths ]] == 0 } {
			set incrSlaWin [expr $incrSlaWin + 1]
			# puts "WHILE: size: [sizeof_collection [get_timing_paths -slack_greater_than [expr $clockPeriod - $slackWin_user*$incrSlaWin] -nworst $criticalPaths ]]	-slack_greater_than $clockPeriod - $slackWin_user*$incrSlaWin	[expr $clockPeriod - $slackWin_user*$incrSlaWin]"
	}
	
	while { [expr $clockPeriod - $slackWin_user*$incrSlaWin] > $slackWin } {
		set wrt_path_collection [get_timing_paths -slack_greater_than [expr $clockPeriod - $slackWin_user*$incrSlaWin] -nworst $criticalPaths ]
		set LH_list $wrt_path_collection
		#set wrt_path_collection_che_posso_cambiare [get_timing_paths -slack_greater_than $slackWin -nworst $criticalPaths ]
		#set wrt_path_collection [get_timing_paths -slack_greater_than $epsilon -max_paths $value -nworst $value2 ]
		#set wrt_path_collection [get_timing_paths -slack_greater_than $epsilon -max_paths $value ]
		
		array unset celle_che_posso_cambiare *
		array set celle_che_posso_cambiare {}

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
			
						if {![info exists celle_cambiate($pin_name)]} {
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
	
		# puts "----------------------------------------------------------------------------------"
		# puts "VELOCI----------------------------------------------------------------------------"
		# parray celle_che_posso_cambiare
		# puts ""
	

		array unset celle_che_non_posso_cambiare *
		array set celle_che_non_posso_cambiare {}

		set wrt_path_collection [get_timing_paths -slack_lesser_than $slackWin -nworst $criticalPaths]
		#set wrt_path_collection [get_timing_paths -slack_lesser_than $epsilon -max_paths $value]
		
		
		#dobbiamo verificare che non siano LH FATTO
		set num_celle_che_non_posso_cambiare 0
		foreach_in_collection timing_point [get_attribute $wrt_path_collection points] {

			set pin_name_temp [get_attribute [get_attribute $timing_point object] full_name]
		            [regexp {(U\d+).*} $pin_name_temp void pin_name]
		            set cell_name  [get_attribute $pin_name ref_name]
		            # puts "celle_che_non_posso_cambiare: $pin_name"
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

		    # puts "----------------------------------------------------------------------------------"
		# puts "LENTE-----------------------------------------------------------------------------"

		# parray celle_che_non_posso_cambiare





		foreach_in_collection cell [get_cells] {
		#puts "cella in LH: $cell"
			set cell_name  [get_attribute $cell ref_name]
			if {![info exists celle_cambiate([get_attribute $cell full_name])]} {
				set nlist [split $cell_name "_"]
				set newname [lindex $nlist 0]
				append newname "_"
				if {[regexp {LLS} [lindex $nlist 1]]} {
					append newname "LHS"
					append newname "_"
					append newname [lindex $nlist 2]
					# puts "$cell	[lindex $nlist 2]	$cell_name	$newname"
					size_cell $cell CORE65LPHVT/$newname
				} elseif {[regexp {LL} [lindex $nlist 1]]} {
					append newname "LH"
					append newname "_"
					append newname [lindex $nlist 2]
					# puts "$cell	[lindex $nlist 2]	$cell_name	$newname"
					size_cell $cell CORE65LPHVT/$newname
				}
				
			}
		}
	
		# puts "ho sostituito tutte in LH"
	
		#set wrt_path_collection_che_posso_cambiare [get_timing_paths -slack_greater_than $epsilon -max_paths $value -nworst $value2 ]
		# set wrt_path_collection [get_timing_paths -slack_greater_than $epsilon -max_paths $value ]
		
		#per le celle con -slack_greater_than $slackWin
		#set wrt_path_collection [get_timing_paths -slack_greater_than [expr $clockPeriod - $slackWin_user*$incrSlaWin] -nworst $criticalPaths ]
		#puts "prima"
		foreach_in_collection timing_point [get_attribute $LH_list points] {
		#puts "dentro"
			set pin_name_temp [get_attribute [get_attribute $timing_point object] full_name]
			[regexp {(U\d+).*} $pin_name_temp void pin_name]
			set cell_name  [get_attribute $pin_name ref_name]
			if {[regexp {U\d+.*} $pin_name_temp]} {
				if {[regexp {\/[^Z].*} $pin_name_temp]} {
					set starttime [get_attribute $timing_point arrival]
				} else {
					set incrtime [expr [get_attribute $timing_point arrival] - $starttime]
			
					if {[info exists celle_che_posso_cambiare($pin_name,ref)]} {
						if {![info exists celle_che_posso_cambiare($pin_name,incH)]} {
							set celle_che_posso_cambiare($pin_name,incH) [list $incrtime]
						} else {
							set celle_che_posso_cambiare($pin_name,incH) [lsort -unique [lappend $celle_che_posso_cambiare($pin_name,incH) $incrtime]]
						}
					}
				}
			}
		}
		#puts "dopo"
	
	
		# puts "----------------------------------------------------------------------------------"
		# puts "LENTE dopo che ho aggiunto incH-----------------------------------------------------------------------------"

		# parray celle_che_posso_cambiare
	
	
	
		#Questo for each deve essere fatto per get_cells - cambiate
		#fatto nel primo if
		
		
		foreach_in_collection cell [get_cells] {
		#puts "cella in LL: $cell"
			if {![info exists celle_cambiate([get_attribute $cell full_name])]} {
				set cell_name  [get_attribute $cell ref_name]
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
					#puts "$cell	[lindex $nlist 2]	$cell_name	$newname"
					size_cell $cell CORE65LPLVT/$newname
					
				}
		}	
	
		# puts "ho risostituito tutte in LL"




		# puts ""
		# puts "----------------------------------------------------------------------------------"
		# puts "QUESTE SONO QUELLE REALMENTE CAMBIABILI ------------------------------------------"

		array unset celle_da_cambiare *
		array set celle_da_cambiare {}
		
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

		# parray celle_da_cambiare

		set t_initial_power [compute_power]
		

		# puts ""
		# puts "----------------------------------------------------------------------------------"
		# puts "ALGHORITM"


		set ll {}
		foreach id [array names celle_da_cambiare] {
			if {[regexp {(.*),refH} $id void pin_name]} {
				lappend ll " $pin_name $celle_da_cambiare($pin_name,ref)  $celle_da_cambiare($pin_name,refH) $celle_da_cambiare($pin_name,k) "
			}
		}
		set ll [lsort -real -decreasing  -index 3 $ll]
		# puts "$ll"

		# set num_celle_sost 0
		foreach elem $ll {
			set pin_name [lindex $elem 0]
			
			size_cell $pin_name CORE65LPHVT/[lindex $elem 2]
			
			set slackWC [expr [get_attribute [get_timing_paths -to [all_outputs]] slack] + ($arrivalTime - $clockPeriod)]
			# puts "\nnum path in SlackWin: [sizeof_collection [get_timing_paths -to [all_outputs] -nworst $criticalPaths -slack_lesser_than $slackWin]], slack: $slackWC, $pin_name [get_attribute $pin_name ref_name] -> [lindex $elem 2]"
			
			
			
			if {$slackWC < 0 || [sizeof_collection [get_timing_paths -to [all_outputs] -nworst $cp_user -slack_lesser_than $slackWin]] >= $cp_user} {
				
				
				# puts "criticalPathsReali = [sizeof_collection [get_timing_paths -to [all_outputs] -nworst $cp_user -slack_lesser_than $slackWin]] [get_attribute $pin_name ref_name] -> [lindex $elem 1]"
				size_cell $pin_name CORE65LPLVT/[lindex $elem 1]
				# set num_celle_sost [expr $num_celle_sost - 1]
			} else {
				#Appendo in cambiate
				set celle_cambiate($pin_name) [lindex $elem 2]
			}
			
			
		}
		
		set index [expr $index +1]
		set incrSlaWin [expr $incrSlaWin + 1]
		
		set diff_percentage [expr ($after_power - [compute_power]) / $after_power]

		
	
		# parray celle_cambiate
		puts "number of celle che posso cambiare: $num_celle_che_posso_cambiare"
		puts "number of celle che posso NON cambiare: $num_celle_che_non_posso_cambiare"
		puts "number of celle da cambiare: $num_celle_da_cambiare"
		
		set after_power [compute_power]
		puts "PARTIAL POWER SAVED AT ITERATION $index:	[expr ($t_initial_power - $after_power) / $t_initial_power]"
		puts "flag_second = $flag_second"
		puts "incrSlaWin = $incrSlaWin"
		puts "-slack_greater_than [expr $clockPeriod - $slackWin_user*$incrSlaWin]"
		puts "PARTIAL criticalPaths = [sizeof_collection [get_timing_paths -to [all_outputs] -nworst $cp_user -slack_lesser_than $slackWin]]"
		puts "PARTIAL diff_percentage = $diff_percentage"
		puts "Searched Path (now) = $criticalPaths"
		puts "# Changed Cells: [array size celle_cambiate]"
		puts "# Up now sec: [expr [clock seconds] - $timestart]"
		puts "# Up now min: [expr ([clock seconds] - $timestart) / 60]"
		puts ""
		
	}

	

	
	
	# puts ""
	# puts "----------------------------------------------------------------------------------"
	# puts "ALGHORITM 2 "
	#WORK ONLY IF WRITE IN THE ./tech/STcmos65/synopsys_dc.setup 
	#set target_library [lappend target_library [lindex $link_library 4]]
	
	set num_of_cell_sub 0
	# decreasing the WIDTH reduce le leackage, increare le delay
	foreach id [array names celle_cambiate] {
		# puts "id: $id"
		set ff 0
		set init_cell [get_attribute $id ref_name]
		[regexp {X(\d*)$} $init_cell void xload]
		# puts "init_cell: $init_cell,	xload: $xload"
		foreach_in_collection cell [get_alternative_lib_cells $id] {
				set cell [get_attribute $cell full_name]
				# puts "	cell: $cell"
				if {[regexp {LH} $cell]} {
					[regexp {.*\/(.*)} $cell void ref]
					[regexp {X(\d*)$} $ref void xloadnew]
					# puts "		ref: $ref,	xloadnew < xload: $xloadnew < $xload"
					if {$xloadnew < $xload} {
						size_cell $id $cell
						set slackWC [expr [get_attribute [get_timing_paths -to [all_outputs]] slack] + ($arrivalTime - $clockPeriod)]
						# puts "		$id -> $cell"
						if {$slackWC < 0 || [sizeof_collection [get_timing_paths -to [all_outputs] -nworst $cp_user -slack_lesser_than $slackWin]] >= $cp_user} {
							# puts "		Torno indietro $id -> $init_cell"
							size_cell $id $init_cell
					} else {
						set init_cell $cell
						set xload $xloadnew
							if {$ff == 0} {
								set ff 1
								set num_of_cell_sub [expr $num_of_cell_sub + 1]
							}
						# puts "		found: new init_cell: $init_cell, new xloadnew: $xloadnew"
						}
					}
				}
			}
	}	
	
	puts "number of celle cambiate in ALGO2: $num_of_cell_sub"
	
	
	set timefinish [clock seconds]
	set after_power [compute_power]
	set after_slack [expr [get_attribute [get_timing_paths  -to [all_outputs]] slack] + ($arrivalTime - $clockPeriod)]
	set HVT_cells [expr [array size celle_cambiate]]
	set LVT_cells [expr  $tot_cells - $HVT_cells ]
	set HVT_perc [expr  $HVT_cells*100 / $tot_cells ]
	set LVT_perc [expr  $LVT_cells*100 / $tot_cells ]
	set HVT_perc2 [expr  $HVT_cells / $tot_cells ]
	set LVT_perc2 [expr  $LVT_cells / $tot_cells ]
	set power_saved [expr (($initial_power - $after_power) / $initial_power) * 100]
	set power_saved2 [expr (($initial_power - $after_power) / $initial_power)]
	set duration [expr $timefinish - $timestart]
	
	puts "----------------"
	puts "arrivalTime = $arrivalTime"
	puts "criticalPaths = $cp_user"
	puts "slackWin = $slackWin_user"
	puts "period: $clockPeriod"
	puts "tot celle: $tot_cells"
	
	puts "number of celle cambiate: [array size celle_cambiate]"
	
	puts "initial slack: $initial_slack"
	puts "after slack: $after_slack"
	puts "criticalPathsReali = [sizeof_collection [get_timing_paths -to [all_outputs] -nworst [expr  $cp_user + 10000 ] -slack_lesser_than $slackWin]]"
	puts "POWER SAVE:	$power_saved %"
	puts "DURATION sec: $duration"
	puts "DURATION min: [expr $duration / 60]"
	puts "LVT:		 	 $LVT_cells"
	puts "HVT:		 	 $HVT_cells"
	puts "LVT_perc:		 $LVT_perc %"
	puts "HVT_perc:		 $HVT_perc %"
	
	set list_to_return [list $power_saved2 $duration $LVT_perc2 $HVT_perc2] 
	return $list_to_return

	}

proc compute_power {} {
	set total_power 0

	foreach_in_collection cell [get_cells] {
			set total_power [expr $total_power + [get_attribute $cell cell_leakage_power]]
		}
	return $total_power
}

#source ./scripts/synthesis.tcl
leakage_opt -arrivalTime 3.5 -criticalPaths 300 -slackWin 0.1
