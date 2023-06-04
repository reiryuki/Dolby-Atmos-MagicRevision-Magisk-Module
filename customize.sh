# space
ui_print " "

# info
MODVER=`grep_prop version $MODPATH/module.prop`
MODVERCODE=`grep_prop versionCode $MODPATH/module.prop`
ui_print " ID=$MODID"
ui_print " Version=$MODVER"
ui_print " VersionCode=$MODVERCODE"
if [ "$KSU" == true ]; then
  ui_print " KSUVersion=$KSU_VER"
  ui_print " KSUVersionCode=$KSU_VER_CODE"
  ui_print " KSUKernelVersionCode=$KSU_KERNEL_VER_CODE"
else
  ui_print " MagiskVersion=$MAGISK_VER"
  ui_print " MagiskVersionCode=$MAGISK_VER_CODE"
fi
ui_print " "

# huskydg function
get_device() {
PAR="$1"
DEV="`cat /proc/self/mountinfo | awk '{ if ( $5 == "'$PAR'" ) print $3 }' | head -1 | sed 's/:/ /g'`"
}
mount_mirror() {
SRC="$1"
DES="$2"
RAN="`head -c6 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9'`"
while [ -e /dev/$RAN ]; do
  RAN="`head -c6 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9'`"
done
mknod /dev/$RAN b `get_device "$SRC"; echo $DEV`
if mount -t ext4 -o ro /dev/$RAN "$DES"\
|| mount -t erofs -o ro /dev/$RAN "$DES"\
|| mount -t f2fs -o ro /dev/$RAN "$DES"\
|| mount -t ubifs -o ro /dev/$RAN "$DES"; then
  blockdev --setrw /dev/$RAN
  rm -f /dev/$RAN
  return 0
fi
rm -f /dev/$RAN
return 1
}
unmount_mirror() {
DIRS="$MIRROR/system_root $MIRROR/system $MIRROR/vendor
      $MIRROR/product $MIRROR/system_ext $MIRROR/odm
      $MIRROR/my_product $MIRROR"
for DIR in $DIRS; do
  umount $DIR
done
}
mount_odm_to_mirror() {
DIR=/odm
if [ -d $DIR ]; then
  ui_print "- Mount $MIRROR$DIR..."
  mkdir -p $MIRROR$DIR
  if mount_mirror $DIR $MIRROR$DIR; then
    ui_print "  $MIRROR$DIR mount success"
  else
    ui_print "  ! $MIRROR$DIR mount failed"
    rm -rf $MIRROR$DIR
    if [ -d $MIRROR/system_root$DIR ]; then
      ln -sf $MIRROR/system_root$DIR $MIRROR
    fi
  fi
  ui_print " "
fi
}
mount_my_product_to_mirror() {
DIR=/my_product
if [ -d $DIR ]; then
  ui_print "- Mount $MIRROR$DIR..."
  mkdir -p $MIRROR$DIR
  if mount_mirror $DIR $MIRROR$DIR; then
    ui_print "  $MIRROR$DIR mount success"
  else
    ui_print "  ! $MIRROR$DIR mount failed"
    rm -rf $MIRROR$DIR
    if [ -d $MIRROR/system_root$DIR ]; then
      ln -sf $MIRROR/system_root$DIR $MIRROR
    fi
  fi
  ui_print " "
fi
}
mount_partitions_to_mirror() {
unmount_mirror
# mount system
if [ "$SYSTEM_ROOT" == true ]; then
  DIR=/system_root
  ui_print "- Mount $MIRROR$DIR..."
  mkdir -p $MIRROR$DIR
  if mount_mirror / $MIRROR$DIR; then
    ui_print "  $MIRROR$DIR mount success"
    rm -rf $MIRROR/system
    ln -sf $MIRROR$DIR/system $MIRROR
  else
    ui_print "  ! $MIRROR$DIR mount failed"
    rm -rf $MIRROR$DIR
  fi
else
  DIR=/system
  ui_print "- Mount $MIRROR$DIR..."
  mkdir -p $MIRROR$DIR
  if mount_mirror $DIR $MIRROR$DIR; then
    ui_print "  $MIRROR$DIR mount success"
  else
    ui_print "  ! $MIRROR$DIR mount failed"
    rm -rf $MIRROR$DIR
  fi
fi
ui_print " "
# mount vendor
DIR=/vendor
ui_print "- Mount $MIRROR$DIR..."
mkdir -p $MIRROR$DIR
if mount_mirror $DIR $MIRROR$DIR; then
  ui_print "  $MIRROR$DIR mount success"
else
  ui_print "  ! $MIRROR$DIR mount failed"
  rm -rf $MIRROR$DIR
  ln -sf $MIRROR/system$DIR $MIRROR
fi
ui_print " "
# mount product
DIR=/product
ui_print "- Mount $MIRROR$DIR..."
mkdir -p $MIRROR$DIR
if mount_mirror $DIR $MIRROR$DIR; then
  ui_print "  $MIRROR$DIR mount success"
else
  ui_print "  ! $MIRROR$DIR mount failed"
  rm -rf $MIRROR$DIR
  ln -sf $MIRROR/system$DIR $MIRROR
fi
ui_print " "
# mount system_ext
DIR=/system_ext
ui_print "- Mount $MIRROR$DIR..."
mkdir -p $MIRROR$DIR
if mount_mirror $DIR $MIRROR$DIR; then
  ui_print "  $MIRROR$DIR mount success"
else
  ui_print "  ! $MIRROR$DIR mount failed"
  rm -rf $MIRROR$DIR
  if [ -d $MIRROR/system$DIR ]; then
    ln -sf $MIRROR/system$DIR $MIRROR
  fi
fi
ui_print " "
mount_odm_to_mirror
mount_my_product_to_mirror
}

