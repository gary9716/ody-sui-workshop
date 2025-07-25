module move2024::enum_keyworld {
    public enum Action has copy, drop, store {
        Stop,
        Pause { duration: u32 },
        MoveTo { x: u64, y: u64 },
        Jump(u64),
    }

    public struct V has copy, drop, store {
        action: Action,
    }

    public struct Abc has key {
        id: UID,
    }
}
