#!/bin/bash
# Script to Download Assets from public GitHub Repositories
# Downloads either assets of the latest release or, if no releases exists, it downloads the master branch and saves it to a specified directory.
#!/bin/bash

repo_list="repositories.list"
default_dir="$HOME/tools"

# Ensure necessary tools are installed
for tool in jq git unzip; do
    if ! command -v $tool &> /dev/null; then
        echo "$tool could not be found, please install it first."
        exit 1
    fi
done

# Function to download the latest release assets
download_latest_release() {
    local repo=$1
    local specified_assets="$2"
    local target_dir=$3
    local api_url="https://api.github.com/repos/$repo/releases/latest"
    local response=$(curl -s $api_url)

    download_and_copy_assets "$response" "$specified_assets" "$target_dir"
}

# Function to download and extract the master branch
download_master_branch() {
    local repo=$1
    local target_dir=$2
    shift 2 # Shift the first two arguments off, leaving any specified assets.
    local specified_assets=("$@") # All remaining arguments are treated as specified assets.


    # echo "Downloading assets from the master branch of $repo..."
    # echo "Specified assets: ${specified_assets[*]}"
    # echo "Target directory: $target_dir"
    # exit 0
    
    local tmp_dir=$(mktemp -d)

    git clone --depth 1 "https://github.com/$repo.git" "$tmp_dir"
    

    if [ ${#specified_assets[@]} -gt 0 ]; then
        for asset in "${specified_assets[@]}"; do
            # Construct the full path of the asset to check if it exists
            local asset_path="$tmp_dir/$asset"
            if [ -e "$asset_path" ]; then
                # Determine if the asset is a directory and copy it accordingly
                if [ -d "$asset_path" ]; then
                    # Asset is a directory, use the -r option to copy
                    cp -r "$asset_path" "$target_dir/$asset"
                else
                    # Asset is a file, copy it normally
                    cp "$asset_path" "$target_dir/$asset"
                fi
            else
                echo "Specified asset not found in master branch: $asset"
            fi
        done
    else
        # No specific assets, copy all files from the cloned repo to the target directory
        cp -r "$tmp_dir/." "$target_dir/"
    fi

    # Clean up the temporary directory
    rm -rf "$tmp_dir"
}

# Function to handle the downloading and optional filtering of assets
download_and_copy_assets() {
    local repo=$1
    local target_dir=$2
    shift 2 # Shift the first two arguments off, leaving any specified assets.
    local specified_assets=("$@") # All remaining arguments are treated as specified assets.

    if [ -n "$specified_assets" ]; then
        # If specific assets are specified, only download those
        for asset_name in $specified_assets; do
            download_url=$(echo $response | jq -r --arg name "$asset_name" '.assets[] | select(.name == $name) | .browser_download_url')
            if [ -n "$download_url" ]; then
                echo "Downloading specified asset: $asset_name to $target_dir"
                curl -L "$download_url" -o "$target_dir/$asset_name"
            else
                echo "Specified asset not found: $asset_name"
            fi
        done
    else
        # If no specific assets are specified, download all assets
        echo "$response" | jq -c '.assets[]' | while read -r asset; do
            asset_url=$(echo "$asset" | jq -r '.browser_download_url')
            asset_name=$(echo "$asset" | jq -r '.name')
            
            echo "Downloading $asset_name to $target_dir..."
            curl -L "$asset_url" -o "$target_dir/$asset_name"
        done
    fi
}

# Function to parse the repositories.list and process each line
parse_and_process() {
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        # Initialize default values
        local mode="latest" # Default mode is 'latest'
        local specified_assets=()

        # Detect if the line starts with 'latest' or 'master'
        if [[ "$line" =~ ^(latest|master) ]]; then
            mode=$(echo "$line" | awk '{print $1}') # Capture 'latest' or 'master'
            line=${line#* } # Remove the first word from the line
        fi

        # Extract repository, which is now the first word
        local repo=$(echo "$line" | awk '{print $1}')
        local target_dir="$default_dir/$repo"

        # Check for and extract specified assets, if any
        if [[ "$line" =~ \[.*\] ]]; then
            local assets_part=$(echo "$line" | grep -oP '\[.*?\]')
            specified_assets=($(echo "$assets_part" | tr -d '[]' | tr ',' ' '))
        fi

        # Extract target directory if specified
        if [[ "$line" == *">"* ]]; then
            target_dir=$(echo "$line" | grep -oP '>.*' | cut -c2- | xargs)
        fi
        mkdir -p "$target_dir"

        # echo "Processing $repo..."
        # echo "Mode: $mode"
        # echo "Specified assets: ${specified_assets[*]}"
        # echo "Target directory: $target_dir"

        # Call the appropriate function based on the mode
        if [ "$mode" == "latest" ]; then
            download_latest_release "$repo" "$target_dir" "${specified_assets[@]}"
        elif [ "$mode" == "master" ]; then
            download_master_branch "$repo" "$target_dir" "${specified_assets[@]}"
        fi


    done < "$repo_list"
}

parse_and_process

exit 0



# # Path to the repositories list
repo_list="repositories.list"
# Default target directory
default_dir="$HOME/tools"

# Ensure jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq could not be found, please install it first."
    exit 1
fi

# Check if the repositories list file exists
if [ ! -f "$repo_list" ]; then
    echo "The repository list file does not exist: $repo_list"
    exit 1
fi

# Read each line from the repository list
while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    # Detect if there is a target directory specified
    if [[ "$line" == *">"* ]]; then
        repo_assets_part=$(echo "$line" | cut -d '>' -f1 | xargs)
        repo=$(echo "$repo_assets_part" | grep -o '^[^\[]*' | xargs)
        target_dir=$(echo "$line" | cut -s -d '>' -f2- | xargs)
    else
        repo_assets_part="$line"
        repo=$(echo "$repo_assets_part" | grep -o '^[^\[]*' | xargs)
        target_dir="$default_dir/$repo"
    fi
  
    # # Extracting specified assets, removing brackets and replacing commas with spaces
    specified_assets=$(echo "$repo_assets_part" | grep -oP '\[.*?\]' | tr -d '[]' | tr ',' ' ')

    echo "repo_assets: $specified_assets"
    echo "target_dir: $target_dir"  

    echo "Processing $repo..."

    # # Construct the API URL
    api_url="https://api.github.com/repos/$repo/releases/latest"

    # # Fetch the latest release data
    response=$(curl -s $api_url)

    # # Ensure target directory exists
    mkdir -p "$target_dir"

    if [ -n "$specified_assets" ]; then
        # If specific assets are specified, only download those
        for asset_name in $specified_assets; do
            download_url=$(echo $response | jq -r --arg name "$asset_name" '.assets[] | select(.name == $name) | .browser_download_url')
            if [ -n "$download_url" ]; then
                echo "Downloading specified asset: $asset_name to $target_dir"
                curl -L "$download_url" -o "$target_dir/$asset_name"
            else
                echo "Specified asset not found: $asset_name"
            fi
        done
    else
        # If no specific assets are specified, download all assets
        echo "$response" | jq -c '.assets[]' | while read -r asset; do
            asset_url=$(echo "$asset" | jq -r '.browser_download_url')
            asset_name=$(echo "$asset" | jq -r '.name')
            
            echo "Downloading $asset_name to $target_dir..."
            curl -L "$asset_url" -o "$target_dir/$asset_name"
        done
    fi
done < "$repo_list"