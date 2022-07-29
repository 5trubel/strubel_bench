#!/usr/bin/bash
# Originally realeased under Apache 2.0 by n-st (Nils Steinger)
# Orignal Parts remain under that Licence.
# Modification licenced under GNU AGPLv3 by Strub3l (Kevin Gaab)
# Modification (c) 2022 Kevin Gaab
#  summarized: Added the API, Removed the Network testing since it's not yet implemented in the Backend, Removed FreeBSD support.

command_exists()
{
    command -v "$@" > /dev/null 2>&1
}

Bps_to_MiBps()
{
    awk '{ printf "%.2f MiB/s\n", $0 / 1024 / 1024 } END { if (NR == 0) { print "error" } }'
}

Bps_to_MiBps_bench()
{
    awk '{ printf "%.2f", $0 / 1024 / 1024 } END { if (NR == 0) { print "error" } }'
}


B_to_MiB()
{
    awk '{ printf "%.0f MiB\n", $0 / 1024 / 1024 } END { if (NR == 0) { print "error" } }'
}

redact_ip()
{
    case "$1" in
        *.*)
            printf '%s.xxxx\n' "$(printf '%s\n' "$1" | cut -d . -f 1-3)"
            ;;
        *:*)
            printf '%s:xxxx\n' "$(printf '%s\n' "$1" | cut -d : -f 1-3)"
            ;;
    esac
}

finish()
{
    printf '\n'
    rm -f test_$$
    exit
}
# make sure the dd test file is always deleted, even when the script is
# interrupted while dd is running
trap finish EXIT INT TERM

command_benchmark()
{
    if [ "$1" = "-q" ]
    then
        QUIET=1
        shift
    fi

    if command_exists "$1"
    then
        ( time "$gnu_dd" if=/dev/zero bs=1M count=500 2> /dev/null | \
            "$@" > /dev/null ) 2>&1
    else
        if [ "$QUIET" -ne 1 ]
        then
            unset QUIET
            printf '[command `%s` not found]\n' "$1"
        fi
        return 1
    fi
}

dd_benchmark()
{
    # returns IO speed in B/s

    # Temporarily override locale to deal with non-standard decimal separators
    # (e.g. "," instead of ".").
    # The awk script assumes bytes/second if the suffix is !~ [TGMK]B. Call me
    # if your storage system does more than terabytes per second; I'll want to
    # see that.
    LC_ALL=C "$gnu_dd" if=/dev/zero of=test_$$ bs=64k count=16k conv=fdatasync 2>&1 | \
        awk -F, '
            {
                io=$NF
            }
            END {
                if (io ~ /TB\/s/) {printf("%.0f\n", 1000*1000*1000*1000*io)}
                else if (io ~ /GB\/s/) {printf("%.0f\n", 1000*1000*1000*io)}
                else if (io ~ /MB\/s/) {printf("%.0f\n", 1000*1000*io)}
                else if (io ~ /KB\/s/) {printf("%.0f\n", 1000*io)}
                else { printf("%.0f", 1*io)}
            }'
    rm -f test_$$
}

download_benchmark()
{
    curl --max-time 10 -so /dev/null -w '%{speed_download}\n' "$@"
}

if ! command_exists curl
then
    printf '%s\n' 'This script requires curl, but it could not be found.' 1>&2
    exit 1
fi

if command_exists gdd
then
    gnu_dd='gdd'
elif command_exists dd
then
    gnu_dd='dd'
else
    printf '%s\n' 'This script requires dd, but it could not be found.' 1>&2
    exit 1
fi

if ! command_exists jq
then
    printf '%s\n' 'This script requires jq, but it could not be found.' 1>&2
    exit 1
fi

if ! "$gnu_dd" --version > /dev/null 2>&1
then
    printf '%s\n' 'It seems your system only has a non-GNU version of dd.'
    printf '%s\n' 'dd write tests disabled.'
    gnu_dd=''
fi

printf '%s\n' '-------------------------------------------------------'
printf ' Strubel Bench -- forked from https://git.io/nench.sh\n'
printf ' With API support for https://benchmarks.gaab-networks.de\n'
date -u '+ Benchmark timestamp:    %F %T UTC'
printf '%s\n' '-------------------------------------------------------'

printf '\n'

    curl -s --max-time 10 -o ioping.static https://benchmarks.gaab-networks.de/ioping.static
    chmod +x ioping.static
    ioping_cmd="./ioping.static"

