zmodload -F zsh/datetime p:EPOCHREALTIME

_command_time_preexec() {
  # check excluded
  if [ -n "$ZSH_COMMAND_TIME_EXCLUDE" ]; then
    cmd="$1"
    for exc ($ZSH_COMMAND_TIME_EXCLUDE) do;
      if grep -qF "$exc" <<< "$cmd"; then
        # echo "command excluded: $exc"
        return
      fi
    done
  fi

  _command_time_timer=$EPOCHREALTIME
  ZSH_COMMAND_TIME_MSG=${ZSH_COMMAND_TIME_MSG-"Time: %s"}
  ZSH_COMMAND_TIME_COLOR=${ZSH_COMMAND_TIME_COLOR-"white"}
  ZSH_COMMAND_TIME_NO_COLOR=${ZSH_COMMAND_TIME_NO_COLOR-""}
  export ZSH_COMMAND_TIME=""
}

_command_time_precmd() {
  [[ -n $_command_time_timer ]] || return
  # C locale keeps the decimal separator a dot
  local LC_NUMERIC=C
  # read by zsh_command_time for the sub-second display
  local -F _command_time_elapsed=$(( EPOCHREALTIME - _command_time_timer ))
  local -i precision=${ZSH_COMMAND_TIME_PRECISION:-0}
  unset _command_time_timer
  if [[ -n $TTY ]] && (( _command_time_elapsed >= ${ZSH_COMMAND_TIME_MIN_SECONDS:-3} )); then
    if (( precision > 0 )); then
      printf -v ZSH_COMMAND_TIME "%.${precision}f" $_command_time_elapsed
    else
      ZSH_COMMAND_TIME=${_command_time_elapsed%%.*}
    fi
    export ZSH_COMMAND_TIME
    if [ ! -z ${ZSH_COMMAND_TIME_MSG} ]; then
      zsh_command_time
    fi
  fi
}

zsh_command_time() {
  local timer_show color sec_fmt ms
  if [ -n "$ZSH_COMMAND_TIME" ]; then
    local LC_NUMERIC=C
    local -i precision=${ZSH_COMMAND_TIME_PRECISION:-0}
    local -i total_sec=$(( ZSH_COMMAND_TIME ))
    local -i days=$(( total_sec / 86400 ))
    local -i hours=$(( total_sec / 3600 % 24 ))
    local -i min=$(( total_sec / 60 % 60 ))
    # whole seconds of the last minute plus the fractional part
    printf -v sec_fmt "%.${precision}f" $(( total_sec % 60 + ZSH_COMMAND_TIME - total_sec ))
    color="$ZSH_COMMAND_TIME_COLOR"
    # under a second, show ms from the raw value so precision 1 still gives 18ms
    if (( precision > 0 )) && [[ -n $_command_time_elapsed ]]; then
      printf -v ms '%.0f' $(( _command_time_elapsed * 1000 ))
    fi
    if [[ -n "$ms" ]] && (( ms < 1000 )); then
        timer_show="${ms}ms"
    elif [[ "$total_sec" -lt 60 ]]; then # less than 1 minute
        timer_show="${sec_fmt}s"
    elif [[ "$total_sec" -lt 3600 ]]; then  # less than 1 hour
        timer_show="${min}m ${sec_fmt}s"
    elif [[ "$days" -eq 0 ]]; then  # less than 1 day
        timer_show="${hours}h ${min}m ${sec_fmt}s"
    else # 1 day or more
        timer_show="${days}d ${hours}h ${min}m ${sec_fmt}s"
    fi
    if [ -n "$ZSH_COMMAND_TIME_NO_COLOR" ]; then
      color="$ZSH_COMMAND_TIME_COLOR"
    else
        if [[ "$total_sec" -lt ${ZSH_COMMAND_TIME_SECONDS_GREEN:-60} ]]; then
            color="green"
        elif [[ "$total_sec" -lt ${ZSH_COMMAND_TIME_SECONDS_YELLOW:-180} ]]; then
            color="yellow"
        else
            color="red"
        fi
    fi
    print -P "%F{$ZSH_COMMAND_TIME_COLOR}$(printf "${ZSH_COMMAND_TIME_MSG}" "%F{$color}$timer_show")%f"
  fi
}

precmd_functions+=(_command_time_precmd)
preexec_functions+=(_command_time_preexec)
