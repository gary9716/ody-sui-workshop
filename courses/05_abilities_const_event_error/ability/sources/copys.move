module ability::copys ;
use std::ascii::String;


public struct A has copy{
}


public  struct B has copy{
    a:u64,
    b:u64,
}


// this function will fail due to undroppable object struct
// fun a(a:UID){

    // u8 - u256   bool    address



// }
