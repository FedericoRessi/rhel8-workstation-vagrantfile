#!/bin/bash


function main {
    register_rh_subscription
    install_python
}


function register_rh_subscription {
    if ! is_rh_subscribed; then
        set +x
        subscription-manager register \
            --force \
            --username "${SUBSCRIPTION_MANAGER_USERNAME}" \
            --password "${SUBSCRIPTION_MANAGER_PASSWORD}" \
            --auto-attach
        set -x
        is_rh_subscribed
    fi
}


function is_rh_subscribed {
    [ "$(get_rh_subscription_status)" == Subscribed ]
}


function get_rh_subscription_status {
    subscription-manager list | awk '($1 == "Status:"){print $2;exit;}'
}


function install_python {
    dnf install -y gcc python3 python3-devel
    alternatives --set python /usr/bin/python3
}


set -eux
main "$*"
