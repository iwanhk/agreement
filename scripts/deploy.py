from scripts.functions import *


def main():
    active_network = network.show_active()
    print("Current Network:" + active_network)

    admin, creator, consumer, iwan = get_accounts(active_network)

    try:
        if active_network in LOCAL_NETWORKS:
            nft = Agreement.deploy(addr(admin))
        if active_network in TEST_NETWORKS:
            nft = Agreement.deploy(addr(admin))
            asset = Asset.deploy(addr(admin))

        if active_network in REAL_NETWORKS:
            #nft = Agreement.deploy(addr(admin))
            # 0x7eE5eA1f769703B755A2F7A7C76E9C00fd2aB8C7
            admin.deploy(contract=Agreement, publish_source=True)

    except Exception:
        console.print_exception()
        # Test net contract address


if __name__ == "__main__":
    main()
