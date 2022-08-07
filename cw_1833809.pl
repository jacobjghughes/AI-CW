% Accomplish a given Task and return the Cost
% tasks: go(?Pos) or find(?Obj)
solve_task(Task,Cost) :-
    validate_task(Task),!,

    my_agent(A), get_agent_position(A,P), get_agent_energy(A, Energy),
    solve_task_astar(Task,[_:P:[]],[],[P|Path]), !,
    (
        length(Path,ThisLeg), 
        % if we have enough energy then proceed to the target
        Energy>=ThisLeg, 
        agent_do_moves(A,Path),
        Cost is ThisLeg
        ; 
        
        % if cost is too high then we need to look for the nearest charge station
        Task \= find(c(_)),
        solve_task(find(c(Station)), ChargeCost),
        agent_topup_energy(A, c(Station)),
        get_agent_position(A, ChargePos),
        % now we have charged we can try again at the original task
        solve_task_astar(Task, [_:ChargePos:[]], [], [ChargePos|ChargePath]),
        !, 
        get_agent_energy(A, ChargedEnergy),
        length(ChargePath, ChargeLeg),
        ChargedEnergy>=ChargeLeg,
        agent_do_moves(A, ChargePath),
        Cost is ChargeLeg + ChargeCost
    ).

validate_task(Task) :-
%if task is go to space and the space is not empty then we cannot go and it fails
   Task=go(Pos), lookup_pos(Pos, Obj), Obj = empty;
   Task=find(_).

% solve(+Task, +score:currentposition:reversepath | rest of queue, +[visited], path taken)
solve_task_astar(Task, [_:Pos:RPath | Queue], Visited, Path) :-
    achieved(Task, Pos), reverse([Pos|RPath], Path);

    findall(Score:NewPos:[Pos|RPath], (
        map_adjacent(Pos, NewPos, empty),
        \+ member(NewPos, Visited),
        \+ member(_:NewPos:_, Queue),
        score(Task, Score:NewPos:[Pos|RPath])
    ), Children),
    
    append(Queue, Children, UnsortedQueue),
    % sort queue by lowest score and recurse with new queue
    sort(1, @=<, UnsortedQueue, NewQueue),
    solve_task_astar(Task, NewQueue, [Pos|Visited], Path).

score(Task, Score:Pos:RPath) :-
    Task = find(_), length(RPath, PathLength), Score is PathLength
    ;
    Task = go(Goal), map_distance(Goal, Pos, Dist), length(RPath, PathLength), Score is Dist + PathLength. 

% True if the Task is achieved with the agent at Pos
achieved(Task,Pos) :- 
    Task=find(Obj), map_adjacent(Pos,_,Obj)
    ;
    Task=go(Pos).