// spin -search -a -ltl p2 2_task2.pml


// [] globally / always
// <> finally / eventually
// ! not
// X next
// -> следствие

byte x;

active proctype A() {
    printf("x = 0\n");
    x = 1;    printf("x=%d\n", x);
    do
    :: select(x : 0 .. 10);printf("x=%d\n", x);
    od
}


ltl p1 { x == 0 } // OK
ltl p2 { x != 0 } // NOT OK
ltl p3 { (x == 0) -> X (x != 0) } // OK
ltl p4 { (x == 0) -> <> (x != 0) }  // OK
ltl p5 { [] ((x == 0) -> X (x != 0)) } // NOT OK
ltl p6 { [] ((x == 0) -> <> (x != 0)) } // NOT OK

