 proc leakage_opt {} {
	set timing_path [get_timing_path  -to [all_outputs]]
	set timing_points [get_attr $timing_path points]

	foreach_in_collection this_point $timing_points {
	#echo "object: [get_attr $this_point object]"
	echo "object_name: [get_object_name [get_attr $this_point object]]"
	#echo "get_cell: [get_cells -of_obj [get_object_name [get_attr $this_point object]]]"
	#echo "cell_name: [get_object_name [get_cells -of_obj [get_object_name [get_attr $this_point object]]]]"
	echo "------------"
	}
}
