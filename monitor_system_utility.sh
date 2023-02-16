#!/usr/bin/env bash

Help() {
    echo -e "\nUsage: $0 [monitor_utility [POSIX or GNU style options] -p or --proc ..." >&2
    echo
    echo "   POSIX options:       GNU long options:      Description: "
    echo "   -p[file_name|dir]    --proc[=file_name|dir]        Get content of file from /proc/[file_name] "
    echo "   -c                   --cpu                         Get CPU information    "
    echo "   -m[total|used|free]  --memory[=total|used|free]    Get information about memory   "
    echo "   -d                   --disks                       Get disks information  "
    echo "   -n[interface|stat]   --network[=interface|stat]    Get network information    "
    echo "   -la                  --loadaverage                 Get information about load on the system   "
    echo "   -k[PID]              --kill[=PID]                  Kill process   "
    echo "   -o[out_file_name]    --output[=out_file_name]      Save output to file. Example: /path/to/output/file.txt  "
    echo "   -h                   --help                        Get helper "
    echo

    exit 1
}

proc_func() {
    #check if arg is empty or contain wrong symbols
    erflag=`echo "$1" | grep -v "^[a-zA-Z0-9/ ]*$"`;
    if [[ -z "$1" || -n "$erflag" ]]; then 
	echo -e "\nEmpty argument or wrong symbols in path  (Allowed symbols: [a-zA-Z0-9/ ])\n";
	exit 1; 
    fi;
  
    #check type of object (folder or file) and list or error
    if [ -f "/proc/$1" ]; then
       cat "/proc/$1"; 
    elif [ -d "/proc/$1" ]; then
       ls -la "/proc/$1";
    else 
       echo -e "\n\"$1\" - No such file in directory /proc/[dir or filename]\n";
       exit 2;
    fi;
}

cpu_func() {
    #check if package exists
    packflag=`dpkg-query -l sysstat  2> /dev/null`

    if [ -z "$packflag"  ]; then 
        echo -e "\nCommand 'mpstat' not found, but can be installed with:\n" \
                "\n apt install sysstat\n" \
                "Please ask your administrator.\n"
        return 1;
    else
      #5 snapshots per 1 second
      mpstat 1 5;
    fi;
}
memory_func() {
    case "$1" in
        total) echo -e "\nTotal memory: "; free -m | grep -i mem |awk {'print $2'};;
        used) echo -e "\nUsed memory: "; free -m | grep -i mem |awk {'print $3'};;
        free) echo -e "\nFree  memory: "; free -m | grep -i mem |awk {'print $4'};;
        *) free -m;;
    esac
}
network_func() {
    #check if arg is empty
    if [ -z "$1" ]; then 
       needs_arg "interface|stat" "interface"
    fi;

    #check if package exists
    packflag=`dpkg-query -l ifstat  2> /dev/null`    
    if [[ "$1" = "stat" || "$1" = "all" ]]; then
        if [ -z "$packflag"  ]; then
            echo -e "\nCommand 'ifstat' not found, but can be installed with:\n" \
                    "\n apt install ifstat\n" \
                    "Please ask your administrator.\n";
            return 1;
        else
            if [ "$2" != "check" ]; then ifstat -a 1 5; fi;
        fi;
    elif [ "$1" = "interface" ]; then
       ip a;
    else 
       echo -e "\nWrong unput arguments, please use syntax -n[interface|stat] --network[=interface|stat]\n";
       return 2;
    fi;
}
disk_func() {
    echo -e "\n====Output from lsblk";
    lsblk;

    echo -e "\n====Output from iostat -dx";
    
    #check if package exists
    packflag=`dpkg-query -l sysstat  2> /dev/null`

    if [ -z "$packflag"  ]; then
        echo -e "\nCommand 'iostat' not found, but can be installed with:\n" \
                "\n apt install sysstat\n" \
                "Please ask your administrator.\n";
        return 1;

    else
      #5 snapshots per 1 second
      iostat -dx;
    fi;
}
load_func() {
    #i'm using cycle here just for educational purposes
    for (( c=1; c<=5; c++ ))
    do 
        echo -e "\n $c - run /proc/loadavg"
        cat /proc/loadavg;
        sleep 1s;
    done
}
kill_func() {
    #check if arg is empty or contain wrong symbols
    erflag=`echo "$1" | grep -v "^[0-9]*$"`;
    if [[ -z "$1" || -n "$erflag" ]]; then
        echo -e "\nEmpty argument or wrong PID  (Allowed symbols: [0-9])\n";
        exit 1;
    fi;

    if ps -p $1 > /dev/null; then
        kill -9 $1;
    else 
        echo "Proccess with PID $1 doesn't exist";
    fi;
}
output_func() {
    #check path for log file
    DIR="$(dirname $1)"
    if [ ! -d "$DIR" ]; then echo "Directory $DIR DOES NOT exists."; exit 2; fi;

    #predefine  block variables
    cpu="false";
    memory="false";
    network="false";
    disks="false";
    loadaverage="false";
    all="false"; 

    case "$2" in
      c | cpu) cpu="true";;
      m | memory)  memory="true";;
      n | network) network="true";;
      d | disks) disks="true";;
      la | loadaverage) loadaverage="true";;
      *) all="true";;
    esac

    #header of outputs
    echo -e "=======System information ($(date +%F_%T)) =======" > $1;
   
    #cpu 
    if [[ "$cpu" = "true" || "$all" = "true" ]]; then
       
        out_str="\n======= Output information about CPU =======";

        cpu_func_result=`cpu_func >> /dev/null;echo $?`;
        if [ "$cpu_func_result" != "1" ]; then 
            echo -e "$out_str" >> $1;
            cpu_func >> $1;
        fi;
    fi;
    #mem
    if [[ "$memory" = "true" || "$all" = "true" ]]; then
        echo -e "\n======= Output information about Memory =======" >> $1;       
        memory_func "$3" >> $1;
    fi;
    #network
    if [[ "$network" = "true" || "$all" = "true" ]]; then

        out_str="\n======= Output information about Network =======";
        
        z=`[ -z "$3" ] && echo "all" || echo "$3"`;
        network_func_result=`network_func "$z" "check" >> /dev/null;echo $?`;
        if [[ "$network_func_result" != "1" && "$network_func_result" != "2" ]]; then
            echo -e "$out_str" >> $1;
            network_func "$z" >> $1;
        fi;
    fi;
    #disks 
    if [[ "$disks" = "true" || "$all" = "true" ]]; then
       
        out_str="\n======= Output information about Disks =======";

        disk_func_result=`disk_func >> /dev/null;echo $?`;
        if [ "$disk_func_result" != "1" ]; then 
            echo -e "$out_str" >> $1;
            disk_func >> $1;
        fi;
    fi;
    #loadaverage
    if [[ "$loadaverage" = "true" || "$all" = "true" ]]; then
        echo -e "\n======= Output information about Load os system =======" >> $1;       
        load_func >> $1;
    fi;
}

