#define N 5

bit pillar[N]     = { 0, 1, 0, 1, 1 };
// bit pillar[N]     = { 1, 0, 1, 0, 1 };
bit gate_opened   = 0;

chan cmd[N]  = [0] of { bit };
chan done    = [0] of { bit };

active [N] proctype ControlPillar ()
{
    bit dummy;
    do
    :: gate_opened -> break;
    :: cmd[_pid] ? dummy ->
        printf("FROM %d %d %d %d %d\n", pillar[0], pillar[1], pillar[2], pillar[3], pillar[4]);
        pillar[_pid]                = 1 - pillar[_pid];
        pillar[(_pid + 1) % N]      = 1 - pillar[(_pid + 1) % N];
        pillar[(_pid + N - 1) % N]  = 1 - pillar[(_pid + N - 1) % N];
        printf("TO %d %d %d %d %d\n", pillar[0], pillar[1], pillar[2], pillar[3], pillar[4]);
        done ! 1;
    od;
}

active proctype Commander ()
{
    byte target;
    int  i;
    int  sum;

    do
    :: gate_opened -> break;
    :: else ->
        select(target : 0 .. 4);
        cmd[target] ! 1;
        done ? 1;

        sum = 0;
        i   = 0;
        do
        :: i >= N -> break;
        :: else ->
            sum = sum + pillar[i];
            i++;
        od;

        if
        :: sum == N -> gate_opened = 1; printf("OPENED %d %d %d %d %d\n", pillar[0], pillar[1], pillar[2], pillar[3], pillar[4]);
        :: else -> skip;
        fi;
    od;
}

ltl p1 { [] !gate_opened }