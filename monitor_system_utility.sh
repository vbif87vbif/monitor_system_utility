#!/bin/bash

Help() {
    echo -e "\nUsage: $0 [monitor_utility [POSIX or GNU style options] -p or --proc ..." >&2
    echo
    echo "   POSIX options:       GNU long options:      Description: "
    echo "   -p[file_name]        --proc[=file_name]            Get content of file from /proc/[file_name] "
    echo "   -c                   --cpu                         Get CPU information    "
    echo "   -m                   --memory                      Get information about memory   "
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
    #check if arg is empty
    if [ -z "$1" ]; then exit 1; fi;

    #check if file then display content
    PROC_FILE=$(find /proc -maxdepth 1 -mindepth 1 -name "$1" -type f);

    if [ -n "$PROC_FILE" ]; then 
         cat "/proc/$1";
    else
        echo "\"$1\" - 	No such file"; 
        exit 2;
    fi;
}
cpu_func() {
    #5 snapshots per 1 second
    mpstat 1 5;
}
memory_func() {
    #i'm using cycle here just for educational purposes
    echo -e "\n $c - run free -m"
    for (( c=1; c<=5; c++ ))
    do 
        free -m;
        sleep 1s;
    done
}
network_func() {
    #check if arg is empty
    if [ -z "$1" ]; then exit 1; fi;

    case "$1" in
        interface) ifconfig -a;;
        stat) ifstat -a 1 5;;
    esac
}
disk_func() {
    echo -e "\n====Echo of lsblk";
    lsblk;
    echo -e "\n====Echo of iostat -dx";
    iostat -dx;
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
    if ps -p $1 > /dev/null; then
        kill -9 $1;
    else 
        echo "Proccess with PID $1 doesn't exist";
    fi;
}
output_func() {
    DIR="$(dirname $1)"
    if [ ! -d "$DIR" ]; then echo "Directory $DIR DOES NOT exists."; exit 2; fi;

    echo -e "\n=======System information ($(date +%F_%T)) =======" > $1;
    for func in cpu_func memory_func network_func disk_func load_func
    do
        echo -e "\n=======Output information from func=$func=======" >> $1;
        if [[ "$func" = "network_func" ]]; then
            $func "interface" >> $1;
            $func "stat" >> $1;
        else
            $func >> $1;
        fi;
    done
}

#check if pass empty is list of params
if [[ "$#" == 0 ]]; then  echo "No arg for utility"; Help; fi;
die() { echo "$*" >&2; exit 2; }  # complain to STDERR and exit with error
needs_arg() { if [ -z "$OPTARG" ]; then die "No arg for --$OPT option. Please set value according to syntax --key=value"; fi; }

while getopts o:p:n:k:lmchd-: OPT; do
  if [ "$OPT" = "-" ]; then   # long option: reformulate OPT and OPTARG
    OPT="${OPTARG%%=*}"       # extract long option name
    OPTARG="${OPTARG#$OPT}"   # extract long option argument (may be empty)
    OPTARG="${OPTARG#=}"      # if long option argument, remove assigning `=`
  fi 

  # some strange magic for -la argument
  if [[ "$1" != "-la" && ${#1} -gt 2 ]]; then die "Incorrect option"; fi;
  if [[ "$1" = "-la" ]]; then OPT="la"; fi;

  case "$OPT" in
    h | help)    Help; shift ;;
    p | proc) needs_arg; proc_func "$OPTARG"; shift ;;
    c | cpu) cpu_func; shift ;;
    m | memory) memory_func; shift ;;
    n | network) network_func  "$OPTARG"; shift ;;
    d | disks) disk_func; shift ;;
    la | loadaverage) load_func; shift ;;
    k | kill) needs_arg; kill_func "$OPTARG"; shift ;;
    o | output) needs_arg; output_func "$OPTARG"; shift ;;
    ??*) Help; die;;  # bad long option
    ?) Help; die;;  # bad short option (error reported via getopts)
  esac
done
shift $((OPTIND-1)) # remove parsed options and args from $@ list