#!/usr/bin/python3
from brownie import (
    TransparentUpgradeableProxy,
    config,
    network,
    PersonalData,
)
from scripts.helpful_scripts import get_account, encode_function_data


def main():
    account = get_account()
    print(config["networks"][network.show_active()])
    print(f"Deploying to {network.show_active()}")
    proxy = TransparentUpgradeableProxy[-1]
    personal_data = PersonalData.deploy(
        "0x51BA25E291b2c33D497edaeF8C81B181c4099D42",
        "0x51BA25E291b2c33D497edaeF8C81B181c4099D42",
        proxy.address,
        "Nodys",
        {"from": account},
        publish_source=config["networks"][network.show_active()]["verify"],
    )
    # print(personal_data.retString("cat"))
    personal_data.addDataType("user.provided.identifiable.gender")
    #print(personal_data.retrieveDataTypes())
