#!/bin/bash
#=================================================
# File name: patch_autocore.sh
# System Required: Linux
# Version: 1.0
# Lisence: GPL-3.0
# Author: AsVow
# Blog: https://asvow.com
#=================================================
set -e

file_a="feeds/luci/modules/luci-base/root/usr/share/rpcd/ucode/luci"
file_b="feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js"
file_c="feeds/luci/modules/luci-mod-status/root/usr/share/rpcd/acl.d/luci-mod-status.json"
insert_path="$(dirname "$0")/autocore"

execute_sed() {
    local file=$1
    local pattern=$2
    local insert_text=$(cat $3 | sed -e 's#\t#€#g' -e ':a;N;$!ba;s#\n#£#g' -e 's#[]\.|$(){}?+*^]#\\&#g')
    local position=$4
    local delete=${5:-false}
    local single_line_pattern=$(echo "$pattern" | sed -e 's#\\n#£#g' -e 's#\\t#€#g')

    sed -i 's#\t#€#g' $file
    sed -i ':a;N;$!ba;s#\n#£#g' $file

    if grep -q "$single_line_pattern" $file; then
        if [ "$position" = "above" ]; then
            sed -i "s#$single_line_pattern#$insert_text£$single_line_pattern#g" $file
        elif [ "$position" = "below" ]; then
            sed -i "s#$single_line_pattern#$single_line_pattern£$insert_text#g" $file
        elif [ "$position" = "append" ]; then
            sed -i "s#$single_line_pattern#$single_line_pattern$insert_text#g" $file
        fi
        [ "$delete" = "true" ] && sed -i "s#$single_line_pattern##g" $file
    else
        echo "Pattern '$pattern' not found in $file"
        exit 1
    fi

    sed -i 's#£#\n#g' $file
    sed -i 's#€#\t#g' $file
}

execute_sed $file_a "\t}\n};\n\n" "$insert_path/ucode_luci" "above"

execute_sed $file_b "method: 'info'\n});" "$insert_path/status_a.js" "below"
execute_sed $file_b "L.resolveDefault(callSystemInfo(), {})," "$insert_path/status_b.js" "below"
execute_sed $file_b "\n\t\t    luciversion = data\[2\];" "$insert_path/status_c.js" "below" "true"
execute_sed $file_b "\n\t\t\t_('Architecture'),     boardinfo.system," "$insert_path/status_d.js" "below" "true"
execute_sed $file_b "\t\t\t) : null" "$insert_path/status_e.js" "append"
execute_sed $file_b "\t\t];" "$insert_path/status_f.js" "below"

execute_sed $file_c '\n\t\t\t\t"luci": \[ "getConntrackList", "getRealtimeStats" \],' "$insert_path/status_rpcd_acl.json" "below" "true"