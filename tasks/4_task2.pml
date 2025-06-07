#define N   3
#define PAD (2*N+1)

#define EMPTY   0
#define GREEN   1
#define PURPLE  2

byte pad[PAD];
bit  done  = 0;
int  moves = 0;

chan lock = [1] of { byte };

inline show_state() {
    printf("move %d:  %d %d %d %d %d %d %d\n",
           moves,
           pad[0], pad[1], pad[2], pad[3], pad[4], pad[5], pad[6])
}

inline goal_reached() {
    pad[0]==PURPLE && pad[1]==PURPLE && pad[2]==PURPLE &&
    pad[3]==EMPTY  &&
    pad[4]==GREEN  && pad[5]==GREEN  && pad[6]==GREEN
}

proctype Frog(byte idx; byte frogType)
{
    byte pos = idx;
    byte tok;

    pad[pos] = frogType;

    do
    :: done -> break

    :: lock ? tok ->
        if
        :: (pos+1 < PAD && pad[pos+1]==EMPTY) ->
            pad[pos]   = EMPTY;
            pad[pos+1] = frogType;
            pos        = pos + 1;
            moves      = moves + 1;
            show_state()

        :: (pos+2 < PAD && pad[pos+1]!=EMPTY && pad[pos+2]==EMPTY) ->
            pad[pos]   = EMPTY;
            pad[pos+2] = frogType;
            pos        = pos + 2;
            moves      = moves + 1;
            show_state()

        :: (pos > 0 && pad[pos-1]==EMPTY) ->
            pad[pos]   = EMPTY;
            pad[pos-1] = frogType;
            pos        = pos - 1;
            moves      = moves + 1;
            show_state()

        :: (pos >= 2 && pad[pos-1]!=EMPTY && pad[pos-2]==EMPTY) ->
            pad[pos]   = EMPTY;
            pad[pos-2] = frogType;
            pos        = pos - 2;
            moves      = moves + 1;
            show_state()

        :: else -> skip
        fi;

        if
        :: goal_reached() ->
            show_state();
             printf("goal reached after %d moves\n", moves);
             done = 1
        :: else -> skip
        fi;

        lock ! tok
    od
}

init {
    byte tok = 1;

    atomic {
        pad[0]=GREEN; pad[1]=GREEN; pad[2]=GREEN;
        pad[3]=EMPTY;
        pad[4]=PURPLE; pad[5]=PURPLE; pad[6]=PURPLE;

        lock ! tok;

        run Frog(0, GREEN);
        run Frog(1, GREEN);
        run Frog(2, GREEN);

        run Frog(4, PURPLE);
        run Frog(5, PURPLE);
        run Frog(6, PURPLE);
    }
}

ltl p1 { [] (!done) }

// spin 4_task2.pml
// spin -search -bfs -ltl p1 4_task2.pml
// spin -t -p 4_task2.pml
// spin -t 4_task2.pml