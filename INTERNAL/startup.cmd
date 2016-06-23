#
# Property of ABB Vasteras/Sweden. All rights reserved.
# Copyright 2003.
#
# Startup.cmd script for 5.0
#
###########################################################
# Option startup info
#
# To execute Option related tasks in the startup, there are
# five places in the startup sequence that can be used.
# Depending on which dependencies the tasks have, the user 
# must select the most suitable place for the Option startup.
#
# In each place, a check is done for a unique named file.
# (These files are created/appended during install sequence.)
# The files checked for in the INTERNAL: folder are named:
# opt_l0.cmd, option.cmd, opt_l1.cmd, opt_l2.cmd, opt_l3.cmd
# If the file exist, then it will be included in the startup.
#
# Search for each file to get info/tip about how to use it.
#
###########################################################

startup_log -file $RAMDISK/startup.log

# Base support initialization start.

if_os -type LINUX -label ADD_EXTRA_STACK
goto -label NEXT_STEP
#ADD_EXTRA_STACK
invoke2 -entry os_add_extra_stack -format int -int1 10000
#NEXT_STEP

baseinit

# Initialize and enable system dump service
sysdmp_init -max_dumps 3 -delay 100 -dir $INTERNAL/SYSDMP -compr no
ifvc -label VC_SKIP_SYSDMPTASK
task -slotname sysdmpts -slotid 82 -pri 253 -vwopt 0x1c -stcks 50000 -entp sysdmpts_main -auto
#VC_SKIP_SYSDMPTASK

sysdmp_add -source print_spooler -save print_spooler_save_buffer
uprobe_init -points 50000 -pretrig_points 45000 -trace_buf_sz 10000
sysdmp_add -class uprobe

# Include command file for logging mechanisms. Mainly used for uprobes
fileexist -path $SYSTEM/service_debug_early.cmd -label LOAD_CMD
goto -label NEXT_STEP
#LOAD_CMD
include -path $SYSTEM/service_debug_early.cmd
sysdmp_add_logfile -move 0 -file "$SYSTEM/service_debug_early.cmd"
#NEXT_STEP

ifvc -label NO_WVLOG
if_os -type LINUX -label NO_WVLOG
# wvLogging is started after service_debug_early.cmd, make it possible to 
# raise the level of logging by using wvLogSysdmpEvtClassSet
sysdmp_add -source wvlog -start wvLogSysdmpStart -stop wvLogSysdmpStop -save wvLogSysdmpSave
#NO_WVLOG

# Start event log 
task -slotname elogts -slotid 1 -pri 85 -vwopt 0x1c -stcks 7000 -entp elog_main -auto
synchronize -level task
go -level task

# Start listening on command device for Linux
if_os -type LINUX -label LINUX_CMDDEV
goto -label LINUX_CMDDEV_END
#LINUX_CMDDEV
task -slotname cmddev_ts -entp cmddev_ts -pri 152 -vwopt 0x1c -stcks 8000 -auto -nosync
#LINUX_CMDDEV_END

# Enable Service Box in devices
invoke -entry RemoteDiagnosticInit -noarg -nomode

task -slotname delay_high -entp delay_ts -pri 60 -vwopt 0x1c -stcks 8000 -nosync -auto -wait_ready 10
task -slotname delay_medium -entp delay_ts -pri 78 -vwopt 0x1c -stcks 20000 -nosync -auto -wait_ready 10
task -slotname delay_low -entp delay_ts -pri 140 -vwopt 0x1c -stcks 8000 -nosync -auto -wait_ready 10

if_os -type LINUX -label LINUX_MIO
goto -label LINUX_MIO_END
#LINUX_MIO
task -entp mio_ts -pri 153 -opt 0x1000000 -stcks 8000 -auto -nosync
#LINUX_MIO_END

basenew
# Base support initialization finished.

ifvc -label NEXT_STEP
# Restore system.xml if needed
fileexist -path $SYSTEM/system.xml -label NEXT_STEP
fileexist -path $INTERNAL/system.xml -label COPY_SYS_XML
echo -text "No system.xml exist neither in SYSTEM or INTERNAL folder"
goto -label NEXT_STEP
#COPY_SYS_XML
echo -text "Restore system.xml from the INTERNAL folder"
copy -from $INTERNAL/system.xml -to $SYSTEM/system.xml
copy -from $INTERNAL/system.xml -to $INTERNAL/system.xml.err
delay -time 1000
echo -text "System is restarted"
restart
#NEXT_STEP

