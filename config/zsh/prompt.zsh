# Minimal zsh prompt with git branch, command duration, and exit status.

setopt prompt_subst
zmodload zsh/datetime 2>/dev/null || true
autoload -Uz add-zsh-hook

typeset -g _prompt_command_start=0
typeset -g _prompt_elapsed=""
typeset -g _prompt_has_command=0

_prompt_format_elapsed() {
  local elapsed=$1
  local hours=$(( elapsed / 3600 ))
  local minutes=$(( elapsed / 60 ))
  local seconds=$(( elapsed % 60 ))

  if (( hours > 0 )); then
    printf "%dh%02dm" "$hours" $(((elapsed % 3600) / 60))
  elif (( minutes > 0 )); then
    printf "%dm%02ds" "$minutes" "$seconds"
  else
    printf "%ds" "$elapsed"
  fi
}

_prompt_preexec() {
  _prompt_command_start=$EPOCHSECONDS
  _prompt_has_command=1
}

_prompt_precmd() {
  local exit_code=$?
  local now=$EPOCHSECONDS
  local git_info=""
  local symbol="%(!.#.❯)"
  local right=""

  _prompt_elapsed=""
  if (( _prompt_command_start > 0 )); then
    local elapsed=$(( now - _prompt_command_start ))
    (( elapsed >= 2 )) && _prompt_elapsed=$(_prompt_format_elapsed "$elapsed")
    _prompt_command_start=0
  fi

  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local branch
    branch=$(git branch --show-current 2>/dev/null)
    [[ -z "$branch" ]] && branch=$(git rev-parse --short HEAD 2>/dev/null)

    if [[ -n "$branch" ]]; then
      git_info=" %F{magenta} ${branch}%f"
      local git_status
      local status_line
      local has_staged=0
      git_status=$(git status --porcelain 2>/dev/null)

      for status_line in ${(f)git_status}; do
        if [[ "${status_line[1,1]}" != " " && "${status_line[1,1]}" != "?" ]]; then
          has_staged=1
          break
        fi
      done

      if (( has_staged )); then
        git_info+="±"
      elif [[ -n "$git_status" ]]; then
        git_info+="≈"
      fi
    fi
  fi

  [[ -n "$_prompt_elapsed" ]] && right="%F{yellow}[${_prompt_elapsed}]%f"

  if (( _prompt_has_command == 0 )); then
    PROMPT="%F{blue}%~%f${git_info} ${symbol} "
  elif (( exit_code == 0 )); then
    PROMPT="%F{blue}%~%f${git_info} %F{green}${symbol}%f "
  else
    PROMPT="%F{blue}%~%f${git_info} %F{red}${symbol}%f "
  fi
  RPROMPT="$right"
}

if [[ -z ${(M)preexec_functions:#_prompt_preexec} ]]; then
  add-zsh-hook preexec _prompt_preexec
fi

if [[ -z ${(M)precmd_functions:#_prompt_precmd} ]]; then
  add-zsh-hook precmd _prompt_precmd
fi
