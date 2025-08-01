module generics::generics ;

public struct Box<T> {
    value: T
}

public fun input1(value: u64) {}

public fun input <T: drop + copy> (value: T) {}


public fun create_box <T> (value: T): Box<T> {
    Box<T> { value }
}


/// this function will fail with undroppable object
// fun init(ctx: &mut TxContext) {
//     let box32 = create_box(32u32);
//
//     let box16 = create_box<u16>((32u32 as u16));
// }
