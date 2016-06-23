
ifvc -label VC_SKIP_DN1
iomgrinstall -entry dnFBC -name /dnfbc -errlabel ERROR_DNFBC

creat -name /dnfbc/DNET_PCI1: -pmode 0 -errlabel ERROR_DNFBC

task -slotname DNread1 -entp read_ts -pri 72 -vwopt 0x1c -stcks 10000 -nosync -auto
readparam -devicename /DNET_PCI1:/bus_read -rmode 1 -buffersize 100
invoke -entry dnfbc_tk_activate -strarg "DNET1" -nomode

# Add DeviceNet to system dump service
sysdmp_add -show dnfbc_sysdmp

goto -label VC_SKIP_DN2 

#VC_SKIP_DN1

creat -name /simfbc/DNET_PCI1: -pmode 0

#VC_SKIP_DN2
#ERROR_DNFBC
#FATAL_ERROR_DNFBC
ifvc -label VC_SKIP_AB1
iomgrinstall -entry ABFBC -name /abfbc -errlabel ERROR_ABFBC

creat -name /abfbc/PBUS_FA1: -pmode 0 -errlabel ERROR_ABFBC
task -slotname ABread1 -entp read_ts -pri 72 -vwopt 0x1c -stcks 10000 -nosync -auto

readparam -devicename /PBUS_FA1:/bus_read -rmode 1 -buffersize 100

# Add Anybus to system dump service
sysdmp_add -show abfbc_sysdmp

goto -label VC_SKIP_AB2 

#VC_SKIP_AB1
creat -name /simfbc/PBUS_FA1: -pmode 0

#VC_SKIP_AB2
#ERROR_ABFBC
