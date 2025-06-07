// el ! channel - отправка в канал el
// channel ? el - получение из канала

chan chnl = [1000] of { byte };

active proctype Sender() {
    byte elemChar;

    elemChar = 34;
    do
    :: (elemChar > 122) -> break
    :: else ->
        chnl ! elemChar;
        printf("Send element: %c\n", elemChar);
        elemChar++;
    od;
}

active proctype Receiver() {
    byte elemChar;
    do
    :: chnl ? elemChar ->
        printf("Got element: %c\n", elemChar);
        if
        :: (elemChar == 'z') -> 
            break
        :: else -> skip
        fi
    od;
    assert(elemChar == 'z')
}