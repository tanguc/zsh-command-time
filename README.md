# zsh-command-time

Plugin that output `time: xx` after long commands and export `ZSH_COMMAND_TIME` variable for usage in your scripts.

Example output with `typeset -F SECONDS`:

![screenshot](screen1.png)

It similar builin feature [REPORTTIME](http://zsh.sourceforge.net/Doc/Release/Parameters.html), but it outputs only
if user + system time >= `REPORTTIME` in config. For example:
```bash
$ time sleep 3
sleep 3  0,00s user 0,00s system 0% cpu 3,008 total
```
Sleep don't consume any cpu time and `REPORTTIME` "don't see" such idle commands.

If you need to monitor only cpu-angry commands, use `REPORTTIME` instead this plugin.


## Install with antigen
```bash
antigen bundle popstas/zsh-command-time
```

## Install with zplug
```bash
zplug "popstas/zsh-command-time"
```


## Install for oh-my-zsh

Download:
```bash
git clone https://github.com/popstas/zsh-command-time.git ~/.oh-my-zsh/custom/plugins/command-time
```
And add `command-time` to `plugins` in `.zshrc`.


## Configuration

You can override defaults in `.zshrc`:
```bash
# Decimal places to show, 3 for milliseconds (default 0, whole seconds).
# Timing uses $EPOCHREALTIME, so no need for `typeset -F SECONDS`.
ZSH_COMMAND_TIME_PRECISION=3

# If command execution time above min. time, plugins will output time.
# Fractions work too, e.g. 0.5.
ZSH_COMMAND_TIME_MIN_SECONDS=3

# Message to display (set to "%s" for disable).
ZSH_COMMAND_TIME_MSG="Execution time: %s sec"

# Message color.
ZSH_COMMAND_TIME_COLOR="cyan"

# Don’t colorize the output based on the duration. Default colors: green < 1 min, yellow < 3 min, red >= 3 min.
ZSH_COMMAND_TIME_NO_COLOR="1"

# Exclude some commands
ZSH_COMMAND_TIME_EXCLUDE=(vim mcedit)
```

### Customization
You can customize view of the plugin by redefinition of function
`zsh_command_time`. There is an example of custom definition `zsh_command_time`:
```bash
zsh_command_time() {
    local hours min sec timer_show
    if [ -n "$ZSH_COMMAND_TIME" ]; then
        # hours and minutes are calculated from the total seconds as integers
        typeset -i hours=$(( ZSH_COMMAND_TIME / 3600))
        typeset -i min=$(( ZSH_COMMAND_TIME / 60 % 60))
        if [[ "$ZSH_COMMAND_TIME" == *.* ]]; then
            # set when ZSH_COMMAND_TIME_PRECISION > 0, keep 3 decimal places
            typeset -F 3 sec
        fi
        # secunds are calculated as float or integer automatically
        sec=$(( ZSH_COMMAND_TIME % 60 ))
        if [[ "$min" == 0 ]]; then
            timer_show="$fg[green]$sec s."
        elif [[ 1 -le "$min" && "$min" -le 3 ]]; then
            timer_show="$fg[yellow]$min min. $sec s."
        else
            if [[ "$hours" != 0 ]]; then
                timer_show="$fg[red]$hours h. $min min. $sec s."
            else
                timer_show="$fg[red]$min min. $sec s."
            fi
        fi
        printf "${ZSH_COMMAND_TIME_MSG}\n" "$timer_show"
    fi
}
```

You can see result of this function on the following screenshot:

![screenshot](screen2.jpg)

Variable `$ZSH_COMMAND_TIME` contains execution time in seconds. We calculate
how many minutes and hours it was and print this information to terminal.
* Commands that were executed less than one minutes highlights by green color.
* Commands that were executed less than three minutes highlights by yellow color.
* Commands that were executed more than three minutes highlights by red color.

## Usage with [powerlevel9k](https://github.com/bhilburn/powerlevel9k) theme
You should not want to use this plugin with powerlevel9k.
Sinse powerlevel9k v0.6.0 theme have native segment 
[command_execution_time](https://github.com/bhilburn/powerlevel9k#command_execution_time)
(see [PR](https://github.com/bhilburn/powerlevel9k/pull/402)), so you can just add it to your prompt:
```bash
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status background_jobs vcs command_execution_time time)
```

If you still want to use it with powerlevel9k, add custom element in `.zshrc`:
```bash
POWERLEVEL9K_CUSTOM_COMMAND_TIME="zsh_command_time"
POWERLEVEL9K_CUSTOM_COMMAND_TIME_BACKGROUND="253" # white
POWERLEVEL9K_CUSTOM_COMMAND_TIME_FOREGROUND="000" # black
```

And add element `custom_command_time` to your prompt:
```bash
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status background_jobs vcs custom_command_time time)
```


## Provision with ansible
~~Plugin `command-time` included in ansible role [viasite-ansible/ansible-role-zsh](https://github.com/viasite-ansible/ansible-role-zsh)
with other useful plugins.~~ Plugin excluded from viasite-ansible.zsh, but you can still check role.
