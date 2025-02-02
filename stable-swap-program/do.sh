#!/usr/bin/env bash

set -ex
cd "$(dirname "$0")"

export PATH="$HOME"/.local/share/solana/install/active_release/bin:"$PATH"

usage() {
    cat <<EOF
Usage: do.sh <action> <action specific arguments>
Supported actions:
    e2e-test
    test
EOF
}

perform_action() {
    case "$1" in
    e2e-test)
        (
            rm -rf scripts/tmp
            anchor build --program-name stable_swap
            solana-test-validator -r --quiet --bpf-program 8h7HJug4hX3C6eQcda5darrsZ5g9RHUYoN7h1dKkA9Jf ../target/deploy/stable_swap.so &
            yarn --cwd sdk install
            yarn --cwd sdk test-int ${@:2}
        )
        ;;
    help)
        usage
        exit
        ;;
    test)
        cargo test-bpf --manifest-path program/Cargo.toml -- --test-threads 1 ${@:2}
        ;;
    esac
}

if [[ $1 == "update" ]]; then
    perform_action "$1"
    exit
else
    if [[ "$#" -lt 1 ]]; then
        usage
        exit
    fi
    if ! hash solana 2>/dev/null; then
        solana-install update
    fi
fi

perform_action "$1" "${@:2}"
