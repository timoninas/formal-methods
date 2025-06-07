init {
    int a = 11; 
    int b = 10; 
    int c = 5;

    if
    :: (a < b) -> printf("good\n");
    :: else -> skip;
    fi;

    if
    :: (a < b) -> printf("good\n");
    :: else -> printf("bad\n");
    fi;

    if
    :: (b > c) -> a = b;
    :: else -> a = c;
    fi;

    do
    :: (a < b) -> break;
    :: else -> a++;
    od;

    int i = 0;
    do
    :: (i < 100) ->
        printf("i = %d\n", i);
        i++;
    :: else -> break;
    od;
}
