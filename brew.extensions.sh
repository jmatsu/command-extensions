brew::logger() {
  local history_file="${BREW_LOGGER_LOCATION:-$HOME}/.brew_history"

  echo "$(date +%s) brew $@" >> "${history_file}"
  command brew "$@"

  # Compress each of sequences which are continuous executed commands
  cat "${history_file}"|tail -r|uniq -f1|tail -r > "${history_file}.backup"
  mv -f "${history_file}.backup" "${history_file}"
}

brew::check_command() {
  local history_file="${BREW_LOGGER_LOCATION:-$HOME}/.brew_history"

  if [ -f "${history_file}" -a ! "$#" = "0" ]; then
    local cmd="$1"
    local last_run="$(cat "${history_file}"|grep "$cmd"|tail -1)"

    if [ -n "${last_run:-}" ]; then
      local time=$(echo "${last_run}"|awk '$0=$1')
      local last_run_date="$(echo "${time}"|perl -e '@t=localtime(<>);printf("%d/%02d/%02d %02d:%02d:%02d\n",@t[5]+1900,@t[4]+1,@t[3],@t[2],@t[1],@t[0])')"
      echo "brew ${cmd} is run at ${last_run_date}"
    fi
  fi
}

brew::all() {
  local formula
  while read formula; do
    echo -n $formula
    command brew deps $formula | awk '{ printf " %s ", $0}'
    echo
  done < <(brew list)
}

brew::export() {
  local backup_file="${BREW_LOGGER_LOCATION:-$HOME}/.brew_backup"

  echo "Exported at $(date +%s)" > "${backup_file}"
  command brew list|tr "[:space:]" "\n" >> "${backup_file}"
}

brew::export::select() {
  local tmp_file=$(mktemp -t tmp)
  local tmp_file2=$(mktemp -t tmp2)

  trap "rm -f ${tmp_file} ${tmp_file2}; exit 1" 1 2 3 15

  command brew list > "${tmp_file}"
  ${EDITOR:-vim} "${tmp_file}"

  local formula
  while read formula; do
    echo -n $formula >> "${tmp_file2}"
    command brew deps $formula | awk '{ printf " %s ", $0}' >> "${tmp_file2}"
    echo >> "${tmp_file2}"
  done < <(cat "${tmp_file}"|grep -v -e '^\s*#' -e '^\s*$'|awk '$0 ~ /^[^#]/ {print $0}')

  cat "${tmp_file2}"|awk '{printf "%d %s\n",NF,$0 }'|sort -rn|awk '{
    for(i=2;i<=NF;i++){
      if(m[$i]==0){
        m[$i]=1;printf "%s ", $i
      }
    }
    print ""
  }'|sort|uniq|awk '{printf "%d %s\n",NF,$0 }'|sort -rn|awk '$0=$2'

  rm -f "${tmp_file}" "${tmp_file2}"

  trap 1 2 3 15
}
