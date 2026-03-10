### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=Custom Kernel with KernelSU for Moto G05 (lamu)
do.devicecheck=1
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=0
device.name1=lamu
device.name2=moto g05
device.name3=
device.name4=
device.name5=
supported.versions=15
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties


### AnyKernel install
## boot shell variables
block=boot
is_slot_device=auto
ramdisk_compression=auto
patch_vbmeta_flag=auto
no_magisk_check=1

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/flash-core.sh

kernel_version=$(cat /proc/version | awk -F '-' '{print $1}' | awk '{print $3}')
case $kernel_version in
    6.6*) ksu_supported=true ;;
    *) ksu_supported=false ;;
esac

ui_print " "
ui_print "Custom Kernel with KernelSU for Moto G05 (lamu)"
ui_print "Kernel version: 6.6"
ui_print "KernelSU: Supported"
ui_print " "
$ksu_supported || abort "  -> Unsupported kernel version, abort."

# boot install
split_boot
if [ -f "split_img/ramdisk.cpio" ]; then
    unpack_ramdisk
    write_boot
else
    flash_boot
fi
## end boot install
