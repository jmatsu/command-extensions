git::logger() {
  local history_file="${GIT_LOGGER_LOCATION:-$HOME}/.git_history"

  command git "$@"

  local status=$?

  echo "$(date +%s) $(git::root_dir) ${status} git $@" >> "${history_file}"

  exit $?
}

git::logger::list() {
  local history_file="${GIT_LOGGER_LOCATION:-$HOME}/.git_history"

  awk -v root=$(git::root_dir) '$2==root&&$3==0{print substr($0,index($0,$4))}' "${history_file}"|uniq
}

git::root_dir() {
  local root_dir=$(command git rev-parse --git-dir)

  if [ "${root_dir%/*}" = "${root_dir}" ]; then
    root_dir=$(pwd)
  else
    root_dir="${root_dir%/*}"
  fi

  echo $root_dir
}

alias git=git::logger