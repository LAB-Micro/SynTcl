 proc leakage_opt {} {
	set wcep [get_object_name [get_attribute [get_timing_paths] endpoint]]
	puts "Worst 5 critical paths ending in ${wcep}"
	foreach_in_collection path [get_timing_paths -to $wcep -nworst 5 -slack_greater_than 0] {
    		set tmp_ep [get_object_name [get_attribute $path endpoint]]
    		set tmp_ar [get_attribute $path arrival]
    		set tmp_sl [get_attribute $path slack]
    		
		puts "endpoint:	$tmp_ep"
    		puts "arrival:	$tmp_ar"
    		puts "slack:	$tmp_sl"
    		puts ""
		report_attribute $path
		#get_attributes

  }
}