ifvc -label VC_NO_MC_PSU_UPGRADE
if_os -type LINUX -label LINUX_NO_PSU_UPGRADE

### Check PSU board firmware version
invoke -entry psu_upgrade -noarg -nomode
#VC_NO_MC_PSU_UPGRADE
goto -label NEXT_STEP

#LINUX_NO_PSU_UPGRADE
print -text "LINUX TODO: Firmware check is not yet implemented for Linux"
#NEXT_STEP

ifvc -label VC_NO_MC_FPGA_UPGRADE
if_os -type LINUX -label LINUX_NO_FPGA_UPGRADE

### Check Main Computer FPGA firmware version
invoke -entry fpgar11_firmw_upgrade -noarg -nomode
#VC_NO_MC_FPGA_UPGRADE
goto -label NEXT_STEP

#LINUX_NO_FPGA_UPGRADE
print -text "LINUX TODO: Fpga firmware check is not yet implemented for Linux"
#NEXT_STEP

iomgrinstall -entry simFBC -name /simfbc
creat -name /simfbc/SIM_SIM1: -pmode 0
creat -name /simfbc/SIM_SIM2: -pmode 0

invoke -entry read_init

# VC SKIP #2
ifvc -label VC_RCC_SKIP1
invoke -entry fpgar11_init
iomgrinstall -entry rccfbc -name /rccfbc
creat -name /rccfbc/LOC_LOC1: -pmode 0

task -slotname LOCALBUS -entp read_ts -pri 71 -vwopt 0x1c -stcks 10000 -nosync -auto
readparam -devicename /LOC_LOC1:/bus_read -rmode 1 -buffersize 100
goto -label VC_RCC_SKIP2

#VC_RCC_SKIP1
creat -name /simfbc/LOC_LOC1: -pmode 0 -errlabel ERROR_RCCFBC
#VC_RCC_SKIP2

#ERROR_RCCFBC
if_os -type LINUX -label LINUX_NO_USERSIO
iomgrinstall -entry UserSio -name /usersio

# Handle COM1
ifvc -label VC_COM1
invoke2 -entry DebugCardPresent -format void -errlabel NEXT_STEP
#VC_COM1
echo -text "Installing COM1 device"
creat -name /usersio/SIO1: -pmode 0
goto -label NEXT_STEP

#LINUX_NO_USERSIO
print -text "LINUX TODO: Usersio is not yet implemented for Linux"
#NEXT_STEP

# Fieldbus command interface
ifvc -label VC_SKIP_FCI
if_os -type LINUX -label LINUX_NO_FCI
iomgrinstall -entry Fci -name /fci
creat -name /fci/FCI1: -pmode 0

task -slotname fcits -slotid 80 -pri 80 -vwopt 0x1c -stcks 10000 -entp fcits -auto

#VC_SKIP_FCI
goto -label NEXT_STEP

#LINUX_NO_FCI
print -text "LINUX TODO: Fieldbus command interface is not yet implemented for Linux"
#NEXT_STEP

###########################################		
# opt_l0.cmd - Option startup Sequence no 1
# Example of:
#  - users: Eio, MotionRef, Paint
#  - use: Create/Enable of I/O interfaces, Start of option task 
#  - dependencies: baseinit, sysdmp, elogts, delay tasks, simFBC, rccfbc, UserSio, Fci
#  - why here: Must be done before init, task and reconfigure of eio and sio
#
fileexist -path $INTERNAL/opt_l0.cmd -label LOAD_CMD
goto -label NEXT_STEP
#LOAD_CMD
include -path $INTERNAL/opt_l0.cmd
#NEXT_STEP

# Check if Python shal be enabled or not
fileexist -path $HOME/enable_python -label USE_PYTHON
goto -label NEXT_STEP
#USE_PYTHON

# Increase number of available interpreters for basic use (20MB memory)
python_config -incr_interpreters 1 -memsize 20971520

# Initialize Python support, including the pyrobapi. Starts all interpreters as configured.
invoke2 -entry pyrobapi_init -format void
python_init

invoke2 -entry rw_dispatcher_init -format void

#NEXT_STEP

init -resource eio
init -resource sio
init -resource motion
init -resource cab
init -resource bar
init -resource prdsta
init -resource pgmrun
init -resource rapid
init -resource puscfg


