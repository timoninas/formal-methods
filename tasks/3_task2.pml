int sum = 0;

inline pick(v) {
    if
    :: v = 1;
    :: v = 2;
    :: v = 3;
    fi
}

active proctype Oscillator()
{
    int v;
    do
    :: pick(v);
       if
       :: sum > 0 -> sum = sum - v;
       :: else -> sum = sum + v;
       fi
    od
}

// ltl
 
// false
ltl p1 { []<> (sum == 0) }

// true
ltl p2 { [] ( (sum >= -3) && (sum <= 3) ) }

// false
ltl p3 { [] ( ((sum > 0) -> <> (sum <= 0)) && ((sum < 0) -> <> (sum >= 0)) ) }

