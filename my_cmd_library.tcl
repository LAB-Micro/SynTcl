################################################################################
# Example of a new command with global variables
################################################################################
set var_reference 4
proc cmd_example {par1 par2} {
  global var_reference
  set op_result [expr $par1 * $par2]
  return [expr $var_reference + $op_result]
}

################################################################################
# A personalized report timing (PrimeTime command)
################################################################################
proc my_report_timing {} {
  set iter 1
  
  # Get the endpoint of the critical path
  set wcep [get_object_name [get_attribute [get_timing_paths] endpoint]]
  puts "Worst 5 critical paths ending in ${wcep}"
  puts "----------------------------------------------------------------------"
  puts [format "%-8s %-20s %-20s %-10s %-10s" "Path Nr." "Start point" "End point" "Arrival" "Slack"]
  puts "----------------------------------------------------------------------"
  foreach_in_collection path [get_timing_paths -to $wcep -nworst 5 -slack_greater_than 0] {
    # Extrapolate some information for each of the selected critical paths
    set tmp_sp [get_object_name [get_attribute $path startpoint]]
    set tmp_ep [get_object_name [get_attribute $path endpoint]]
    set tmp_ar [get_attribute $path arrival]
    set tmp_sl [get_attribute $path slack]
    puts [format "%-8s %-20s %-20s %-10s %-10s" $iter $tmp_sp $tmp_ep $tmp_ar $tmp_sl]
    incr iter
  }
  puts "----------------------------------------------------------------------"
}

################################################################################
# A personalized report cell proc (PrimeTime command)
################################################################################
proc my_report_cell {} {
  set total_power 0.0
  puts [format "%-20s %-20s %-8s %-15s %-15s %-15s" "Full name" "Reference name" "Size" "Area" "Leakage" "Dynamic"]
  puts "-----------------------------------------------------------------------------------------------"
  foreach_in_collection cell [get_cells] {
    # For each and every cell in the design, extrapolate some information
    set full_name [get_attribute $cell full_name]
    set ref_name [get_attribute $cell ref_name]
    set area [get_attribute $cell area]
    set leakage [get_attribute $cell leakage_power]
    set dynamic [get_attribute $cell dynamic_power]
    # Use regexp to efficiently get the size (last number in
    # the ref_name) of the cell
    regexp -nocase {[a-z0-9]+\_[a-z]+\_[a-z]+([0-9]+)} $ref_name junk size
    puts [format "%-20s %-20s %-8s %-15s %-15s %-15s" ${full_name} ${ref_name} ${size} ${area} ${leakage} ${leakage}]
    set total_power [expr $total_power + $dynamic + $leakage]
  }
  puts [format "Total power: %.4f W" $total_power]
}

################################################################################
# A personalized report on pins that belong to an
# user-specified cell (PrimeTime command)
################################################################################
proc my_report_pin {cell} {
  puts "Cell ${cell} pin information report"
  puts [format "%-15s %-10s %-15s %-15s" "Pin" "I/O" "Static prob." "Toggle rate"]
  puts "------------------------------------------------------"
  # Get pins that belong to the selected cell
  foreach_in_collection pin [get_pins "${cell}/*"] {
    set pin_name [get_object_name $pin]
    set direction [get_attribute $pin pin_direction]
    set sp [get_attribute $pin static_probability]
    set toggle [get_attribute $pin toggle_rate]
    puts [format "%-15s %-10s %-15s %-15s" $pin_name $direction $sp $toggle]
  }
  puts "------------------------------------------------------"
}
################################################################################
# Anlyze the effect of static probability on dynamic power (PrimeTime command)
################################################################################
proc my_update_switching_activity {node_name t1 tsim} {
  suppress_message PWR-601
  suppress_message PT-019
  suppress_message PWR-602
  suppress_message PSW-192
  # Get some info on the cell connected to the specified pin
  set ref_cell_name [get_attribute [get_cells -of_objects $node_name] ref_name]
  set full_cell_name [get_attribute [get_cells -of_objects $node_name] full_name]
  
  # Get the original dynamic power
  set original_dynamic [get_attribute [get_cells -of_objects $node_name] dynamic_power]
  
  # Get the original static probability, store it, and update it with the new value
  set original_sw [lindex [lindex [get_switching_activity -static_probability $node_name] 0] 1]
  set new_static_prob [expr $t1/$tsim]
  set_switching_activity $node_name -static_probability $new_static_prob
  
  # Retrieve the updated dynamic power
  set updated_dynamic [get_attribute [get_cells -of_objects $node_name] dynamic_power]
  
  # Print before/after results
  puts "\nAnalysis of static probability on dynamic power\n"
  puts [format "%-15s %-20s %-15s %-15s %-15s %-15s" "Full name" "Ref name" "Original Sw." "Original Dyn." "Updated Sw." "Updated Dyn."]
  puts "--------------------------------------------------------------------------------------------------"
  puts [format "%-15s %-20s %-15s %-15s %-15s %-15s" $full_cell_name $ref_cell_name $original_sw $original_dynamic $new_static_prob $updated_dynamic]
}
