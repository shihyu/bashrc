#export PS1='\[\e[36;1m\][\[\e[33;1m\]\u\[\e[35;1m\]@\[\e[32;1m\]\H \[\e[31;1m\]\w\[\e[36;1m\]]\[\e[34;1m\]\$ \[\e[37;1m\]' 
export PS1='\[\e[36;1m\][\[\e[33;1m\]姚\[\e[35;1m\]@\[\e[32;1m\]\H \[\e[31;1m\]\w\[\e[36;1m\]]\[\e[34;1m\]\$ \[\e[37;1m\]' 
#export PS1="\[$(tput bold)$(tput setb 4)$(tput setaf 7)\]\u@\h:\w $ \[$(tput sgr0)\]"


export LC_ALL=zh_TW.UTF-8 
export LANG=zh_TW.UTF-8 
export TERM=xterm 
umask 022 

alias sr='shutdown -r now' 
alias sd='shutdown -h now' 
alias ls='ls --color=always' 
alias ll='ls -l --block-size=M' 
alias less='less -r' 
alias rm='rm -f' 
alias h='history' 
alias hc='history -c' 
alias mnt='mount' 
alias umnt='umount' 
alias sx='startx' 
alias lt='logout' 
alias df='df -B G'
alias cl='clear'
alias vi='vim'
alias indent='indent -bad -bap -saf -sai -saw -npro -npcs -npsl -cli8 -i8 -ts8 -sob -l80 -ss -bl -bls -bli 0'
alias gcc='gcc -Wall -g -pedantic'
#alias indent='indent -npro -nip -nlp -npsl -i4 -ts4 -sob -l200 -ss -bl -bli 0 -l80'
alias style='astyle --A2 --delete-empty-lines -s4 -K -f -p -H -U -c -n -l -N -L -Y -M -j -k1 -z2'

#HTC
#alias pull='adb pull /storage/sdcard0/htclog'
alias pull='adb pull /data/htclog'
alias tombstones='adb pull /data/tombstones'
alias dlx_envsetup='source build/envsetup.sh; choosecombo 1 dlx eng; export ANDROID_SOURCE=$(gettop)'
#alias m7dug_envsetup='source build/envsetup.sh; choosecombo 1 m7dug eng'
alias m7cdug_envsetup='source build/envsetup.sh; choosecombo 1 m7cdug userdebug DEBUG'
alias dlxp_envsetup='source build/envsetup.sh ; choosecombo 1 dlpdtu userdebug DEBUG'
alias img_zip='zip rom.zip -j android-info.txt *.img *.hdr'
alias logcat='adb logcat -c && adb logcat -v threadtime 2>&1 | tee /tmp/logcat.txt'
#alias rm_log='adb shell rm /data/htclog/*'

