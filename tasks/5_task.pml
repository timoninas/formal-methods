chan LIGHT1 = [1] of { byte };
chan LIGHT2 = [1] of { byte };
chan LIGHT3 = [1] of { byte };
chan LIGHT4 = [1] of { byte };
chan LIGHT5 = [1] of { byte };
chan LIGHT6 = [1] of { byte };

byte PRIORITY_VALUE = 10;
byte MINOR_PRIORITY_VALUE = 5;

byte  n = 6;
byte  currentTurn  = 1; 
byte  queue[6]     = {0, 0, 0, 0, 0, 0};
short requests[7]  = {0, 0, 0, 0, 0, 0, 0, 0};
bool  statuses[6]  = {false, false, false, false, false, false};

proctype RunTrafficLight(
        byte currCarNumber,
        nextTurnNum,
        matrixConflictValue1,
        matrixConflictValue2,
        matrixConflictValue3,
        matrixConflictValue4;
        chan currLIGHT)
{
    /* конфликтные значения для текущего автомобиля */
    short conflictValue1 = 0;
    short conflictValue2 = 0;
    short conflictValue3 = 0;
    short conflictValue4 = 0;

    /* количество машин в очереди */
    short currCarRequestsNumber = 0;
    byte  carsInQueue   = 0;

    do
    :: currentTurn == currCarNumber ->
        /*  число машин, желающих проехать  */
        currLIGHT ? carsInQueue;
        requests[0] = 0;
        queue[currCarNumber - 1] = carsInQueue;

        if
        :: statuses[currCarNumber-1] ->
              requests[currCarNumber] = 0;
              statuses[currCarNumber-1] = false;
        :: else -> skip
        fi;

        if
        :: requests[currCarNumber] > 0 -> 
              /* конкурентов нет -> зелёный */
              if
              :: (requests[matrixConflictValue1] == 0) &&
                 (requests[matrixConflictValue2] == 0) &&
                 (requests[matrixConflictValue3] == 0) && 
                 (requests[matrixConflictValue4] == 0) ->
                     statuses[currCarNumber - 1] = true;
                     queue[currCarNumber - 1] = 0;
                     currentTurn = nextTurnNum
              :: else ->
                     /* вычисляем ключи конкурентов обычным if-ом */
                     conflictValue1 = 0;
                     if
                     :: requests[matrixConflictValue1] > 0 -> conflictValue1 = requests[matrixConflictValue1]
                     :: else -> skip
                     fi;

                     conflictValue2 = 0;
                     if
                     :: requests[matrixConflictValue2] > 0 -> conflictValue2 = requests[matrixConflictValue2]
                     :: else -> skip
                     fi;

                     conflictValue3 = 0;
                     if
                     :: requests[matrixConflictValue3] > 0 -> conflictValue3 = requests[matrixConflictValue3]
                     :: else -> skip
                     fi;

                     conflictValue4 = 0;
                     if
                     :: requests[matrixConflictValue4] > 0 -> conflictValue4 = requests[matrixConflictValue4]
                     :: else -> skip
                     fi;

                     currCarRequestsNumber = requests[currCarNumber];

                     if
                     :: (conflictValue1 > currCarRequestsNumber) ||
                        (conflictValue2 > currCarRequestsNumber) ||
                        (conflictValue3 > currCarRequestsNumber) ||
                        (conflictValue4 > currCarRequestsNumber) ->
                            requests[currCarNumber]  = currCarRequestsNumber + MINOR_PRIORITY_VALUE;
                            requests[matrixConflictValue1] = requests[matrixConflictValue1] + MINOR_PRIORITY_VALUE;
                            requests[matrixConflictValue2] = requests[matrixConflictValue2] + MINOR_PRIORITY_VALUE;
                            requests[matrixConflictValue3] = requests[matrixConflictValue3] + MINOR_PRIORITY_VALUE;
                            requests[matrixConflictValue4] = requests[matrixConflictValue4] + MINOR_PRIORITY_VALUE;
                     :: else ->
                            statuses[currCarNumber - 1] = true;
                            queue[currCarNumber - 1] = 0;
                            requests[currCarNumber] = currCarRequestsNumber + PRIORITY_VALUE;
                     fi;

                     currentTurn = nextTurnNum;
                     requests[0] = 0
              fi
        /* Если заявки ещё не было, но машины есть -> ставим заявку */
        :: else ->
              if
              :: queue[currCarNumber - 1] > 0 ->
                     requests[currCarNumber] = currCarNumber
              :: else -> skip
              fi;
              currentTurn = nextTurnNum
        fi
    od
}