task -slotname alarmts -slotid 16 -pri 80 -vwopt 0x1c -stcks 7000 \
-entp alarmts -auto

ifvc -label VC_CABSUPTS_SKIP
task -slotname cabsupts -slotid 62 -pri 135 -vwopt 0x1c -stcks 7000 \
-entp rapidsup_main -auto
#VC_CABSUPTS_SKIP

task -slotname pstopts -pri 30 -vwopt 0x1c -stcks 5000 \
-entp pstopts_main -auto -nosync

task -slotname rhaltts -pri 30 -vwopt 0x1c -stcks 5000 \
-entp rhaltts_main -auto -nosync

task -slotname eiocrsts -slotid 56 -pri 74 -vwopt 0x1c -stcks 10000 \
-entp eiocrsts -auto

task -slotname eiots -slotid 54 -pri 70 -vwopt 0x1c -stcks 10000 \
-entp eiots -auto -slots 2

task -slotname eioadmts -slotid 55 -pri 76 -vwopt 0x1c -stcks 25000 \
-entp eioadmts -auto

reconfigure -resource eio
io_synchronize -timeout 30000

reconfigure -resource sio

task -slotname safevtts  -slotid 20 -pri 20 -vwopt 0x1c -stcks 10000 \
-entp safevtts -auto

task -slotname safcycts  -slotid 29 -pri 80 -vwopt 0x1c -stcks 10000 \
-entp safcycts -auto

task -slotname sysevtts  -slotid 30 -pri 95 -vwopt 0x1c -stcks 30000 \
-entp sysevtts_main -auto

task -slotname ipolts0 -slotid 65 -pri 90 -vwopt 0x1c -stcks 65000 \
-entp ipolts_main -auto

task -slotname ipolts1 -slotid 66 -pri 90 -vwopt 0x1c -stcks 65000 \
-entp ipolts_main -auto

task -slotname ipolts2 -slotid 67 -pri 90 -vwopt 0x1c -stcks 65000 \
-entp ipolts_main -auto

task -slotname ipolts3 -slotid 68 -pri 90 -vwopt 0x1c -stcks 65000 \
-entp ipolts_main -auto

task -slotname ipolts4 -slotid 91 -pri 90 -vwopt 0x1c -stcks 65000 \
-entp ipolts_main -auto

task -slotname ipolts5 -slotid 92 -pri 90 -vwopt 0x1c -stcks 65000 \
-entp ipolts_main -auto

task -slotname statmats -slotid 64 -pri 6 -vwopt 0x1c -stcks 24000 \
-entp statmats -auto

task -slotname compliance_masterts -slotid 124 -pri 8 -vwopt 0x1c -stcks 65000 \
-entp compliance_masterts -auto

task -slotname sens_memts -slotid 89 -pri 150 -vwopt 0x1c -stcks 20000 \
-entp sens_memts -auto

task -slotname servots0 -slotid 69 -pri 5 -vwopt 0x1c -stcks 65000 \
-entp servots -auto -slots 2

task -slotname servots1 -slotid 71 -pri 5 -vwopt 0x1c -stcks 65000 \
-entp servots -auto -slots 2

task -slotname servots2 -slotid 73 -pri 5 -vwopt 0x1c -stcks 65000 \
-entp servots -auto -slots 2

task -slotname servots3 -slotid 75 -pri 5 -vwopt 0x1c -stcks 65000 \
-entp servots -auto -slots 2

task -slotname servots4 -slotid 93 -pri 5 -vwopt 0x1c -stcks 65000 \
-entp servots -auto -slots 2

task -slotname servots5 -slotid 95 -pri 5 -vwopt 0x1c -stcks 65000 \
-entp servots -auto -slots 2

task -slotname evhats -slotid 117 -pri 3 -vwopt 0x1c -stcks 20000 \
-entp evhats -auto

task -slotname mcits -slotid 133 -pri 4 -vwopt 0x1c -stcks 20000 \
-entp mcits -auto

task -slotname refmats -slotid 52 -pri 2 -vwopt 0x1c -stcks 65000 \
-entp refmats -auto

task -slotname mocutilts -slotid 135 -pri 170 -vwopt 0x1c -stcks 20000 \
-entp mocutilts -auto

