#!/bin/bash


direc=`dirname $0`
function color(){
    black='\033[0;30m'        # Black
    red='\033[0;31m'          # Red
    green='\033[0;32m'        # Green
    yellow='\033[0;33m'       # Yellow
    blue='\033[0;36m'         # Blue
    magenta='\033[0;35m'      # Magenta
    cyan='\033[0;36m'         # Cyan
    white='\033[0;37m'        # White

    close="\033[m"
    case $1 in
        blue)
          echo  "$blue $2 $close"
#            echo -e "$blue $2 $close"
        ;;
        red)
            echo   "$red $2 $close"
#            echo -e "$red $2 $close"
        ;;
        green)
            echo   "$green $2 $close"
#            echo -e "$green $2 $close"
        ;;
        *)
            echo "Input color error!!"
        ;;
    esac
}

function copyright(){
    color blue "#######################################################"
    color blue "#####################    scp file   ###################"
    color blue "#######################################################"

}

function underline(){
    echo "--------------------------------------------------------"
}
function get_ip_info() {
    pw="$direc/ip_addrs.txt"
    local field=$1
    local number=$2
    awk -v num="$number" -F: "\$1 == num {print \$${field}}" "$pw"
}
 # 定义一个函数来检查 IP 是否可达
function check_ip() {
    local ip=$1
    ping -c 3 -i 1 $ip > /dev/null 2>&1
    return $?
}
# 定义一个函数来检查并创建目录
function check_and_create_directory() {
    local dir=$1
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        color green "目录 $dir 已创建。\n"
    fi
}

function main(){
    # shellcheck disable=SC2078
    while [ True ];do

        underline
        color green "序号  |       主机    |      说明      | 目标路径  "
        underline
        awk 'BEGIN {FS=":"} {printf("\033[0;31m% 3s \033[m | %15s | %15s | %s\n",$1,$2,$6,$7)}' $direc/ip_addrs.txt
        underline
        color blue '[*] 选择主机: '
        read number

        if [[ ! "$number" =~ ^[0-9]+$  && "$number" != "q" && "$number" != "quit" ]]; then
            color red "Input error!! Please enter a valid number or 'q' to quit.\n\n"
            continue
        fi
        # read -p '[*] 选择主机: ' number
#        pw="$direc/ip_addrs.txt"
        ipaddr=$(get_ip_info 2 "$number")
        port=$(get_ip_info 3 "$number")
        username=$(get_ip_info 4 "$number")
        passwd=$(get_ip_info 5 "$number")
        targetPath=$(get_ip_info 7 "$number")
        machineType=$(get_ip_info 6 "$number")



        case $number in
            [0-9]|[0-9][0-9]|[0-9][0-9][0-9])
                echo $passwd | grep -q ".pem$"
                RETURN=$?
                if [[ $RETURN == 0 ]];then
                    echo "Input error!!\n\n"
                    # ssh -i $direc/keys/$passwd $username@$ipaddr -p $port
                    # echo "ssh -i $direc/$passwd $username@$ipaddr -p $port"
                elif [[ $ipaddr == '' ]];then
                    color red  "Input error!! The input number does not exist!!  \n\n"
                elif  ! check_ip $ipaddr;then
                    color red  "The IP address $ipaddr is not reachable!!  \n\n"
                else
                    color blue '[1] 上传包    [2]拉取日志 '
                    read number # read -p '[1] 上传包;   [2]拉取日志 ' number
                    case $number in
                        1)
                            # 提示用户输入文件路径
                            read -p "请输入文件路径: " file

                            # 检查文件是否存在且是文件
                            if [[ -f "$file" ]]; then
                                color green "文件存在: $file"
                                # 在这里添加你想要对文件进行的操作
                            else
                                color red "文件不存在或不是一个有效的文件: $file  \n\n"
                                continue
                            fi


                            # echo "$ipaddr $username $passwd $port $targetPath $file"
                            expect -f $direc/scp_script.sh $ipaddr $username $passwd $port $targetPath $file
                            ;;
                        2)
                            #本地存放日志路径
                            logPath="./linuxLog"
                            check_and_create_directory $logPath
                            #组装日志路径
                            today=$(date +%Y_%m_%d)
                            log_file=$today".log"
                            if echo $machineType  | grep 'RG'; then
                                sourceLog=/home/yh/data/yhpos/cache/log/$log_file
                            else

                                sourceLog=/home/yh/data/yh_pos_ext/cache/log/$log_file
                            fi
                            targetLogPath=$logPath"/"$today"_"$ipaddr".log"
                            
                            expect -f $direc/pull_log_script.sh $ipaddr $username $passwd $port $sourceLog $targetLogPath

                            open $logPath
                            ;;
                        *)
                            color red  "Input error: The input number does not exist!!  \n\n"
                            ;;
                    esac



                    # 检查scp命令是否成功
                    if [ $? -eq 0  ]; then
                        color green "----------------------- 文件传输成功! -----------------------"
                        echo "\n\n"
                    else
                        color red "----------------------- 文件传输失败! -----------------------"
                        echo "\n\n"
                    fi

                fi
            ;;
            "q"|"quit")
                exit
            ;;

            *)
                color red "Input error!!\n\n"
            ;;
        esac
    done
}

copyright
main

