#!/usr/bin/env bash

# Create an executable file at a given location
# $1 = Location
# $2 = Name of the file (executable)
# $3 = Optional - interpreter, appended to /usr/bin/env, default bash
create_executable() {
  scripts_dir="$1"

  if [[ ! -d $scripts_dir ]]; then
    mkdir -p $scripts_dir
  fi

  # Parse filename and create the script
  filename="$2"
  script_path="$scripts_dir/$filename"
  touch $script_path
  chmod +x $script_path

  # Parse interpreter
  interpreter="bash"
  if [[ -z "$3" ]]; then
    : #noop
  else 
    interpreter="$3"
  fi

  echo "Using interpreter: $interpreter"

  echo "#!/usr/bin/env $interpreter" > $script_path
  echo "" >> $script_path
  echo "" >> $script_path

  echo "Created script: $script_path"
  echo "Press enter to edit now, or enter any string to decline:"
  read -r should_open

  if [[ -z $should_open ]]; then
    $EDITOR $script_path
  else
    exit 0
  fi
}

# Print either "linux" or "macos"
detect_os() {
  if [[ $OSTYPE == "darwin" ]]; then
    echo "macos"
  elif [[ $OSTYPE == "linux-gnu" ]]; then
    echo "linux"
  else
    echo "unsupported operating system"
    exit 1
  fi
}