ifvc -label VC_SKIP_SIS
task -slotname sismats -slotid 63 -pri 106 -vwopt 0x1c -stcks 12500 \
-entp sismats -auto 
#VC_SKIP_SIS

task -slotname bcalcts -slotid 44 -pri 200 -vwopt 0x1c -stcks 45000 \
-entp bcalcts -auto

task -slotname logsrvts -slotid 51 -pri 100 -vwopt 0x1c -stcks 30000 \
-entp logsrvts -auto

ifvc -label RW_MOTION_END
task -slotname com_rec_fdbts -slotid 77 -pri 2 -vwopt 0x1c -stcks 5000 -entp com_rec_fdbts -auto

task -slotname axc_failts -slotid 28 -pri 80 -vwopt 0x1c -stcks 7000 -entp axc_failts -auto

#RW_MOTION_END

task -slotname peventts -slotid 21 -pri 65 -vwopt 0x1c -stcks 45000 \
-entp peventts -auto


if_os -type LINUX -label LINUX_NO_RLOAD
task -slotname rloadts -slotid 45 -pri 126 -vwopt 0x1c -stcks 40000 \
-entp rloadts -auto
goto -label NEXT_STEP

#LINUX_NO_RLOAD
print -text "LINUX TODO: rload not yet migrated to Linux"

#NEXT_STEP

task -slotname barts -slotid 79 -pri 140 -vwopt 0x1c -stcks 80000 \
-entp barts_main -auto

task -slotname rlcomts -slotid 27 -pri 100 -vwopt 0x1c -stcks 12000 \
-entp rlcomts_main -auto

if_os -type LINUX -label LINUX_NO_RSOCKETS
task -slotname rlsocketts -slotid 108 -pri 99 -vwopt 0x1c -stcks 8000 \
-entp rlsocketts_main -auto
task -slotname rlsocketts_rec -slotid 120 -pri 99 -vwopt 0x1c -stcks 8000 \
-entp rlsocketts_rec_main -auto -noreg
goto -label NEXT_STEP

#LINUX_NO_RSOCKETS
print -text "LINUX TODO: RAPID sockets not yet migrated to Linux"


#NEXT_STEP

# Check if RobAPI2 shal be enabled or not
fileexist -path $HOME/enable_robapi2 -label USE_ROBAPI2
goto -label NEXT_STEP
#USE_ROBAPI2

if_os -type LINUX -label LINUX_NO_ROBAPI2

# Initialize the memory-pool for RobAPI 2. This should be done before spawning any other task.
invoke2 -entry init_mempools -format void

task -slotname appweb -slotid 129 -pri 125 -vwopt 0x1c -stcks 120000 \
-entp AppwebEntryFunc -auto -noreg

task -slotname servdisp -slotid 126 -pri 125 -vwopt 0x1c -stcks 90000 \
-entp servdispts -auto -noreg

task -slotname servlist -slotid 127 -pri 125 -vwopt 0x1c -stcks 90000 \
-entp ServiceListingTS -auto -noreg

task -slotname rwservice -slotid 42 -pri 125 -vwopt 0x1c -stcks 65000 \
-entp rwsvcts_main -auto -noreg

task -slotname rwssubsc -slotid 132 -pri 125 -vwopt 0x1c -stcks 65000 \
-entp rwssubscr_main -auto -noreg

task -slotname rwssubsc_worker -slotid 128 -pri 125 -vwopt 0x1c -stcks 65000 \
-entp rwssubscr_worker -auto -noreg

task -slotname filesrv -slotid 130 -pri 125 -vwopt 0x1c -stcks 120000 \
-entp rapi_fileservts_main -auto -noreg

task -slotname ctrlsrvts -slotid 134 -pri 125 -vwopt 0x1c -stcks 90000 \
-entp rapi_ctrlsrvts -auto -noreg

task -slotname cnmgrts -slotid -1 -pri 125 -vwopt 0x1c -stcks 90000 \
-entp cleanupts -auto -noreg

task -slotname subscription -slotid -1 -pri 125 -vwopt 0x1c -stcks 120000 \
-entp rapi_subscriptionts_main -auto -noreg

task -slotname rws_dipc -slotid -1 -pri 125 -vwopt 0x1c -stcks 65000 \
-entp rwsdipc_main -auto -noreg

task -slotname rapi_user -slotid 131 -pri 125 -vwopt 0x1c -stcks 90000 \
-entp rapi_usersrvts -auto -noreg

