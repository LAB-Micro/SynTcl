set var_list [list]
foreach var [list 1 2 3 4 5 6 7 8 9 10] {
    lappend var_list $var 
} 

# In PrimeTime
foreach_in_collection point_cell [get_cells] {
	set cell_name [get_attribute $point_cell full_name ]
	set cell_type [get_attribute $point_cell is_combinational]
	if { $cell_type == true } {
		puts "$cell_name is combinational"
	else {
		puts "$cell_name is not combinational"
	}
}

# Maybe work in dc_shell
list_attributes -class cell -application

# return num of path
set path_list [get_timing_paths -from A -to B]
set num_path [sizeof_collection $path_list]

#return arrival time
set wrt_arrival [get_attribute [get_timing_path] arrival]

#extract the list of cells belonging to the most critical paths
set wrt_path_collection [get_timing_paths]
foreach_in_collection timing_point [get_attribute $wrt_path_collection points] {
	set cell_name [get_attribute [get_attribute $timing_point object] full_name]
}

#Use to see attributes
list_attribute -application -class timing_path
list_attribute -application -class timing_point

#LAB3.2.2 (HISTOGRAM) può essere utile per la slack window

