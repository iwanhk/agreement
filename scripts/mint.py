from scripts.functions import *


def main():
    active_network = network.show_active()
    print("Current Network:" + active_network)

    admin, creator, consumer, iwan = get_accounts(active_network)

    try:
        if active_network in LOCAL_NETWORKS:
            nft=Agreement.deploy(addr(admin))
            asset= Asset.deploy(addr(admin))

            asset.mint(addr(creator))
            asset.mint(addr(iwan))

            # nft.create("TERMS", [(asset, 1)], addr(iwan))
            # nft.sign(0, [(asset, 0)], addr(creator))
            # nft.sign(0, addr(admin))
            # print(nft.agreement(0))

            # nft.create("TERMS", addr(iwan))
            # nft.sign(1, [(asset, 0)], addr(creator))
            # nft.sign(1, addr(admin))
            # print(nft.agreement(1))

            with open('BYC#3769.txt', 'r') as f:
                terms= f.read()
                nft.create(terms, chain.time()+ 60*60*24*365, [creator], [asset], addr(iwan))
            nft.sign(0, [(asset, 0)], addr(creator))



        if active_network in TEST_NETWORKS:
            nft=Agreement.deploy(addr(admin))
            

    except Exception:
        console.print_exception()
        # Test net contract address


if __name__ == "__main__":
    main()
