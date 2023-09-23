[ -z $MODPATH ] && MODPATH=${0%/*}

# function
copy_dir_file() {
  mkdir -p `dirname "$2"`
  cp -af "$1" "$2"
}

# audio file
AUD="*audio*effects*.conf -o -name *audio*effects*.xml -o -name *policy*.conf -o -name *policy*.xml"
rm -f `find $MODPATH -type f -name $AUD`
FILES=`find /system /odm /my_product -type f -name $AUD`
for FILE in $FILES; do
  MODFILE=$MODPATH/system`echo "$FILE" | sed 's|/system||g'`
  copy_dir_file $FILE $MODFILE
done
FILES=`find /vendor -type f -name $AUD`
for FILE in $FILES; do
  if [ -L $MODPATH/system/vendor ]\
  && [ -d $MODPATH/vendor ]; then
    MODFILE=$MODPATH$FILE
  else
    MODFILE=$MODPATH/system$FILE
  fi
  copy_dir_file $FILE $MODFILE
done
rm -f `find $MODPATH -type f -name *policy*volume*.xml -o -name *audio*effects*spatializer*.xml`









