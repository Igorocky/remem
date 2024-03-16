let randSelect: array<('a,int)> => 'a

let randText: (
    ~minLen:int,
    ~maxLen:int,
    ~letterProb:int=?,
    ~digitProb:int=?,
    ~spaceProb:int=?,
) => string