# default exit (STDERROR)
die() { echo -e "$*" >&2; exit 2; }

# check input arguments and show error
needs_arg() {
   # skip exception for memory
   if [[ "$OPT" != "memory" && "$OPT" != "m" ]]; then
        if [ -z "$OPTARG" ]; then
            if [ ${#OPT} -gt 2 ]; then
                die "\nWrong or empty arg for --$OPT option. Please set value according to syntax (--$OPT=[$1]). (Example: --$OPT=$2)\n";
            elif [[ ${#OPT} -gt 0 && ${#OPT} -lt 3 ]]; then
                die "\nWrong or empty arg for -$OPT option. Please set value according to syntax (-$OPT [$1]). (Example: -$OPT $2)\n";
            fi;
        fi;
   fi;
}

#check if input list of params then exit
if [ "$#" = 0 ]; then  echo "No args for utility"; Help; fi;

#routing of input params
firstOPT="";
firstOPTARG="";

while getopts :o:p:n:k:m:lchd-: OPT; do

    if [ "$OPT" = "-" ]; then   # long option: reformulate OPT and OPTARG
    OPT="${OPTARG%%=*}"       # extract long option name
    OPTARG="${OPTARG#$OPT}"   # extract long option argument (may be empty)
    OPTARG="${OPTARG#=}"      # if long option argument, remove assigning `=`
    elif [ "$OPT" = ":" ]; then  
        OPT="$OPTARG";
        OPTARG="";
    elif [[ "$OPT" = "l" && "$1" = "-la" ]]; then
        OPT="la" 
    fi; 

    firstOPT=$OPT;
    firstOPTARG=$OPTARG;

    #parse log flags
    logfilename=`[[ "$2" = "-o" ]] && echo "$3" || echo "$2" | cut -d '=' -f 2`;
    logenableflag=`[[ "$2" = "-o" ]] && echo "$2" || echo "$2" | cut -d '=' -f 1`;
    logfilenameforshort=`echo "$3" | cut -d '=' -f 2`;
    logenableflagforshort=`echo "$3" | cut -d '=' -f 1`;

    if [[ "$OPT" != "o" || "$OPT" != "output" ]]; then
        if [[ "$logenableflag" = "-o" || "$logenableflag" = "--output" ]]; then
            if [[ -n "$logfilename" && "$OPT" != "network" ]]; then output_func "$logfilename" "$OPT" "$OPTARG"; fi;
        elif [[ "$logenableflagforshort" = "-o" || "$logenableflagforshort" = "--output" ]]; then
            if [ -n "$logfilenameforshort" ]; then output_func "$logfilenameforshort" "$OPT" "$OPTARG"; fi;
        fi;
    fi;

    case "$OPT" in
        h | help) Help; shift ;;
        p | proc) needs_arg "filename|dir" "cpuinfo" "$OPTARG"; proc_func "$OPTARG"; shift ;;
        c | cpu) cpu_func; shift ;;
        m | memory) needs_arg "total|used|free" "total" "$OPTARG"; memory_func "$OPTARG"; shift ;;
        n | network) needs_arg "interface|stat" "interface" "$OPTARG"; network_func  "$OPTARG"; shift ;;
        d | disks) disk_func; shift ;;
        la | loadaverage) load_func; break;;
        k | kill) needs_arg "PID" "1234" "$OPTARG"; kill_func "$OPTARG"; shift ;;
        o | output) needs_arg "out_file_name" "/path.to.file.out" "$OPTARG"; output_func "$OPTARG" "all"; shift ;;
        ??*) Help; die;;  # bad long option
        ?) Help; die;;  # bad short option (error reported via getopts)
    esac
done

shift $((OPTIND-1)) # remove parsed options and args from $@ list