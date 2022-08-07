% True if link L appears on A's wikipedia page
actor_has_link(L,A) :- 
    actor(A), wp(A,WT), wt_link(WT,L).

% Attempt to solve by visiting each oracle in ID order
eliminate(Actors,Actor, VisitedOracles) :- 
    Actors=[Actor], !
    ;
    my_agent(Agent),  
    get_agent_energy(Agent, AgentEnergy), 
    ailp_grid_size(GridSize),
    get_agent_position(Agent, Pos),
    EnergyMax is GridSize * GridSize / 4,
    EnergyAsk is GridSize / 10,
    
    %find nearest oracle not visited
    solve_task_astar(find(o(NextOracle)), [_:Pos:[]], [], [Pos|Path]),
    \+ member(NextOracle, VisitedOracles),
    \+ agent_check_oracle(Agent, o(NextOracle)), 
    !,
    (
        % if agent energy after the task is above the threshold of 25% max energy then we can proceed 
        % 25% seems to work well from testing random maps
        length(Path, PathCost),
        (AgentEnergy - PathCost - EnergyAsk) >= EnergyMax*0.25,

        agent_do_moves(Agent, Path),
        agent_ask_oracle(Agent, o(NextOracle), link, Ans),
        NewVisited = [NextOracle | VisitedOracles], 
        include(actor_has_link(Ans), Actors, ViableAs),
        eliminate(ViableAs, Actor, NewVisited)
        ;

        % if our energy would go below the threshold, find and navigate to the nearest charger 
        % then search for the nearest oracle from the new position and proceed
        % if we cannot find a valid oracle now then we cannot proceed and the actor remains unknown
        solve_task(find(c(Charger)),_),
        agent_topup_energy(Agent, c(Charger)),
        get_agent_position(Agent, NewPos),
        solve_task_astar(find(o(NewNextOracle)), [_:NewPos:[]], [], [NewPos|NewPath]),
        \+ member(NewNextOracle, VisitedOracles),
        \+ agent_check_oracle(Agent, o(NewNextOracle)),
        !,
        agent_do_moves(Agent,NewPath),
        agent_ask_oracle(Agent, o(NewNextOracle), link, Ans),
        NewVisited = [NewNextOracle | VisitedOracles], 
        include(actor_has_link(Ans), Actors, ViableAs),
        eliminate(ViableAs, Actor, NewVisited)
    );
    % if we fail to find an available oracle then the task fails and the actor is unknown
    Actor = unknown
    .
        
% Deduce the identity of the secret actor A
find_identity(A) :- 
    findall(A,actor(A),As), eliminate(As,A,[])
    ;
    A = unknown.