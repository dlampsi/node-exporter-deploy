#!/usr/bin/env bash
#
# Script uses for fetch or build service from source code repository specific

if [[ -z "$1" ]]; then
    echo "Script for fetch or build service artifact"
    echo "Usage: $0 <ACTION>"
    echo "Available ACTION is: 'fetch', 'build'"
    exit 1
else
    ACTION=$1
fi

: "${SERVICE_OS:="linux"}"
: "${SERVICE_ARCH:="amd64"}"
: "${REPO_BASE:="https://github.com/prometheus/node_exporter"}"
: "${OUT_DIR:=".artifacts"}"

binary_name="node_exporter"

if [ -d "$OUT_DIR" ]
then
    mkdir -p $OUT_DIR
fi

case $ACTION in
  "fetch")
    : "${SERVICE_FETCH_RELEASE:=""}"

    fetch_name="node_exporter-$SERVICE_FETCH_RELEASE.$SERVICE_OS-$SERVICE_ARCH"

    # Downloading package
    if [ ! -f "$OUT_DIR/$fetch_file" ]; then
        wget $REPO_BASE/releases/download/v$SERVICE_FETCH_RELEASE/$fetch_name.tar.gz -P $OUT_DIR
    else
        echo "File already exists in '$OUT_DIR/$fetch_name.tar.gz'"
    fi

    # Extracting and removing archive
    tar -xf $OUT_DIR/$fetch_name.tar.gz -C $OUT_DIR/ && \
      mv $OUT_DIR/$fetch_name/node_exporter $OUT_DIR/$binary_name &&\
      rm -rf $OUT_DIR/$fetch_name.tar.gz* $OUT_DIR/$fetch_name
    ;;
  "build")
    : "${SERVICE_BUILD_BRANCH:=""}"
    : "${SERVICE_BUILD_COMMIT:=""}"
    : "${SERVICE_BUILD_CLONE_DIR:="build"}"

    repo_dir="$SERVICE_BUILD_CLONE_DIR/node_exporter"

    # Delete cloned direcotry if already exists
    if [ -d "$repo_dir" ]
    then
        echo "Deleting existing repo cloned directory"
        rm -rf $repo_dir
    fi

    # Cloning repository
    clone_args=""
    if [ "$SERVICE_BUILD_BRANCH" != "" ]; then
      clone_args+="-b $SERVICE_BUILD_BRANCH"
    fi

    git clone $REPO_BASE.git $clone_args $repo_dir

    # Checkout specific commit.
    if [ "$SERVICE_BUILD_COMMIT" != "" ]; then
      cd $repo_dir && git checkout $SERVICE_BUILD_COMMIT
    fi

    echo "Building service..."
    cd $repo_dir && \
      GOOS=$SERVICE_OS GOARCH=$SERVICE_ARCH make && \
      mv node_exporter ../../$OUT_DIR/$binary_name
    ;;
  *)
    echo "Unexpected action type '$ACTION'"
    exit 1
    ;;
esac