rm_log() 
{
    adb shell rm /data/htclog/*
    adb shell rm /data/tombstones/tomb*
}

#function dlx_envsetup()
#{ 
    #unset GREP_OPTIONS
 #   source build/envsetup.sh; choosecombo 1 dlx eng
    #export GREP_OPTIONS
#}

#export GREP_OPTIONS='--color=auto --binary-files=without-match --ignore-case'

alias ..="cd .."
alias ..2="cd ../.."
alias ..3="cd ../../.."
alias ..4="cd ../../../.."
alias ..5="cd ../../../../.."

alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
shopt -s cdspell

#alias gaia_zip="adb reboot-bootloader; flash_zip; fastboot reboot"

export HISTTIMEFORMAT='%F %T'
alias h1='history 10'
alias h2='history 20'
alias h3='history 30'

logsort()
{
    ls -lrt `find . -name "$1"` | awk '{print $NF}'
}

gaia_logparse()
{
    ack -w 'Exception|ANR|E\/|SIGSEGV|FATAL|EXCEPTION\:|W\/mutexwatch' $1 >  /tmp/aa ; vim /tmp/aa
}


get_maps()
{
    PID=`adb shell ps | grep $1 | awk '{print $2}'`
    adb shell cat /proc/$PID/maps > ~/maps
    sh /home/shihyu/gen_add_symbol_file.sh /home/shihyu/maps
}

attach_pid()
{
    PID=`adb shell ps | grep $1 | awk '{print $2}'`
    adb shell gdbserver :5039 --attach $PID
} 

tar_bz2_dir()
{ # ©2007 dsplabs.com.au
    if [ "$1" != "" ]; then
        FOLDER_IN=`echo $1 |sed -e 's/\/$//'`;
        FILE_OUT="$FOLDER_IN.tar.bz2";
        FOLDER_IN="$FOLDER_IN/";
        echo "Compressing $FOLDER_IN into $FILE_OUT…";
        echo "tar cjf $FILE_OUT $FOLDER_IN";
        if [ -z "`apt-cache show pbzip2 2> /dev/null`" -o -z "pbzip2" ] ;
        then
            tar cjf "$FILE_OUT" "$FOLDER_IN";
        else
            time tar -c "$FOLDER_IN" | pbzip2 -cv -m5000 > "$FILE_OUT";
        fi
        echo "Done.";
    fi
}


d_bz2_dir()
{ 

    if [ "$1" != "" ]; then
        time pbzip2 -dvc -m5000 $1 | tar x     
    fi
}

function gdbgaia()
{
    local SUDO="sudo env PATH=$PATH"
    local PS3="Choose the operating device:"
    local ADB="adb"
    local devices=($(${ADB} devices | awk '{if(FNR>1)print $1}'))
    local s=

    echo "${devices[@]}" | grep -q "\<$4\>" 2> /dev/null && devices=("$4")

    if [ ${#devices[@]} -eq 0 ]; then
        echo No devices
        return 2;
    elif [ ${#devices[@]} -gt 1 -a "$1" != "-a" ]; then
        select s in "${devices[@]}" "quit";
        do
            if [ -n "${s}" ]; then
                case "${s}" in 
                "All devices")
                    break;
                    ;;
                "quit")
                    echo Quit!
                    return 1;
                    ;;
                *)
                    devices=(${s})
                    break;
                    ;;
                esac
            fi
        done
    fi

    local OUT_ROOT=$(get_abs_build_var PRODUCT_OUT)
    local OUT_SYMBOLS=$(get_abs_build_var TARGET_OUT_UNSTRIPPED)
    local OUT_SO_SYMBOLS=$(get_abs_build_var TARGET_OUT_SHARED_LIBRARIES_UNSTRIPPED)
    local OUT_EXE_SYMBOLS=$(get_abs_build_var TARGET_OUT_EXECUTABLES_UNSTRIPPED)
    local PREBUILTS=$(get_abs_build_var ANDROID_PREBUILTS)
    local ARCH=$(get_build_var TARGET_ARCH)
    local GDB
    case "$ARCH" in
        x86) GDB=i686-android-linux-gdb;;
        arm) GDB=arm-linux-androideabi-gdb;;
        *) echo "Unknown arch $ARCH"; return 1;;
    esac

    if [ "$OUT_ROOT" -a "$PREBUILTS" ]; then
        local EXE="$1"
        if [ "$EXE" ] ; then
            EXE=$1
        else
            EXE="app_process"
        fi

        local PORT="$2"
        if [ "$PORT" ] ; then
            PORT=$2
        else
            PORT=":5039"
        fi

        local PID
        local PROG="$3"
        if [ "$PROG" ] ; then
            if [[ "$PROG" =~ ^[0-9]+$ ]] ; then
                PID="$3"
            else
                PID=`pid $3 ${devices[0]}`
            fi
            if [ -n "${devices[0]}" ]; then
                adb -s ${devices[0]} forward "tcp$PORT" "tcp$PORT"
                adb -s ${devices[0]} shell gdbserver $PORT --attach $PID &
            else
                adb forward "tcp$PORT" "tcp$PORT"
                adb shell gdbserver $PORT --attach $PID &
            fi
            sleep 2
        else
                echo ""
                echo "If you haven't done so already, do this first on the device:"
                echo "    gdbserver $PORT /system/bin/$EXE"
                    echo " or"
                echo "    gdbserver $PORT --attach $PID"
                echo ""
        fi

        echo >|"$OUT_ROOT/gdbclient.cmds" "set solib-absolute-prefix $OUT_SYMBOLS"
        echo >>"$OUT_ROOT/gdbclient.cmds" "set solib-search-path $OUT_SO_SYMBOLS:$OUT_SO_SYMBOLS/hw:$OUT_SO_SYMBOLS/ssl/engines"
        echo >>"$OUT_ROOT/gdbclient.cmds" "set watchdog 200000000"
        echo >>"$OUT_ROOT/gdbclient.cmds" "target remote $PORT"
        echo >>"$OUT_ROOT/gdbclient.cmds" ""

        $ANDROID_TOOLCHAIN/$GDB -x "$ANDROID_SOURCE/Mygdbinit" -x "$OUT_ROOT/gdbclient.cmds" "$OUT_EXE_SYMBOLS/$EXE"
        #$ANDROID_TOOLCHAIN/$GDB -x "$ANDROID_SOURCE/Mygdbinit"  "$OUT_EXE_SYMBOLS/$EXE"
    else
        echo "Unable to determine build system output dir."
    fi
}

function mkdircd () { mkdir -p "$@" && eval cd "\"\$$#\""; }

push_so()
{
    adb shell rm /data/log/* ;
    adb shell rm /data/memleak/* ;
    adb shell rm /data/tombstones/tomb* ;
    adb remount ;
    adb push $1 /system/lib ;
    adb reboot
}

gaia_lib() 
{
    time make $1 ONLYSDKAP=true -j8 2>&1 |tee build.log
}

gaia_mm()
{
    time mm ONLYSDKAP=true -j8 2>&1 |tee build.log
}

gaia_sync() 
{
    #adb shell rm /data/log/* &&
    rm_log &&
    adb remount &&
    adb sync &&
    adb reboot
}

push_apk()
{
    adb shell rm /data/log/* ;
    adb remount ;
    adb push $1 /system/app ;
    adb reboot
}

tar_bz2_dir()
{ # ©2007 dsplabs.com.au
    if [ "$1" != "" ]; then
        FOLDER_IN=`echo $1 |sed -e 's/\/$//'`;
        FILE_OUT="$FOLDER_IN.tar.bz2";
        FOLDER_IN="$FOLDER_IN/";
        echo "Compressing $FOLDER_IN into $FILE_OUT…";
        echo "tar cjf $FILE_OUT $FOLDER_IN";
        if [ -z "`apt-cache show pbzip2 2> /dev/null`" -o -z "pbzip2" ] ;
        then
            tar cjf "$FILE_OUT" "$FOLDER_IN";
        else
            time tar -c "$FOLDER_IN" | pbzip2 -c > "$FILE_OUT";
        fi
        echo "Done.";
    fi
}

attach_pid()
{
    PID=`adb shell ps | grep $1 | awk '{print $2}'`
    adb shell gdbserver :5039 --attach $PID
}

get_maps()
{
    PID=`adb shell ps | grep $1 | awk '{print $2}'`
    adb shell cat /proc/$PID/maps > ~/maps
    sh /home/shihyu/gen_add_symbol_file.sh /home/shihyu/maps
}

d_bz2_dir()
{
    if [ "$1" != "" ]; then
        time pbzip2 -dvc -m5000 $1 | tar x     
    fi
}

scopy() 
{
    scp $1 shihyu@$2:~/upload
}

gaia_zip()
{
    adb reboot-bootloader 

    flash_zip 

    while [ $? = 1 ]; do
        sleep 3
        flash_zip 
    done

    fastboot reboot
}

gaia_rom() 
{
    adb reboot-bootloader 
    #if [ "`zip -sf $1 | grep qsc_radio.img`" != "" ]; then
        #zip $1 -d qsc_radio.img
    #fi
    echo "partial rom start"
    fastboot flash zip $1
    while [ $? = 1 ]; do
        sleep 3
        fastboot flash zip $1
    done
    echo "partial rom end"
    fastboot reboot-bootloader
    echo "COS rom start"
    fastboot flash zip $2
    while [ $? = 1 ]; do
        sleep 3
        fastboot flash zip $2
    done
    echo "COS rom end"
    fastboot reboot
}

gaia_logparse()
{
   ack -w 'Exception|ANR|E\/|SIGSEGV|FATAL|EXCEPTION\:|W\/mutexwatch|die' $1 >  /tmp/aa ; vim /tmp/aa 
}

CD() 
{
    cd `dirname "$1"` 
}

logack()
{
    ls -rt | find . -name "$1" | xargs ack -Q "$2" 
}

# colorful man page
export PAGER="`which less` -s"
export BROWSER="$PAGER"
export LESS_TERMCAP_mb=$'\E[38;5;167m'
export LESS_TERMCAP_md=$'\E[38;5;39m'
export LESS_TERMCAP_me=$'\E[38;5;231m'
export LESS_TERMCAP_se=$'\E[38;5;231m'
export LESS_TERMCAP_so=$'\E[38;5;167m'
export LESS_Td
RMCAP_ue=$'\E[38;5;231m'
export LESS_TERMCAP_us=$'\E[38;5;167m'
#export ANDROID_SOURCE=$(gettop)


# 一鍵編譯, 完成後在當前目錄下生成build文件夾
stc-cc() {
CUR_PATH=`pwd`
    if [ ! -d $CUR_PATH/build ]; then
        mkdir $CUR_PATH/build
    fi

    cd $CUR_PATH/build
    sdcc -mmcs51 $CUR_PATH/$1
}

# 一鍵編譯&&燒寫
stc-cisp() {
CUR_PATH=`pwd`
# 首先在當前目錄下生成build目錄
    if [ ! -d $CUR_PATH/build ]; then
        mkdir $CUR_PATH/build
    fi

# 編譯
    sourceFile=$CUR_PATH/build/$1
    cd $CUR_PATH/build
    sdcc -mmcs51 $CUR_PATH/$1
    cd $CUR_PATH
    ./stcisp -f ${sourceFile%.*}.ihx
}

CD()
{
    if [ -f "$1" ]; then
        cd `dirname "$1"`
    else
        cd $1
    fi
}

export ANDROID_SWT="/home/shihyu/myandroid/prebuilt/linux-x86_64/swt"

[[ -s /etc/profile.d/autojump.sh ]] && . /etc/profile.d/autojump.sh

export PATH=~/bin:$PATH
eval "$(fasd --init auto)"


export  PATH=$PATH:/opt/FriendlyARM/toolschain/4.4.3/bin 

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"


PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/opencv/lib/pkgconfig
export PKG_CONFIG_PATH

export PYTHONPATH=$PYTHONPATH:/usr/local/opencv/lib/python2.7/dist-packages

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
PATH=$PATH:$HOME/Qt5.1.1/5.1.1/gcc_64/bin/
PATH=$PATH:/home/shihyu/adt-bundle-linux-x86_64-20130917/sdk/platform-tools/