proctype GenerateLights(){
    do
    :: LIGHT1!1 :: LIGHT2!1 :: LIGHT3!1 :: LIGHT4!1 :: LIGHT5!1 :: LIGHT6!1
    od
}

init {
    atomic {
        run RunTrafficLight(1, 2, 3, 4, 5, 6, LIGHT1); /* W->E  */
        run RunTrafficLight(2, 3, 3, 4, 5, 6, LIGHT2); /* E->W  */
        run RunTrafficLight(3, 4, 1, 2, 6, 0, LIGHT3); /* S->N  */
        run RunTrafficLight(4, 5, 1, 2, 6, 0, LIGHT4); /* Ped  */
        run RunTrafficLight(5, 6, 1, 6, 0, 0, LIGHT5); /* S->W  */
        run RunTrafficLight(6, 1, 1, 3, 5, 4, LIGHT6); /* E->S  */

        run GenerateLights()
    }
}

// safety

ltl safe_13 { [](!(statuses[0] && statuses[2])) } /* WE ∩ SN  */
ltl safe_14 { [](!(statuses[0] && statuses[3])) } /* WE ∩ PED */
ltl safe_15 { [](!(statuses[0] && statuses[4])) } /* WE ∩ SW  */
ltl safe_16 { [](!(statuses[0] && statuses[5])) } /* WE ∩ ES  */

ltl safe_23 { [](!(statuses[1] && statuses[2])) } /* EW ∩ SN  */
ltl safe_24 { [](!(statuses[1] && statuses[3])) } /* EW ∩ PED */
ltl safe_25 { [](!(statuses[1] && statuses[4])) } /* EW ∩ SW  */
ltl safe_26 { [](!(statuses[1] && statuses[5])) } /* EW ∩ ES  */

ltl safe_36 { [](!(statuses[2] && statuses[5])) } /* SN ∩ ES  */
ltl safe_46 { [](!(statuses[3] && statuses[5])) } /* PED ∩ ES  */
ltl safe_56 { [](!(statuses[4] && statuses[5])) } /* SW ∩ ES  */

// liveness

ltl live_1  { []((queue[0]>0 && !statuses[0]) -> (<>statuses[0])) } /* WE  */
ltl live_2  { []((queue[1]>0 && !statuses[1]) -> (<>statuses[1])) } /* EW  */
ltl live_3  { []((queue[2]>0 && !statuses[2]) -> (<>statuses[2])) } /* SN  */
ltl live_4  { []((queue[3]>0 && !statuses[3]) -> (<>statuses[3])) } /* PED */
ltl live_5  { []((queue[4]>0 && !statuses[4]) -> (<>statuses[4])) } /* SW  */
ltl live_6  { []((queue[5]>0 && !statuses[5]) -> (<>statuses[5])) } /* ES  */

// fariness

ltl fair_1  { []<>(!statuses[0]) } /* WE  */
ltl fair_2  { []<>(!statuses[1]) } /* EW  */
ltl fair_3  { []<>(!statuses[2]) } /* SN  */
ltl fair_4  { []<>(!statuses[3]) } /* PED */
ltl fair_5  { []<>(!statuses[4]) } /* SW  */
ltl fair_6  { []<>(!statuses[5]) } /* ES  */


// spin 5_task.pml
// spin -search -a -ltl safe_13 5_task.pml
// spin -search -bfs -ltl safe_16 5_task.pml
// spin -search -bfs -ltl live_1 5_task.pml
// spin -search -bfs -ltl fair_1 5_task.pml
// spin -t 5_task.pml

// spin -search -a -ltl safe_25 5_task.pml
// spin -search -a -ltl fair_1 5_task.pml
// spin -search -a -ltl live_1 5_task.pml
