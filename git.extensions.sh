git::logger() {
  local history_file="${GIT_LOGGER_LOCATION:-$HOME}/.git_history"

  echo "$(date +%s) $(git::root_dir) git $@" >> "${history_file}"
  command git "$@"
}

git::root_dir() {
  local root_dir=$(command git rev-parse --git-dir)

  if [ "${root_dir%/*}" = "${root_dir}" ];
    root_dir=$(pwd)
  else
    root_dir="${root_dir%/*}"
  fi

  echo $root_dir
}

alias git=git::logger