goto -label NEXT_STEP

#LINUX_NO_ROBAPI2
print -text "LINUX TODO: RobAPI II is not yet migrated to Linux"

#NEXT_STEP
task -slotname rapidts -slotid 17 -pri 101 -vwopt 0x1c -stcks 78000 \
-entp rapidts_main -auto

task -slotname sysorchts -slotid 19 -pri 100 -vwopt 0x1c -stcks 78000 \
-entp sysorchts_main -auto

task -slotname cabts -slotid 6 -pri 99 -vwopt 0x1c -stcks 78000 \
-entp cabts_main -auto

task -slotname mocts -slotid 9 -pri 100 -vwopt 0x1c -stcks 78000 \
-entp motion_main -auto

task -slotname hpjts -slotid 22 -pri 99 -vwopt 0x1c -stcks 65000 \
-entp hpj_main -auto

ifvc -label VC_NETCMD_SKIP
task -slotname elog_axctsr -pri 100 -vwopt 0x1c -stcks 9000 \
-entp elog_axctsr -auto -nosync
#VC_NETCMD_SKIP

synchronize -level task
delay -time 500
go -level task

ifvc -label VC_AXC_SKIP
netcmd_run
#VC_AXC_SKIP

#PNT new -entry purge_sync
#PNT delay -time 5000

###########################################		
# option.cmd - Option startup Sequence no 2
# Example of:
#  - users: 3P, Cap, Eio, MotionRef, Paint, SensorInterfaces, SpotWeld
#  - use: Start of option task, invoke of init/sync methods, convey_new, sysdefs
#  - dependencies: Init of resources, reconfig of eio/sio, most of the system task created, synched and started
#  - why here: Must be done before new of motion and rapid, connect_dependings -object SYS_STORED_OBJ_CAB
#
fileexist -path $INTERNAL/option.cmd -label LOAD_CMD
goto -label NEXT_STEP
#LOAD_CMD
include -path $INTERNAL/option.cmd
#NEXT_STEP


ifvc -label VC_AXC_SKIP

if_os -type LINUX -label LINUX_NO_AXC_FIRMWARE_CHECK
print -text "Check AXC board firmware version ..."
invoke -entry netcmd_upgrade -arg 0 -strarg "axcfirmw_upgrade" -nomode
invoke -entry axcfirmw_devices_install_hook -nomode
print -text "Check drive unit board firmware version ..."
invoke -entry netcmd_upgrade -arg 0 -strarg "drive_unit_firmw_upgrade" -nomode
invoke -entry drive_unit_firmw_devices_install_hook -nomode
goto -label NEXT_STEP

#LINUX_NO_AXC_FIRMWARE_CHECK
print -text "LINUX TODO: AXC Firmware check is not yet implemented for Linux"

#NEXT_STEP

#VC_AXC_SKIP
new -resource motion
delay -time 1500
connect_dependings -object SYS_STORED_OBJ_CAB -instance 0 -man 0 -ipm 0 -servo 0 -ipol 0 -statma 0

# syncronization (setsync) to be used with network systems only
# setsync
if -var 52 -value 1 -label SYNCROB
goto -label NOSYNC
#SYNCROB
# syncronization (setsync) to be used with network systems only
setsync
#NOSYNC

synchronize -level task
go -level task

new -resource rapid

###########################################		
# opt_l1.cmd - Option startup Sequence no 3
# Example of:
#  - users: 3P
#  - purpose: Start of option tasks, invoke methods that access sdb and creates ipm processes
#  - dependencies: new -resource motion, connect_dependings -object SYS_STORED_OBJ_CAB, new -resource rapid
#  - why here: Must be done before new -resource cab (Start of RAPID tasks and POWER_ON event etc.)
#
fileexist -path $INTERNAL/opt_l1.cmd -label LOAD_CMD
goto -label NEXT_STEP
#LOAD_CMD
include -path $INTERNAL/opt_l1.cmd
#NEXT_STEP

new -resource cab

#task -slotname spoolts -slotid 34 -pri 140 -vwopt 0x1c -stcks 3000 \
#-entp spool_main -auto

# RobAPI communication and event tasks