# sdk
NUM=17
if [ "$API" -lt $NUM ]; then
  ui_print "! Unsupported SDK $API. You have to upgrade your"
  ui_print "  Android version at least SDK API $NUM to use this"
  ui_print "  module."
  abort
else
  ui_print "- SDK $API"
  ui_print " "
fi

# magisk
MAGISKPATH=`magisk --path`
if [ "$BOOTMODE" == true ]; then
  if [ "$MAGISKPATH" ]; then
    mount -o rw,remount $MAGISKPATH
    MAGISKTMP=$MAGISKPATH/.magisk
    MIRROR=$MAGISKTMP/mirror
  else
    MAGISKTMP=/mnt
    mount -o rw,remount $MAGISKTMP
    MIRROR=$MAGISKTMP/mirror
    mount_partitions_to_mirror
  fi
fi

# path
SYSTEM=`realpath $MIRROR/system`
PRODUCT=`realpath $MIRROR/product`
VENDOR=`realpath $MIRROR/vendor`
SYSTEM_EXT=`realpath $MIRROR/system_ext`
if [ "$BOOTMODE" == true ]; then
  if [ ! -d $MIRROR/odm ]; then
    mount_odm_to_mirror
  fi
  if [ ! -d $MIRROR/my_product ]; then
    mount_my_product_to_mirror
  fi
fi
ODM=`realpath $MIRROR/odm`
MY_PRODUCT=`realpath $MIRROR/my_product`

# optionals
OPTIONALS=/sdcard/optionals.prop
if [ ! -f $OPTIONALS ]; then
  touch $OPTIONALS
fi

# mount
if [ "$BOOTMODE" != true ]; then
  if [ -e /dev/block/bootdevice/by-name/vendor ]; then
    mount -o rw -t auto /dev/block/bootdevice/by-name/vendor /vendor
  else
    mount -o rw -t auto /dev/block/bootdevice/by-name/cust /vendor
  fi
  mount -o rw -t auto /dev/block/bootdevice/by-name/persist /persist
  mount -o rw -t auto /dev/block/bootdevice/by-name/metadata /metadata
fi

# sepolicy
FILE=$MODPATH/sepolicy.rule
DES=$MODPATH/sepolicy.pfsd
if [ "`grep_prop sepolicy.sh $OPTIONALS`" == 1 ]\
&& [ -f $FILE ]; then
  mv -f $FILE $DES
fi

# .aml.sh
mv -f $MODPATH/aml.sh $MODPATH/.aml.sh

