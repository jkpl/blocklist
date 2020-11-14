# Blocklist

[Blocklist](https://jkpl.gitlab.io/blocklist/blocklist.txt) for dnsmasq.

## Using in Ubiquity EdgeMAX routers

1. Log into your Edgerouter
2. Grant yourself superuser permissions using `sudo -i`
3. Add the following contents to this file: `/config/user-data/update-adblock-dnsmasq.sh` (`vi` should be available)
    ```bash
    #!/usr/bin/env bash
    set -euo pipefail

    AD_LIST_URL="https://jkpl.gitlab.io/blocklist/blocklist.txt"
    AD_FILE="/etc/dnsmasq.d/dnsmasq.adlist.conf"
    TEMP_AD_FILE="/etc/dnsmasq.d/dnsmasq.adlist.conf.tmp"

    curl -sSfL -o "$TEMP_AD_FILE" "$AD_LIST_URL"

    if [ -f "$TEMP_AD_FILE" ]
    then
        mv "$TEMP_AD_FILE" "$AD_FILE"
    else
        echo "Failed to build the ad list"
        exit 1
    fi

    systemctl restart dnsmasq
    ```
4. Make the file executable: `chmod +x /config/user-data/update-adblock-dnsmasq.sh`
5. Run it: `/config/user-data/update-adblock-dnsmasq.sh`
6. Schedule it with cron: `(crontab -l ; echo "56 4 * * 6  /config/user-data/update-adblock-dnsmasq.sh") | crontab -`
7. Logout

## License

MIT License. See [LICENSE](LICENSE) for more information.
