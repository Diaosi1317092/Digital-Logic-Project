# 
# Synthesis run script generated by Vivado
# 

proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
set_param xicom.use_bs_reader 1
create_project -in_memory -part xc7a35tcsg324-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir D:/Verilog/DigitalProject/DigitalProject.cache/wt [current_project]
set_property parent.project_path D:/Verilog/DigitalProject/DigitalProject.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_output_repo d:/Verilog/DigitalProject/DigitalProject.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_verilog -library xil_defaultlib {
  D:/Verilog/DigitalProject/DigitalProject.srcs/sources_1/new/clock_divider.v
  D:/Verilog/DigitalProject/DigitalProject.srcs/sources_1/new/clock_divider_debounce.v
  D:/Verilog/DigitalProject/DigitalProject.srcs/sources_1/new/clock_divider_enable.v
  D:/Verilog/DigitalProject/DigitalProject.srcs/sources_1/new/keyboard_driver.v
  D:/Verilog/DigitalProject/DigitalProject.srcs/sources_1/new/lcd1602_display.v
  D:/Verilog/DigitalProject/DigitalProject.srcs/sources_1/new/lighting_function.v
  D:/Verilog/DigitalProject/DigitalProject.srcs/sources_1/new/power_set.v
  D:/Verilog/DigitalProject/DigitalProject.srcs/sources_1/new/search_function.v
  D:/Verilog/DigitalProject/DigitalProject.srcs/sources_1/new/seven_segment_display.v
  D:/Verilog/DigitalProject/DigitalProject.srcs/sources_1/new/smart_reminder.v
  D:/Verilog/DigitalProject/DigitalProject.srcs/sources_1/new/state_machine.v
  D:/Verilog/DigitalProject/DigitalProject.srcs/sources_1/new/timer.v
  D:/Verilog/DigitalProject/DigitalProject.srcs/sources_1/new/top_module.v
}
# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc D:/Verilog/DigitalProject/DigitalProject.srcs/constrs_1/new/constrain.xdc
set_property used_in_implementation false [get_files D:/Verilog/DigitalProject/DigitalProject.srcs/constrs_1/new/constrain.xdc]


synth_design -top top_module -part xc7a35tcsg324-1


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef top_module.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file top_module_utilization_synth.rpt -pb top_module_utilization_synth.pb"