# Uncomment invoke below to disable tcp_nodelay for robapi on the lan interface. 
# tcp_nodelay enabled, causes packets to be flushed on to the network more frequently.
# Default is tcp_nodelay enabled on all robapi interfaces.
# For other robapi interface use strarg={"lan" | "service" | "tpu"}.
# invoke -entry robcmd_set_tcp_nodelay -arg 0 -strarg "lan" -nomode

task -slotname robdispts -slotid 58 -pri 125 -vwopt 0x1c -stcks 50000 \
-entp robdispts -auto -noreg

task -slotname robesuts -slotid 59 -pri 125 -vwopt 0x1c -stcks 18000 \
-entp robesuts -auto -noreg

task -slotname robesuts_p -slotid 85 -pri 125 -vwopt 0x1c -stcks 15000 \
-entp robesuts_p -auto -noreg

task -slotname robesuts_hp -slotid 123 -pri 125 -vwopt 0x1c -stcks 15000 \
-entp robesuts_hp -auto -noreg

task -slotname robcmdts -slotid 60 -pri 125 -vwopt 0x1c -stcks 23000 \
-entp robcmdts -auto -noreg

task -slotname robayats -slotid 61 -pri 125 -vwopt 0x1c -stcks 7000 \
-entp robayats -auto -noreg

task -slotname robrspts -slotid 57 -pri 124 -vwopt 0x1c -stcks 15000 \
-entp robrspts -auto -noreg

task -slotname robmasts -slotid 13 -pri 126 -vwopt 0x1c -stcks 48000 \
-entp robmasts -auto -noreg

task -slotname dipcts -slotid 122 -pri 126 -vwopt 0x1c -stcks 18000 \
-entp dipcts -auto -noreg

# Start stream support 
task -slotname streamts -slotid 81 -pri 120 -vwopt 0x1c -stcks 10000 \
-entp streamts -auto

# Start the stream read threads
task -slotname stream_readts1 -slotid 104 -entp stream_readts -pri 120 -vwopt 0x1c -stcks 8000 -auto
task -slotname stream_readts2 -slotid 105 -entp stream_readts -pri 120 -vwopt 0x1c -stcks 8000 -auto

# Check if T10 shall be enabled or not
fileexist -path $HOME/enable_t10 -label USE_T10
goto -label NEXT_STEP
#USE_T10

# Start KVC Server task (T10 jogging)
# Priority below RobAPI (robcmdts) is used
task -slotname kvcserverts -pri 126 -vwopt 0x1c -stcks 25000 \
-entp kvcserverts -auto -noreg

#NEXT_STEP

###########################################		
# opt_l2.cmd - Option startup Sequence no 4
# Example of:
#  - users: Cap, Dap, Vision
#  - purpose: Start of option tasks, invoke init/start methods 
#  - dependencies: new -resource cab, creation of RobAPI/stream task
#  - why here: Must be done before the last synchronize/start of tasks
#
fileexist -path $INTERNAL/opt_l2.cmd -label LOAD_CMD
goto -label NEXT_STEP
#LOAD_CMD
include -path $INTERNAL/opt_l2.cmd
#NEXT_STEP

task -slotname ns_send -slotid 78 -entp robnetscansendts -pri 98 -vwopt 0x1c \
-stcks 35000 -auto -noreg

ifvc -label NETSCANSKIP
task -slotname ns_receive -slotid 87 -entp robnetscanreceivets -pri 99 -vwopt 0x1c \
-stcks 10000 -auto -noreg
#NETSCANSKIP

synchronize -level task
rapid_startup_ready
cab_startup_ready
go -level task

### Notify CHANREF data is valid for PSC operation
invoke -entry pscio_chanref_valid -noarg -nomode

ifvc -label VTSPEED
goto -label VTSPEED_END
#VTSPEED
# Set Virtual Time Speed to 100% for VC at end of startup-script
invoke -entry VTSetSpeed -arg 100 -nomode

#VTSPEED_END

ifvc -label VCSHELL
if_os -type LINUX -label VCSHELL
goto -label VCSHELL_END
#VCSHELL
task -slotname vcshell -entp vcshell -pri 120 -vwopt 0x1c -stcks 50000 -auto -noreg -nosync
#VCSHELL_END

###########################################		
# opt_l3.cmd - Option startup Sequence no 5
# Example of:
#  - users: Paint
#  - purpose: Set of enable signal, sysdmp_add 
#  - dependencies: rapid_startup_ready/cab_startup_ready
#  - why here: No need to synch/start any option task
#
fileexist -path $INTERNAL/opt_l3.cmd -label LOAD_CMD
goto -label NEXT_STEP
#LOAD_CMD
include -path $INTERNAL/opt_l3.cmd
#NEXT_STEP

