#!/usr/bin/python3
from brownie import (
    DataTypesV2,
    TransparentUpgradeableProxy,
    ProxyAdmin,
    config,
    network,
    Contract,
)
from scripts.helpful_scripts import get_account, upgrade


def main():
    account = get_account()
    print(f"Deploying to {network.show_active()}")
    data_types_v2 = DataTypesV2.deploy(
        {"from": account},
        publish_source=config["networks"][network.show_active()]["verify"],
    )
    proxy = TransparentUpgradeableProxy[-1]
    proxy_admin = ProxyAdmin[-1]

    upgrade(account, proxy, data_types_v2, proxy_admin, data_types_v2.setDataTypes, 1)
    print("Proxy has been upgraded!")
    proxy_data_types_v2 = Contract.from_abi("DataTypesV2", proxy.address, DataTypesV2.abi)
    '''print(f"Proxy admin is {proxy_admin.getProxyAdmin(proxy)}")
    print(f"Imp address is {proxy_admin.getProxyImplementation(proxy)}")'''