# mod ui
if [ "`grep_prop mod.ui $OPTIONALS`" == 1 ]; then
  APP=Atmos
  FILE=/sdcard/$APP.apk
  DIR=`find $MODPATH/system -type d -name $APP`
  ui_print "- Using modified UI apk..."
  if [ -f $FILE ]; then
    cp -f $FILE $DIR
    chmod 0644 $DIR/$APP.apk
    ui_print "  Applied"
  else
    ui_print "  ! There is no $FILE file."
    ui_print "    Please place the apk to your internal storage first"
    ui_print "    and reflash!"
  fi
  ui_print " "
fi

# cleaning
ui_print "- Cleaning..."
PKG=`cat $MODPATH/package.txt`
if [ "$BOOTMODE" == true ]; then
  for PKGS in $PKG; do
    RES=`pm uninstall $PKGS 2>/dev/null`
  done
fi
rm -rf /metadata/magisk/$MODID
rm -rf /mnt/vendor/persist/magisk/$MODID
rm -rf /persist/magisk/$MODID
rm -rf /data/unencrypted/magisk/$MODID
rm -rf /cache/magisk/$MODID
ui_print " "

# function
conflict() {
for NAMES in $NAME; do
  DIR=/data/adb/modules_update/$NAMES
  if [ -f $DIR/uninstall.sh ]; then
    sh $DIR/uninstall.sh
  fi
  rm -rf $DIR
  DIR=/data/adb/modules/$NAMES
  rm -f $DIR/update
  touch $DIR/remove
  FILE=/data/adb/modules/$NAMES/uninstall.sh
  if [ -f $FILE ]; then
    sh $FILE
    rm -f $FILE
  fi
  rm -rf /metadata/magisk/$NAMES
  rm -rf /mnt/vendor/persist/magisk/$NAMES
  rm -rf /persist/magisk/$NAMES
  rm -rf /data/unencrypted/magisk/$NAMES
  rm -rf /cache/magisk/$NAMES
done
}

# function
cleanup() {
if [ -f $DIR/uninstall.sh ]; then
  sh $DIR/uninstall.sh
fi
DIR=/data/adb/modules_update/$MODID
if [ -f $DIR/uninstall.sh ]; then
  sh $DIR/uninstall.sh
fi
}

# cleanup
DIR=/data/adb/modules/$MODID
FILE=$DIR/module.prop
if [ "`grep_prop data.cleanup $OPTIONALS`" == 1 ]; then
  sed -i 's/^data.cleanup=1/data.cleanup=0/' $OPTIONALS
  ui_print "- Cleaning-up $MODID data..."
  cleanup
  ui_print " "
elif [ -d $DIR ] && ! grep -q "$MODNAME" $FILE; then
  ui_print "- Different version detected"
  ui_print "  Cleaning-up $MODID data..."
  cleanup
  ui_print " "
fi

# function
permissive_2() {
sed -i '1i\
SELINUX=`getenforce`\
if [ "$SELINUX" == Enforcing ]; then\
  magiskpolicy --live "permissive *"\
fi\' $MODPATH/post-fs-data.sh
}
permissive() {
SELINUX=`getenforce`
if [ "$SELINUX" == Enforcing ]; then
  setenforce 0
  SELINUX=`getenforce`
  if [ "$SELINUX" == Enforcing ]; then
    ui_print "  Your device can't be turned to Permissive state."
    ui_print "  Using Magisk Permissive mode instead."
    permissive_2
  else
    setenforce 1
    sed -i '1i\
SELINUX=`getenforce`\
if [ "$SELINUX" == Enforcing ]; then\
  setenforce 0\
fi\' $MODPATH/post-fs-data.sh
  fi
fi
}

# permissive
if [ "`grep_prop permissive.mode $OPTIONALS`" == 1 ]; then
  ui_print "- Using device Permissive mode."
  rm -f $MODPATH/sepolicy.rule
  permissive
  ui_print " "
elif [ "`grep_prop permissive.mode $OPTIONALS`" == 2 ]; then
  ui_print "- Using Magisk Permissive mode."
  rm -f $MODPATH/sepolicy.rule
  permissive_2
  ui_print " "
fi

