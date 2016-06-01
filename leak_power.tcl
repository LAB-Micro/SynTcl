################################################################################
# This command returns leakage power of the cell specified in the
# parameter list.
#
# Command tested in Design Compiler Version K-2015.06-SP2-1
#
# TODO: the returned value includes units, e.g., 1.373nW; it is up to you to
# correctly handle scale conversions, e.g., from nW to uW.
# TODO: you can tune the $lnr and $wnr variables to retrieve other information
# from the output of the report_power command.
################################################################################
proc leak_power {cell_name} {
  set report_text ""  ;# Contains the output of the report_power command
  set lnr 3           ;# Leakage info is in the 2nd line from the bottom
  set wnr 7           ;# Leakage info is the eighth word in the $lnr line 
  redirect -variable report_text {report_power -only $cell_name -cell -nosplit}
  set report_text [split $report_text "\n"]
  return [lindex [regexp -inline -all -- {\S+} [lindex $report_text [expr [llength $report_text] - $lnr]]] $wnr]
}
