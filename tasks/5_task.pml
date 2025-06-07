chan TL1 = [1] of { byte };
chan TL2 = [1] of { byte };
chan TL3 = [1] of { byte };
chan TL4 = [1] of { byte };
chan TL5 = [1] of { byte };
chan TL6 = [1] of { byte };

byte  n = 6;                       /* прирост «ключа»            */
byte  currentTurn = 1;             /* чей ход                    */
byte  queue[6]     = {0,0,0,0,0,0};/* ожидание    */
short requests[7] = {0,0,0,0,0,0,0,0};/* заявки      */
bool  statuses[6] = {false,false,false,false,false,false};

proctype TrafficLight(
        byte number,
        nextNum,
        fProblem,
        sProblem,
        tProblem,
        kProblem;
        chan tlChan)
{
    short fValue = 0;
    short sValue = 0;
    short tValue = 0;
    short nValue = 0;
    short kValue = 0;
    byte  aps   = 0;

    do
    :: currentTurn == number ->
        /*  число машин, желающих проехать  */
        tlChan ? aps;
        requests[0]      = 0;
        queue[number-1]  = aps;

        if
        :: statuses[number-1] ->
              requests[number] = 0;
              statuses[number-1] = false;
        :: else -> skip
        fi;

        if
        :: requests[number] > 0 ->
              /* 2 конкурентов нет -> зелёный */
              if
              :: (requests[fProblem] == 0) &&
                 (requests[sProblem] == 0) &&
                 (requests[tProblem] == 0) && 
                 (requests[kProblem] == 0) ->
                     statuses[number-1] = true;
                     queue[number-1]    = 0;
                     currentTurn        = nextNum
              :: else ->
                     /* вычисляем ключи конкурентов обычным if-ом */
                     fValue = 0;
                     if
                     :: requests[fProblem] > 0 -> fValue = requests[fProblem]
                     :: else -> skip
                     fi;

                     sValue = 0;
                     if
                     :: requests[sProblem] > 0 -> sValue = requests[sProblem]
                     :: else -> skip
                     fi;

                     tValue = 0;
                     if
                     :: requests[tProblem] > 0 -> tValue = requests[tProblem]
                     :: else -> skip
                     fi;

                     kValue = 0;
                     if
                     :: requests[kProblem] > 0 -> kValue = requests[kProblem]
                     :: else -> skip
                     fi;

                     nValue = requests[number];

                     if
                     :: (fValue > nValue) ||
                        (sValue > nValue) ||
                        (tValue > nValue) ||
                        (kValue > nValue) ->
                            requests[number]  = nValue + n;
                            requests[fProblem] = requests[fProblem] + n;
                            requests[sProblem] = requests[sProblem] + n;
                            requests[tProblem] = requests[tProblem] + n;
                            requests[kProblem] = requests[kProblem] + n
                     :: else ->
                            statuses[number-1] = true;
                            queue[number-1]    = 0;
                            requests[number]   = requests[number] + number
                     fi;

                     currentTurn = nextNum;
                     requests[0] = 0
              fi
        /* Если заявки ещё не было, но машины есть -> ставим заявку */
        :: else ->
              if
              :: queue[number-1] > 0 ->
                     requests[number] = number
              :: else -> skip
              fi;
              currentTurn = nextNum
        fi
    od
}

proctype TrafficGenerator(){
    do
    :: TL1!1 :: TL2!1 :: TL3!1 :: TL4!1 :: TL5!1 :: TL6!1
    od
}

init {
    atomic {
        run TrafficLight(1, 2, 4, 3, 5, 6, TL1); /* W->E  */
        run TrafficLight(2, 3, 4, 3, 5, 6, TL2); /* E->W  */
        run TrafficLight(3, 4, 6, 1, 2, 6, TL3); /* S->N  */
        run TrafficLight(4, 5, 1, 2, 6, 0, TL4); /* Ped  */
        run TrafficLight(5, 6, 6, 1, 0, 0, TL5); /* S->W  */
        run TrafficLight(6, 1, 3, 5, 1, 0, TL6); /* E->S  */

        run TrafficGenerator()
    }
}

ltl s1 { [](!(statuses[0] && statuses[1])) } /* W->E vs E->W      */
ltl s2 { [](!(statuses[0] && statuses[2])) } /* W->E vs S->N      */
ltl s3 { [](!(statuses[5] && statuses[2])) } /* E->S vs S->N      */
ltl s4 { [](!(statuses[4] && statuses[2])) } /* S->W vs S->N      */
ltl s5 { [](!(statuses[1] && statuses[3])) } /* E->W vs Ped      */
ltl s6 { [](!(statuses[3] && statuses[4])) } /* Ped  vs S->W     */
ltl s7 { [](!(statuses[3] && statuses[5])) } /* Ped  vs E->S     */
ltl s8 { [](!(statuses[4] && statuses[3] && statuses[5])) } /* ped vs S->N vs S->W */
ltl safe_13 { [](!(statuses[0] && statuses[2])) }
ltl safe_16 { [](!(statuses[0] && statuses[5])) }
ltl safe_234 { [](!(statuses[1] && statuses[0] && statuses[3] && statuses[2])) }

ltl l1 { []( (queue[0]==1 && !statuses[0]) -> (<>statuses[0]) ) }
ltl l2 { []( (queue[1]==1 && !statuses[1]) -> (<>statuses[1]) ) }
ltl l3 { []( (queue[2]==1 && !statuses[2]) -> (<>statuses[2]) ) }
ltl l4 { []( (queue[3]==1 && !statuses[3]) -> (<>statuses[3]) ) }
ltl l5 { []( (queue[4]==1 && !statuses[4]) -> (<>statuses[4]) ) }
ltl l6 { []( (queue[5]==1 && !statuses[5]) -> (<>statuses[5]) ) }

ltl f1 { [](<>(!statuses[0])) }
ltl f2 { [](<>(!statuses[1])) }
ltl f3 { [](<>(!statuses[2])) }
ltl f4 { [](<>(!statuses[3])) }
ltl f5 { [](<>(!statuses[4])) }
ltl f6 { [](<>(!statuses[5])) }


// spin 5_task.pml
// spin -search -a -ltl safe_13 5_task.pml
// spin -search -bfs -ltl safe_16 5_task.pml
// spin -t 5_task.pml