# function
hide_oat() {
for APPS in $APP; do
  REPLACE="$REPLACE
  `find $MODPATH/system -type d -name $APPS | sed "s|$MODPATH||"`/oat"
done
}
replace_dir() {
if [ -d $DIR ]; then
  REPLACE="$REPLACE $MODDIR"
fi
}
hide_app() {
DIR=$SYSTEM/app/$APPS
MODDIR=/system/app/$APPS
replace_dir
DIR=$SYSTEM/priv-app/$APPS
MODDIR=/system/priv-app/$APPS
replace_dir
DIR=$PRODUCT/app/$APPS
MODDIR=/system/product/app/$APPS
replace_dir
DIR=$PRODUCT/priv-app/$APPS
MODDIR=/system/product/priv-app/$APPS
replace_dir
DIR=$MY_PRODUCT/app/$APPS
MODDIR=/system/product/app/$APPS
replace_dir
DIR=$MY_PRODUCT/priv-app/$APPS
MODDIR=/system/product/priv-app/$APPS
replace_dir
DIR=$PRODUCT/preinstall/$APPS
MODDIR=/system/product/preinstall/$APPS
replace_dir
DIR=$SYSTEM_EXT/app/$APPS
MODDIR=/system/system_ext/app/$APPS
replace_dir
DIR=$SYSTEM_EXT/priv-app/$APPS
MODDIR=/system/system_ext/priv-app/$APPS
replace_dir
DIR=$VENDOR/app/$APPS
MODDIR=/system/vendor/app/$APPS
replace_dir
DIR=$VENDOR/euclid/product/app/$APPS
MODDIR=/system/vendor/euclid/product/app/$APPS
replace_dir
}

# hide
APP="`ls $MODPATH/system/priv-app` `ls $MODPATH/system/app`"
hide_oat
APP=MusicFX
for APPS in $APP; do
  hide_app
done

# stream mode
FILE=$MODPATH/.aml.sh
PROP=`grep_prop stream.mode $OPTIONALS`
if echo "$PROP" | grep -q m; then
  ui_print "- Activating music stream..."
  sed -i 's/#m//g' $FILE
  sed -i 's/musicstream=/musicstream=true/g' $MODPATH/acdb.conf
  ui_print " "
else
  APP=AudioFX
  for APPS in $APP; do
    hide_app
  done
fi
if echo "$PROP" | grep -q r; then
  ui_print "- Activating ring stream..."
  sed -i 's/#r//g' $FILE
  ui_print " "
fi
if echo "$PROP" | grep -q a; then
  ui_print "- Activating alarm stream..."
  sed -i 's/#a//g' $FILE
  ui_print " "
fi
if echo "$PROP" | grep -q s; then
  ui_print "- Activating system stream..."
  sed -i 's/#s//g' $FILE
  ui_print " "
fi
if echo "$PROP" | grep -q v; then
  ui_print "- Activating voice_call stream..."
  sed -i 's/#v//g' $FILE
  ui_print " "
fi
if echo "$PROP" | grep -q n; then
  ui_print "- Activating notification stream..."
  sed -i 's/#n//g' $FILE
  ui_print " "
fi

# directory
if [ "$API" -le 25 ]; then
  ui_print "- /vendor/lib/soundfx is not supported in SDK 25 and bellow"
  ui_print "  Using /system/lib/soundfx instead"
  mv -f $MODPATH/system/vendor/lib* $MODPATH/system
  ui_print " "
fi

# settings
FILE=$MODPATH/system/etc/dlb-default.xml
ui_print "- Disable volume leveler for all default profiles"
sed -i 's/dvle=\[1\]/dvle=\[0\]/g' $FILE
ui_print " "

# audio rotation
FILE=$MODPATH/service.sh
if [ "`grep_prop audio.rotation $OPTIONALS`" == 1 ]; then
  ui_print "- Enables ro.audio.monitorRotation=true"
  sed -i '1i\
resetprop ro.audio.monitorRotation true' $FILE
  ui_print " "
fi

# raw
FILE=$MODPATH/.aml.sh
if [ "`grep_prop disable.raw $OPTIONALS`" == 0 ]; then
  ui_print "- Not disables Ultra Low Latency playback (RAW)"
  ui_print " "
else
  sed -i 's/#u//g' $FILE
fi

# run
. $MODPATH/copy.sh
. $MODPATH/.aml.sh

# unmount
if [ "$BOOTMODE" == true ] && [ ! "$MAGISKPATH" ]; then
  unmount_mirror
fi












