[ -z $MODPATH ] && MODPATH=${0%/*}
[ -z $API ] && API=`getprop ro.build.version.sdk`

# destination
if [ "$API" -ge 26 ]; then
  LIBPATH="\/vendor\/lib\/soundfx"
else
  LIBPATH="\/system\/lib\/soundfx"
fi
MODAEC=`find $MODPATH -type f -name *audio*effects*.conf`
MODAEX=`find $MODPATH -type f -name *audio*effects*.xml`
MODAP=`find $MODPATH -type f -name *policy*.conf -o -name *policy*.xml`

# function
remove_conf() {
for RMV in $RMVS; do
  sed -i "s|$RMV|removed|g" $MODAEC
done
sed -i 's|path /vendor/lib/soundfx/removed||g' $MODAEC
sed -i 's|path /system/lib/soundfx/removed||g' $MODAEC
sed -i 's|path /vendor/lib/removed||g' $MODAEC
sed -i 's|path /system/lib/removed||g' $MODAEC
sed -i 's|path /vendor/lib64/soundfx/removed||g' $MODAEC
sed -i 's|path /system/lib64/soundfx/removed||g' $MODAEC
sed -i 's|path /vendor/lib64/removed||g' $MODAEC
sed -i 's|path /system/lib64/removed||g' $MODAEC
sed -i 's|library removed||g' $MODAEC
sed -i 's|uuid removed||g' $MODAEC
sed -i "/^        removed {/ {;N s/        removed {\n        }//}" $MODAEC
sed -i 's|removed { }||g' $MODAEC
sed -i 's|removed {}||g' $MODAEC
}
remove_xml() {
for RMV in $RMVS; do
  sed -i "s|\"$RMV\"|\"removed\"|g" $MODAEX
done
sed -i 's|<library name="removed" path="removed"/>||g' $MODAEX
sed -i 's|<library name="proxy" path="removed"/>||g' $MODAEX
sed -i 's|<effect name="removed" library="removed" uuid="removed"/>||g' $MODAEX
sed -i 's|<effect name="removed" uuid="removed" library="removed"/>||g' $MODAEX
sed -i 's|<libsw library="removed" uuid="removed"/>||g' $MODAEX
sed -i 's|<libhw library="removed" uuid="removed"/>||g' $MODAEX
sed -i 's|<apply effect="removed"/>||g' $MODAEX
sed -i 's|<library name="removed" path="removed" />||g' $MODAEX
sed -i 's|<library name="proxy" path="removed" />||g' $MODAEX
sed -i 's|<effect name="removed" library="removed" uuid="removed" />||g' $MODAEX
sed -i 's|<effect name="removed" uuid="removed" library="removed" />||g' $MODAEX
sed -i 's|<libsw library="removed" uuid="removed" />||g' $MODAEX
sed -i 's|<libhw library="removed" uuid="removed" />||g' $MODAEX
sed -i 's|<apply effect="removed" />||g' $MODAEX
}

# store
RMVS="ring_helper alarm_helper music_helper voice_helper
      notification_helper ma_ring_helper ma_alarm_helper
      ma_music_helper ma_voice_helper ma_system_helper
      ma_notification_helper sa3d fens lmfv dirac dtsaudio
      dlb_music_listener dlb_ring_listener dlb_alarm_listener
      dlb_system_listener dlb_notification_listener"

# setup audio effects conf
if [ "$MODAEC" ]; then
  for RMV in $RMVS; do
    sed -i "/^        $RMV {/ {;N s/        $RMV {\n        }//}" $MODAEC
    sed -i "s|$RMV { }||g" $MODAEC
    sed -i "s|$RMV {}||g" $MODAEC
  done
  if ! grep -q '^output_session_processing {' $MODAEC; then
    sed -i -e '$a\
\
output_session_processing {\
    music {\
    }\
    ring {\
    }\
    alarm {\
    }\
    system {\
    }\
    voice_call {\
    }\
    notification {\
    }\
    bluetooth_sco {\
    }\
    dtmf {\
    }\
    enforced_audible {\
    }\
    accessibility {\
    }\
    tts {\
    }\
    assistant {\
    }\
    call_assistant {\
    }\
    patch {\
    }\
    rerouting {\
    }\
}\' $MODAEC
  else
    if ! grep -q '^    rerouting {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    rerouting {\n    }" $MODAEC
    fi
    if ! grep -q '^    patch {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    patch {\n    }" $MODAEC
    fi
    if ! grep -q '^    call_assistant {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    call_assistant {\n    }" $MODAEC
    fi
    if ! grep -q '^    assistant {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    assistant {\n    }" $MODAEC
    fi
    if ! grep -q '^    tts {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    tts {\n    }" $MODAEC
    fi
    if ! grep -q '^    accessibility {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    accessibility {\n    }" $MODAEC
    fi
    if ! grep -q '^    enforced_audible {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    enforced_audible {\n    }" $MODAEC
    fi
    if ! grep -q '^    dtmf {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    dtmf {\n    }" $MODAEC
    fi
    if ! grep -q '^    bluetooth_sco {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    bluetooth_sco {\n    }" $MODAEC
    fi
    if ! grep -q '^    notification {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    notification {\n    }" $MODAEC
    fi
    if ! grep -q '^    voice_call {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    voice_call {\n    }" $MODAEC
    fi
    if ! grep -q '^    system {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    system {\n    }" $MODAEC
    fi
    if ! grep -q '^    alarm {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    alarm {\n    }" $MODAEC
    fi
    if ! grep -q '^    ring {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    ring {\n    }" $MODAEC
    fi
    if ! grep -q '^    music {' $MODAEC; then
      sed -i "/^output_session_processing {/a\    music {\n    }" $MODAEC
    fi
  fi
fi

# setup audio effects xml
if [ "$MODAEX" ]; then
  for RMV in $RMVS; do
    sed -i "s|<apply effect=\"$RMV\"/>||g" $MODAEX
    sed -i "s|<apply effect=\"$RMV\" />||g" $MODAEX
  done
  if ! grep -q '<postprocess>' $MODAEX\
  || grep -q '<!-- Audio post processor' $MODAEX; then
    sed -i '/<\/effects>/a\
    <postprocess>\
        <stream type="music">\
        <\/stream>\
        <stream type="ring">\
        <\/stream>\
        <stream type="alarm">\
        <\/stream>\
        <stream type="system">\
        <\/stream>\
        <stream type="voice_call">\
        <\/stream>\
        <stream type="notification">\
        <\/stream>\
        <stream type="bluetooth_sco">\
        <\/stream>\
        <stream type="dtmf">\
        <\/stream>\
        <stream type="enforced_audible">\
        <\/stream>\
        <stream type="accessibility">\
        <\/stream>\
        <stream type="tts">\
        <\/stream>\
        <stream type="assistant">\
        <\/stream>\
        <stream type="call_assistant">\
        <\/stream>\
        <stream type="patch">\
        <\/stream>\
        <stream type="rerouting">\
        <\/stream>\
    <\/postprocess>' $MODAEX
  else
    if ! grep -q '<stream type="rerouting">' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"rerouting\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -q '<stream type="patch">' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"patch\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -q '<stream type="call_assistant">' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"call_assistant\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -q '<stream type="assistant">' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"assistant\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -q '<stream type="tts">' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"tts\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -q '<stream type="accessibility">' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"accessibility\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -q '<stream type="enforced_audible">' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"enforced_audible\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -q '<stream type="dtmf">' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"dtmf\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -q '<stream type="bluetooth_sco">' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"bluetooth_sco\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -q '<stream type="notification">' $MODAEX\
    || grep -q '<!-- YunMang.Xiao@PSW.MM.Dolby' $MODAEX\
    || grep -q '<!-- WuHao@MULTIMEDIA.AUDIOSERVER.EFFECT' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"notification\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -q '<stream type="voice_call">' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"voice_call\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -q '<stream type="system">' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"system\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -q '<stream type="alarm">' $MODAEX\
    || grep -q '<!-- YunMang.Xiao@PSW.MM.Dolby' $MODAEX\
    || grep -q '<!-- WuHao@MULTIMEDIA.AUDIOSERVER.EFFECT' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"alarm\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -q '<stream type="ring">' $MODAEX\
    || grep -q '<!-- YunMang.Xiao@PSW.MM.Dolby' $MODAEX\
    || grep -q '<!-- WuHao@MULTIMEDIA.AUDIOSERVER.EFFECT' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"ring\">\n        <\/stream>" $MODAEX
    fi
    if ! grep -q '<stream type="music">' $MODAEX\
    || grep -q '<!-- YunMang.Xiao@PSW.MM.Dolby' $MODAEX\
    || grep -q '<!-- WuHao@MULTIMEDIA.AUDIOSERVER.EFFECT' $MODAEX; then
      sed -i "/<postprocess>/a\        <stream type=\"music\">\n        <\/stream>" $MODAEX
    fi
  fi
fi

# store
LIB=libdlbatmos.so
LIBNAME=dlbatmos
NAME=dlbatmos
UUID=9d4921da-8225-4f29-aefa-39537a041337
RMVS="$LIB $LIBNAME $NAME $UUID"

# patch audio effects conf
if [ "$MODAEC" ]; then
  remove_conf
  sed -i "/^libraries {/a\  $LIBNAME {\n    path $LIBPATH\/$LIB\n  }" $MODAEC
  sed -i "/^effects {/a\  $NAME {\n    library $LIBNAME\n    uuid $UUID\n  }" $MODAEC
#m  sed -i "/^    music {/a\        $NAME {\n        }" $MODAEC
#r  sed -i "/^    ring {/a\        $NAME {\n        }" $MODAEC
#a  sed -i "/^    alarm {/a\        $NAME {\n        }" $MODAEC
#s  sed -i "/^    system {/a\        $NAME {\n        }" $MODAEC
#v  sed -i "/^    voice_call {/a\        $NAME {\n        }" $MODAEC
#n  sed -i "/^    notification {/a\        $NAME {\n        }" $MODAEC
#b  sed -i "/^    bluetooth_sco {/a\        $NAME {\n        }" $MODAEC
#f  sed -i "/^    dtmf {/a\        $NAME {\n        }" $MODAEC
#e  sed -i "/^    enforced_audible {/a\        $NAME {\n        }" $MODAEC
#y  sed -i "/^    accessibility {/a\        $NAME {\n        }" $MODAEC
#t  sed -i "/^    tts {/a\        $NAME {\n        }" $MODAEC
#i  sed -i "/^    assistant {/a\        $NAME {\n        }" $MODAEC
#c  sed -i "/^    call_assistant {/a\        $NAME {\n        }" $MODAEC
#p  sed -i "/^    patch {/a\        $NAME {\n        }" $MODAEC
#g  sed -i "/^    rerouting {/a\        $NAME {\n        }" $MODAEC
fi

# patch audio effects xml
if [ "$MODAEX" ]; then
  remove_xml
  sed -i "/<libraries>/a\        <library name=\"$LIBNAME\" path=\"$LIB\"\/>" $MODAEX
  sed -i "/<effects>/a\        <effect name=\"$NAME\" library=\"$LIBNAME\" uuid=\"$UUID\"\/>" $MODAEX
#m  sed -i "/<stream type=\"music\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#r  sed -i "/<stream type=\"ring\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#a  sed -i "/<stream type=\"alarm\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#s  sed -i "/<stream type=\"system\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#v  sed -i "/<stream type=\"voice_call\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#n  sed -i "/<stream type=\"notification\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#b  sed -i "/<stream type=\"bluetooth_sco\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#f  sed -i "/<stream type=\"dtmf\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#e  sed -i "/<stream type=\"enforced_audible\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#y  sed -i "/<stream type=\"accessibility\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#t  sed -i "/<stream type=\"tts\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#i  sed -i "/<stream type=\"assistant\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#c  sed -i "/<stream type=\"call_assistant\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#p  sed -i "/<stream type=\"patch\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
#g  sed -i "/<stream type=\"rerouting\">/a\            <apply effect=\"$NAME\"\/>" $MODAEX
fi

# patch audio policy
#uif [ "$MODAP" ]; then
#u  sed -i 's|RAW|NONE|g' $MODAP
#u  sed -i 's|,raw||g' $MODAP
#ufi