# Create Token at API backend
export sbench_token=$(curl -Ss https://benchmarks.gaab-networks.de/api.php?gettoken | jq -r .token)
curl -Ss -o /dev/null -X POST -F "type=unknown" -F "token=$sbench_token" https://benchmarks.gaab-networks.de/api.php > /dev/null 2>&1

# Basic info
printf 'Processor:    '
awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//'
cpu=$(awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//') 
curl -Ss -X POST -F "cpu=$cpu" -F "token=$sbench_token" https://benchmarks.gaab-networks.de/api.php > /dev/null 2>&1
printf 'CPU cores:    '
awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo
cpucores=$(awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo) 
curl -Ss -X POST -F "cpucores=$cpucores" -F "token=$sbench_token" https://benchmarks.gaab-networks.de/api.php > /dev/null 2>&1
printf 'Frequency:    '
awk -F: ' /cpu MHz/ {freq=$2} END {print freq " MHz"}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//'
printf 'RAM:          '
free --mega | awk 'NR==2 {print $2}'
ram=$(free --mega | awk 'NR==2 {print $2}')
curl -Ss -X POST -F "ram=$ram" -F "token=$sbench_token" https://benchmarks.gaab-networks.de/api.php > /dev/null 2>&1
if [ "$(swapon -s | wc -l)" -lt 2 ]
then
    printf 'Swap:         -\n'
else
    printf 'Swap:         '
    free -h | awk '/Swap/ {printf $2}'
    printf '\n'
fi

printf 'Kernel:       '
uname -r
kernel=$(uname -r)
curl -Ss -X POST -F "kernel=$kernel" -F "token=$sbench_token" https://benchmarks.gaab-networks.de/api.php > /dev/null 2>&1

printf '\n'

freespace=$(df -k . | awk 'NR==2 {print $3}')
totalspace=$(df -k . | awk 'NR==2 {print $2}')
printf 'Disk usage:            \n'
echo "$freespace / $totalspace"
curl -Ss -X POST -F "disk_available=$totalspace" -F "token=$sbench_token" https://benchmarks.gaab-networks.de/api.php > /dev/null 2>&1

diskid=$(df -k . | awk 'NR==2 {print $1}' | rev | cut -c2- | rev | cut -c6-)
disktype=$(lsblk --nodeps --noheadings --output NAME,SIZE,ROTA --exclude 1,2,11 | sort | awk '{if ($3 == 0) {$3="SSD"} else {$3="HDD"}; printf("%-3s%8s%5s\n", $1, $2, $3)}' | grep $(df -k . | awk 'NR==2 {print $1}' | rev | cut -c2- | rev | cut -c6-) | awk '{print $3}')
echo "$diskid is $disktype"
curl -Ss -X POST -F "disk_type=$disktype" -F "token=$sbench_token" https://benchmarks.gaab-networks.de/api.php > /dev/null 2>&1

printf '\n'

# CPU tests
export TIMEFORMAT='%3R seconds'

printf 'CPU: SHA256-hashing 500 MB\n    '
sha=$(command_benchmark -q sha256sum || command_benchmark -q sha256 || printf '[no SHA256 command found]\n')
echo $sha
curl -Ss -o /dev/null -X POST -F "sha256_500=$(echo $sha | awk '{print $1;}')" -F "token=$sbench_token" https://benchmarks.gaab-networks.de/api.php > /dev/null 2>&1

printf 'CPU: bzip2-compressing 500 MB\n    '
bzip=$(command_benchmark bzip2)
echo $bzip
curl -Ss -o /dev/null -X POST -F "bzip2_500=$(echo $bzip | awk '{print $1;}')" -F "token=$sbench_token" https://benchmarks.gaab-networks.de/api.php > /dev/null 2>&1

printf 'CPU: AES-encrypting 500 MB\n    '
aes=$(command_benchmark openssl enc -e -aes-256-cbc -pass pass:12345678 | sed '/^\*\*\* WARNING : deprecated key derivation used\.$/d;/^Using -iter or -pbkdf2 would be better\.$/d')
echo $aes
curl -Ss -o /dev/null -X POST -F "aes_500=$(echo $aes | awk '{print $1;}')" -F "token=$sbench_token" https://benchmarks.gaab-networks.de/api.php > /dev/null 2>&1

printf '\n'

# ioping
printf 'ioping: seek rate\n    '
ioping=$(./ioping.static -DR -w 5 . | tail -n 1)
echo $ioping
curl -Ss -o /dev/null -X POST -F "ioping_min=$(echo $ioping | awk '{print $3;}') $(echo $ioping | awk '{print $4;}')" -F "token=$sbench_token" https://benchmarks.gaab-networks.de/api.php > /dev/null 2>&1
curl -Ss -o /dev/null -X POST -F "ioping_avg=$(echo $ioping | awk '{print $6;}') $(echo $ioping | awk '{print $7;}')" -F "token=$sbench_token" https://benchmarks.gaab-networks.de/api.php > /dev/null 2>&1
curl -Ss -o /dev/null -X POST -F "ioping_max=$(echo $ioping | awk '{print $9;}') $(echo $ioping | awk '{print $10;}')" -F "token=$sbench_token" https://benchmarks.gaab-networks.de/api.php > /dev/null 2>&1
printf 'ioping: sequential read speed\n    '
"$ioping_cmd" -DRL -w 5 . | tail -n 2 | head -n 1

printf '\n'

# dd disk test
printf 'dd: sequential write speed\n'

if [ -z "$gnu_dd" ]
then
    printf '    %s\n' '[disabled due to missing GNU dd]'
else
    io1=$( dd_benchmark )
    printf '    1st run:    %s\n' "$(printf '%d\n' "$io1" | Bps_to_MiBps)"

    io2=$( dd_benchmark )
    printf '    2nd run:    %s\n' "$(printf '%d\n' "$io2" | Bps_to_MiBps)"

    io3=$( dd_benchmark )
    printf '    3rd run:    %s\n' "$(printf '%d\n' "$io3" | Bps_to_MiBps)"

    # Calculating avg I/O (better approach with awk for non int values)
    ioavg=$( awk 'BEGIN{printf("%.0f", ('"$io1"' + '"$io2"' + '"$io3"')/3)}' )
    curl -Ss -o /dev/null -X POST -F "dd_avg=$(echo $ioavg | Bps_to_MiBps_bench)" -F "token=$sbench_token" https://benchmarks.gaab-networks.de/api.php > /dev/null 2>&1
    printf '    average:    %s\n' "$(printf '%d\n' "$ioavg" | Bps_to_MiBps)"
fi
printf '\n'

# Network speedtests Disabled for now

# ipv4=$(curl -4 -s --max-time 5 http://icanhazip.com/)
# if [ -n "$ipv4" ]
# then
#     printf 'IPv4 speedtests\n'
#     printf '    your IPv4:    %s\n' "$(redact_ip "$ipv4")"
#     printf '\n'

#     printf '    Cachefly CDN:         '
#     download_benchmark -4 http://cachefly.cachefly.net/100mb.test | \
#         Bps_to_MiBps

#     printf '    Leaseweb (NL):        '
#     download_benchmark -4 http://mirror.nl.leaseweb.net/speedtest/100mb.bin | \
#         Bps_to_MiBps

#     printf '    Softlayer DAL (US):   '
#     download_benchmark -4 http://speedtest.dal06.softlayer.com/downloads/test100.zip | \
#         Bps_to_MiBps

#     printf '    Online.net (FR):      '
#     download_benchmark -4 http://ping.online.net/100Mo.dat | \
#         Bps_to_MiBps

#     printf '    OVH BHS (CA):         '
#     download_benchmark -4 http://speedtest-bhs.as16276.ovh/files/100Mio.dat | \
#         Bps_to_MiBps

# else
#     printf 'No IPv4 connectivity detected\n'
# fi

# printf '\n'

# ipv6=$(curl -6 -s --max-time 5 http://icanhazip.com/)
# if [ -n "$ipv6" ]
# then
#     printf 'IPv6 speedtests\n'
#     printf '    your IPv6:    %s\n' "$(redact_ip "$ipv6")"
#     printf '\n'

#     printf '    Leaseweb (NL):        '
#     download_benchmark -6 http://mirror.nl.leaseweb.net/speedtest/100mb.bin | \
#         Bps_to_MiBps

#     printf '    Softlayer DAL (US):   '
#     download_benchmark -6 http://speedtest.dal06.softlayer.com/downloads/test100.zip | \
#         Bps_to_MiBps

#     printf '    Online.net (FR):      '
#     download_benchmark -6 http://ping6.online.net/100Mo.dat | \
#         Bps_to_MiBps

#     printf '    OVH BHS (CA):         '
#     download_benchmark -6 http://speedtest-bhs.as16276.ovh/files/100Mio.dat | \
#         Bps_to_MiBps

# else
#     printf 'No IPv6 connectivity detected\n'
# fi

echo ""
echo "Please enter the type of the machine, vps or dedi"
echo "If you don't use the correct one or you enter nothing it will be shown as 'unknown'"
echo "If you pipe this script into bash/zsh, it will be shown as unknown. Contact me with your token so I can change it."
read type
curl -Ss -o /dev/null -X POST -F "type=$type" -F "token=$sbench_token" https://benchmarks.gaab-networks.de/api.php > /dev/null 2>&1

echo ""
echo "Thanks for contributing!"
echo "Here is your Token, you might need it later: $sbench_token"


printf '%s\n' '-------------------------------------------------'

# delete downloaded ioping binary if script has been run straight from a pipe
# (rather than a downloaded file)
[ -t 0 ] || rm -f ioping.static

curl -Ss -o /dev/null -X POST -F "fin=yes" -F "token=$sbench_token" https://benchmarks.gaab-networks.de/api.php > /dev/null 2>&1
unset sbench_token
