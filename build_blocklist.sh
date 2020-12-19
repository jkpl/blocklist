#!/usr/bin/env bash
set -euo pipefail

# Based on https://v.firebog.net/hosts/lists.php?type=tick
SOURCES='
https://adaway.org/hosts.txt
https://bitbucket.org/ethanr/dns-blacklists/raw/8575c9f96e5b4a1308f2f12394abd86d0927a4a0/bad_lists/Mandiant_APT1_Report_Appendix_D.txt
https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt
https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt
https://mirror.cedia.org.ec/malwaredomains/immortal_domains.txt
https://osint.digitalside.it/Threat-Intel/lists/latestdomains.txt
https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext
https://phishing.army/download/phishing_army_blocklist_extended.txt
https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt
https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts
https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt
https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt
https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts
https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts
https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts
https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts
https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts_without_controversies.txt
https://raw.githubusercontent.com/Spam404/lists/master/main-blacklist.txt
https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt
https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt
https://urlhaus.abuse.ch/downloads/hostfile/
https://v.firebog.net/hosts/AdguardDNS.txt
https://v.firebog.net/hosts/Admiral.txt
https://v.firebog.net/hosts/Easylist.txt
https://v.firebog.net/hosts/Easyprivacy.txt
https://v.firebog.net/hosts/Prigent-Ads.txt
https://v.firebog.net/hosts/Prigent-Crypto.txt
https://v.firebog.net/hosts/Shalla-mal.txt
https://v.firebog.net/hosts/static/w3kbl.txt
https://www.malwaredomainlist.com/hostslist/hosts.txt
https://zerodot1.gitlab.io/CoinBlockerLists/hosts_browser
'
SOURCES=$(echo "${SOURCES}" | sed '/^$/d') # trim empty lines

TARGET_DIR="$(mktemp -d tmp.XXXXX)"
FINAL_BLOCKLIST="blocklist.txt"
CURDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

delete_target_dir() {
    if [ -d "${TARGET_DIR}" ] && [ -z "${DEBUG:-}" ]; then
        rm -r "${TARGET_DIR}"
    fi
}
trap delete_target_dir EXIT

mkdir -p \
    "${TARGET_DIR}/raw" \
    "${TARGET_DIR}/cleaned"

echo "Fetching blocklists" >&2
parallel "${CURDIR}/download_file.sh" {} "${TARGET_DIR}/raw/{#}.txt" ::: "${SOURCES}"

echo "Cleaning up blocklists" >&2
parallel "${CURDIR}/blocklist_cleanup.py" {} "${TARGET_DIR}/cleaned/{/}.txt" ::: "${TARGET_DIR}/raw"/*.txt

echo "Aggregating blocklists" >&2
sort --unique "${TARGET_DIR}/cleaned"/*.txt > "${FINAL_BLOCKLIST}"

cat <<EOF >&2
Stats:
  Sources crawled : $(echo "${SOURCES}" | wc -l)
  Hosts blocked   : $(wc -l < "${FINAL_BLOCKLIST}")
  File size       : $(du -h "${FINAL_BLOCKLIST}" | awk '{print $1}')
EOF
