_Hyde () {
    if [[ $(type -t _get_comp_words_by_ref) != function ]]; then
        echo _get_comp_words_by_ref: function not defined.  Make sure the bash-completions system package is installed
        return 1
    fi

    local words cword
    _get_comp_words_by_ref -n "$COMP_WORDBREAKS" words cword

    local -a literals=("revert" "--uninstall" "--install" "wallbash" "--opacity" "-j" "save" "unset" "3" "--rebuild" "--animations" "--stop" "backup" "BackUp" "list" "cursor" "-p" "Config" "d" "--scan" "--record-focus" "theme" "bookmarks" "0" "-freeze" "pastebin" "1" "systeminfo" "--all" "theme" "toggle" "upgrade" "waybar" "toggle" "reload" "update" "all" "glyph" "--print-monitor" "w" "game" "shell" "Config" "info" "reload" "reset" "--animations" "version" "select" "--blur" "theme" "clean" "size" "reload" "-f" "--print-snip" "reload" "Clone" "check" "override" "::=" "--mismatch" "prev" "--borderangle" "wallpaper" "--borderangle" "show" "-w" "inject" "power" "set" "binds" "rebuild" "screencap" "c" "man" "asus_patch" "events" "--blur" "restore" "-d" "emoji" "sddm" "run" "cache" "control" "prev" "chaotic_aur" "--less" "mode" "--opacity" "--reset" "Link" "audio_idle" "--print-all" "next" "-h" "select" "--preserve" "size" "next" "branch" "flatpak" "Config" "screencap" "--record-snip" "2" "--revert" "set" "patch" "select" "Package" "control")

    declare -A literal_transitions
    literal_transitions[0]="([32]=24 [58]=2 [35]=3 [47]=4 [3]=5 [59]=6 [21]=7 [82]=9 [83]=10 [101]=12 [84]=11 [34]=25 [41]=13 [85]=14 [75]=15 [27]=16 [12]=17 [64]=18 [15]=19 [66]=20 [68]=21 [31]=23 [69]=1 [79]=8)"
    literal_transitions[1]="([33]=27 [40]=27 [6]=37 [45]=27 [7]=34)"
    literal_transitions[2]="([111]=27 [42]=26)"
    literal_transitions[5]="([30]=27 [89]=35)"
    literal_transitions[7]="([48]=27 [95]=27 [109]=27 [86]=27 [108]=27)"
    literal_transitions[8]="([92]=27 [17]=27 [13]=27 [57]=27)"
    literal_transitions[9]="([50]=27)"
    literal_transitions[10]="([93]=27 [77]=27 [104]=30)"
    literal_transitions[11]="([72]=27 [56]=27)"
    literal_transitions[13]="([110]=27)"
    literal_transitions[14]="([103]=27)"
    literal_transitions[17]="([14]=27 [36]=27 [51]=27 [0]=27)"
    literal_transitions[18]="([97]=27 [100]=27 [70]=27 [62]=27)"
    literal_transitions[19]="([53]=27 [43]=27 [99]=27 [29]=27)"
    literal_transitions[20]="([81]=27 [73]=27 [25]=33 [37]=27 [71]=32 [22]=31)"
    literal_transitions[21]="([76]=27 [102]=27 [87]=29)"
    literal_transitions[24]="([44]=27 [52]=36 [112]=27)"
    literal_transitions[26]="([98]=27 [88]=27 [61]=27)"
    literal_transitions[28]="([60]=27)"
    literal_transitions[29]="([1]=27 [107]=27 [2]=27)"
    literal_transitions[30]="([11]=27 [105]=27 [20]=27 [38]=27 [24]=27 [91]=27 [55]=27 [94]=27 [19]=27)"
    literal_transitions[31]="([9]=27)"
    literal_transitions[32]="([5]=27 [96]=27 [16]=27 [67]=27 [80]=27 [54]=27)"
    literal_transitions[33]="([39]=27 [18]=27 [74]=27)"
    literal_transitions[34]="([4]=27 [46]=27 [65]=27 [78]=27)"
    literal_transitions[35]="([23]=27 [26]=27 [106]=27 [8]=27)"
    literal_transitions[36]="([28]=27)"
    literal_transitions[37]="([10]=27 [49]=27 [63]=27 [90]=27)"

    declare -A match_anything_transitions
    match_anything_transitions=([3]=27 [12]=27 [16]=27 [0]=22 [6]=27 [15]=27 [4]=27 [22]=28 [25]=27 [23]=27)
    declare -A subword_transitions

    local state=0
    local word_index=1
    while [[ $word_index -lt $cword ]]; do
        local word=${words[$word_index]}

        if [[ -v "literal_transitions[$state]" ]]; then
            declare -A state_transitions
            eval "state_transitions=${literal_transitions[$state]}"

            local word_matched=0
            for literal_id in $(seq 0 $((${#literals[@]} - 1))); do
                if [[ ${literals[$literal_id]} = "$word" ]]; then
                    if [[ -v "state_transitions[$literal_id]" ]]; then
                        state=${state_transitions[$literal_id]}
                        word_index=$((word_index + 1))
                        word_matched=1
                        break
                    fi
                fi
            done
            if [[ $word_matched -ne 0 ]]; then
                continue
            fi
        fi

        if [[ -v "match_anything_transitions[$state]" ]]; then
            state=${match_anything_transitions[$state]}
            word_index=$((word_index + 1))
            continue
        fi

        return 1
    done


    local prefix="${words[$cword]}"

    local shortest_suffix="$word"
    for ((i=0; i < ${#COMP_WORDBREAKS}; i++)); do
        local char="${COMP_WORDBREAKS:$i:1}"
        local candidate="${word##*$char}"
        if [[ ${#candidate} -lt ${#shortest_suffix} ]]; then
            shortest_suffix=$candidate
        fi
    done
    local superfluous_prefix=""
    if [[ "$shortest_suffix" != "$word" ]]; then
        local superfluous_prefix=${word%$shortest_suffix}
    fi

    if [[ -v "literal_transitions[$state]" ]]; then
        local state_transitions_initializer=${literal_transitions[$state]}
        declare -A state_transitions
        eval "state_transitions=$state_transitions_initializer"

        for literal_id in "${!state_transitions[@]}"; do
            local literal="${literals[$literal_id]}"
            if [[ $literal = "${prefix}"* ]]; then
                local completion=${literal#"$superfluous_prefix"}
                COMPREPLY+=("$completion ")
            fi
        done
    fi

    return 0
}

complete -o nospace -F _Hyde Hyde
