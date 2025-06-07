// [] globally / always
// <> finally / eventually
// ! not
// X next
// -> следствие

// el ! channel - отправка в канал el
// channel ? el - получение из канала

// spin 3_task1.pml
// spin -search -a -ltl p3 3_task1.pml

#define NMONKEYS 26
#define LEN      13

chan global = [0] of { byte }

// tobeornottobe
// tobeornot obetobe
byte quote[LEN] = {
        't','o','b','e','o','r','n','o','t','t','o','b','e'
};

byte matched = 0

active [NMONKEYS] proctype Monkey ( )
{
    byte mychar = 'a' + _pid;
   
    do
    :: matched -> break
    :: global ! mychar
    od
}

active proctype Reviewer ( )
{
    byte idx = 0;
    byte ch;

    do
    :: matched -> break
    :: global ? ch ->
        if
        :: ch == quote[idx] ->
               idx++;
               if
               :: idx == LEN ->
                        matched = 1
               :: else -> skip
               fi
        :: else ->
            if
               :: ch == quote[0] -> idx = 1;  printf("My char is %c.\n", ch);
               :: else -> idx = 0
            fi
        fi
    od
}

ltl p1 { [] (!matched) }
