#!/usr/bin/python3
import time
from brownie import (
    DataTypes,
    TransparentUpgradeableProxy,
    ProxyAdmin,
    config,
    network,
    Contract,
)
from scripts.helpful_scripts import get_account, encode_function_data


def main():
    account = get_account()
    print(config["networks"][network.show_active()])
    print(f"Deploying to {network.show_active()}")
    data_types = DataTypes.deploy(
        {"from": account},
        publish_source=config["networks"][network.show_active()]["verify"],
    )
    # Optional, deploy the ProxyAdmin and use that as the admin contract
    proxy_admin = ProxyAdmin.deploy(
        {"from": account},
        publish_source=config["networks"][network.show_active()]["verify"]
    )

    # If we want an intializer function we can add
    # `initializer=box.store, 1`
    # to simulate the initializer being the `store` function
    # with a `newValue` of 1
    # data_types_encoded_initializer_function = encode_function_data(data_types.setDataTypes)
    data_types_encoded_initializer_function = encode_function_data(
        data_types.setDataTypes, 10
    )
    proxy = TransparentUpgradeableProxy.deploy(
        data_types.address,
        proxy_admin.address,
        data_types_encoded_initializer_function,
        # gas limit removed fort an issue not very clear
        # {"from": account, "gas_limit": 100000000000},
        {"from": account},
        publish_source=config["networks"][network.show_active()]["verify"]
    )
    print(f"Proxy deployed to {proxy} ! You can now upgrade it to dataTypesV2!")
    proxy_data_types = Contract.from_abi("DataTypes", proxy.address, DataTypes.abi)
    print(proxy_data_types.retrieveDataTypes())
