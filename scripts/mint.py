from scripts.functions import *


def main():
    active_network = network.show_active()
    print("Current Network:" + active_network)

    admin, creator, consumer, iwan = get_accounts(active_network)

    try:
        if active_network in LOCAL_NETWORKS:
            nft = Agreement.deploy(addr(admin))
            asset = Asset.deploy(addr(admin))

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

            with open('BAYC#3769.txt', 'r') as f:
                terms = f.read()
                nft.create("BAYC#3769 Agreement", terms, chain.time() +
                           60*60*24*365*3, [creator], [asset], addr(iwan))
            nft.sign(0, [(asset, 0)], addr(creator))

        if active_network in TEST_NETWORKS:
            nft = Agreement[-1]
            with open('BAYC#3769.txt', 'r') as f:
                terms = f.read()
                nft.create("BAYC#3769 Agreement", "TERMS", chain.time() + 60*60*24*365*3, [
                           "0xAb1fdD3F84b2019BEF47939E66fb6194532f9640"], ["0x85a91119ECBe6641401A33b1418A90FEa8066d85"], addr(iwan))

        if active_network in REAL_NETWORKS:
            nft = Agreement[-1]
            with open('BAYC#3769.txt', 'r') as f:
                terms = f.read()
                nft.create("BAYC#3769 Agreement", terms, chain.time() + 60*60*24*365*3, [
                           "0x7eE5eA1f769703B755A2F7A7C76E9C00fd2aB8C7"], ["0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D"], addr(iwan))

    except Exception:
        console.print_exception()
        # Test net contract address


if __name__ == "__main__":
    main()