### Reset firmware upgrade error monitoring. No device upgrade methods may be invoked after this point.
upgrade_warm_start_completed

# Notify user if this is an unofficial RobotWare release in a customer system
unofficial_rw_notification

sysdmp_add -show alarm_show_failed
# Add IPC to the sysdump
sysdmp_add -show ipc_show
# Add elog to the sysdump (dumps elog messages to a text file)
sysdmp_add -class elog
# Add semaphore info to the sysdump
sysdmp_add -show sysdmp_sem_show
# Add devices info to system dump service
sysdmp_add -show devices_show
# Add ipm to the sysdump
sysdmp_add -show ipm_show_data
# Add pgm info to system dump service
sysdmp_add -show rapid_show_pgm
# Add pgmrun info to system dump service
sysdmp_add -show rapid_show_pgmrun
# Add pgmexe info to system dump service
sysdmp_add -show rapid_show_pgmexe_all
# Add operator mode info to system dump service
sysdmp_add -show operator_mode_show
# Add master control info to system dump service
sysdmp_add -show master_control_show
# Add robdisp info to system dump service
sysdmp_add -show robdisp_show
# Add bspNetDump info to system dump service
sysdmp_add -show bspNetDump
# Add mchw_show info to system dump service
sysdmp_add -show mchw_show
if_os -type LINUX -label NEXT_STEP
#NEXT_STEP
# Add FlexPendant dump info to system dump service
sysdmp_add -source fpcmd -save fpcmd_diagnostics
# Add EIO to system dump service
sysdmp_add -source eio_sysdmp -save eio_sysdmp
# Add Bulletin Board info to system dump service
sysdmp_add -show BulletinBoard_show

if_os -type LINUX -label SHELL_SCRIPT_TASK
goto -label NEXT_STEP
#SHELL_SCRIPT_TASK
task -slotname sysdmp_shell_script -slotid 18 -entp sysdmp_shell_script -pri 250 -vwopt 0x1c -stcks 25000 -auto
synchronize -level task
go -level task
sysdmp_add -class sysdmp_shell_script
#NEXT_STEP

# Generate sysdump on "refma underrun"
sysdmp_trigger_add -elog_domain 5 -elog_number 226
# Generate sysdump on "Communication lost with Drive Module"
sysdmp_trigger_add -elog_domain 3 -elog_number 9520
# Generate sysdump on "Overrun of Receive Feedback task"
sysdmp_trigger_add -elog_internal "Overrun of Receive Feedback task"
# Generate sysdump on "refma command queue timeout"
sysdmp_trigger_add -elog_domain 5 -elog_number 235
# Generate sysdump on "axc underrun of references"
sysdmp_trigger_add -elog_domain 5 -elog_number 430
# Generate sysdump on "servo underrun"
sysdmp_trigger_add -elog_domain 5 -elog_number 82

# Additional log files to be copied to the sysdump
sysdmp_add_logfile -move 0 -file "$INTERNAL/upgrade.log"
sysdmp_add_logfile -move 0 -file "$INTERNAL/install.log"
sysdmp_add_logfile -move 0 -file "$INTERNAL/startup.log"
sysdmp_add_logfile -move 0 -file "$INTERNAL/pf_info.log"
sysdmp_add_logfile -move 1 -file "$INTERNAL/tt.log"

# Include command file for additional logging mechanisms 
include -path $RELEASE/system/uprobe_default_start.cmd
fileexist -path $SYSTEM/service_debug.cmd -label LOAD_CMD
goto -label NEXT_STEP
#LOAD_CMD
include -path $SYSTEM/service_debug.cmd
sysdmp_add_logfile -move 0 -file "$SYSTEM/service_debug.cmd"
#NEXT_STEP

ifvc -label NEXT_STEP
# Report if system.xml has been restored
fileexist -path $INTERNAL/system.xml.err -label REPORT_SYS_XML
goto -label NEXT_STEP
#REPORT_SYS_XML
delete -path $INTERNAL/system.xml.err
print -text "*** RESTORE OF SYSTEM.XML HAS BEEN DONE ***"
#NEXT_STEP

systemrun
