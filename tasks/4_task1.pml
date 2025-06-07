#define K        11
#define NOTFOUND 0
#define FOUND    1

byte pos    = 0;
byte search = 5;
byte old = 0;
bit  done   = NOTFOUND;

proctype TargetMover ()
{
    do
    :: done -> break
    :: else ->
        if
        :: old = pos; pos = (pos + 1) % K; printf("MOVER: pos + 1 | old=%d -> newPos=%d \n", old, pos);
        :: pos = (pos + K - 1) % K; printf("MOVER: pos + K - 1 | old=%d -> newPos=%d \n", old, pos);
        :: printf("MOVER: Not moved | pos=%d \n", pos);  
        fi
    od
}

proctype Searcher ()
{
    do
    :: done -> break
    :: search == pos ->
        done = FOUND;
        printf("Found at %d\n", search)
    :: else ->
        search = (search + 1) % K
        printf("SEEKER: seek at idx=%d\n", search)
    od
}

inline random(r) {
    if
    :: r = 0;
    :: r = 1;
    :: r = 2;
    :: r = 3;
    :: r = 4;
    :: r = 5;
    :: r = 6;
    :: r = 7;
    :: r = 8;
    :: r = 9;
    :: r = 10;
    fi
}

init {
    random(pos);
    printf("Random idx at %d\n", pos);
    run TargetMover();
    run Searcher();
}

// spin 4_task1.pml
// spin -search -a -ltl p1 4_task1.pml
// spin -t 4_task1.pml

ltl p1 { <>(done==FOUND) }