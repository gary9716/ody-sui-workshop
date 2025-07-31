module lesson_one::lesson_one {
    use std::ascii::{Self, String};
    use sui::{clock::Clock, package};

    // === Imports ===

    // === Errors ===
    const EIsOwner: u64 = 100;
    const ENotUpgradeable: u64 = 101;

    // === Constants ===

    // === Structs ===
    public struct LESSON_ONE has drop {}
    public struct Tutor has key {
        id: UID,
    }

    public struct Member has key {
        id: UID,
        name: String,
        img_url: String,
    }

    public struct Rookie has key, store {
        id: UID,
        creator: address,
        name: String,
        img_url: String,
        signer: Option<address>,
    }
    // === Events ===
    public struct MemberRegisterEvent has copy, drop {
        member_id: ID,
        name: String,
        img_url: String,
        timestamp: u64,
    }

    // === Method Aliases ===

    // === Public Functions ===

    #[allow(lint(self_transfer))]
    public fun new_member(name: String, ctx: &mut TxContext) {
        transfer::public_transfer(
            Rookie {
                id: object::new(ctx),
                creator: ctx.sender(),
                name,
                img_url: ascii::string(b""),
                signer: option::none(),
            },
            ctx.sender(),
        )
    }

    public fun update_name(rookie: &mut Rookie, name: String) {
        rookie.name = name;
    }

    public fun update_img_url(rookie: &mut Rookie, img_url: String) {
        rookie.img_url = img_url;
    }

    public fun update_with_different_signer(rookie: &mut Rookie, ctx: &TxContext) {
        assert!(rookie.creator != ctx.sender(), EIsOwner);
        rookie.signer = option::some(ctx.sender());
    }

    public fun upgrade(rookie: Rookie, clock: &Clock, ctx: &mut TxContext) {
        let Rookie {
            id,
            creator,
            name,
            img_url,
            signer,
        } = rookie;

        object::delete(id);

        assert!(
            signer.is_some() && ctx.sender() == creator && !img_url.is_empty() && !name.is_empty(),
            ENotUpgradeable,
        );

        let id = object::new(ctx);
        sui::event::emit(MemberRegisterEvent {
            member_id: id.to_inner(),
            name,
            img_url,
            timestamp: clock.timestamp_ms(),
        });
        transfer::transfer(
            Member {
                id,
                name,
                img_url,
            },
            ctx.sender(),
        );
    }

    // === View Functions ===

    // === Admin Functions ===
    fun init(otw: LESSON_ONE, ctx: &mut TxContext) {
        package::claim_and_keep(otw, ctx);
    }

    // === Package Functions ===

    // === Private Functions ===

    // === Test Functions ===
}
