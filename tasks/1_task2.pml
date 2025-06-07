#define N 6

inline random(result) {
    if
    :: result = 0;
    :: result = 1;
    :: result = 2;
    :: result = 3;
    :: result = 4; 
    :: result = 5;
    fi
}

active proctype ARRAY() {
    int a[N];
    int i = 0;
    int sum = 0;
    int temp;

    do
    :: (i >= N) -> break;
    :: else -> random(temp); a[i] = temp; i++; printf("num: %d\n", temp);
    od;

    i = 0;
    do
    :: (i >= N) -> break;
    :: else ->
        if
        :: (i % 2 == 0) -> sum = sum + a[i];
        :: else -> sum = sum - a[i];
        fi;
        i++;
    od;

    printf("Result = %d\n", sum);
}
