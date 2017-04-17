include("src/master/master.jl")

using Master

function life()
    life_iteration = Life.construct_life_iteration(3, 12, 480)
    while length(Life.query) > 0 ||
            length(filter((call) -> call.active, Life.calls)) > 0
        life_iteration()
        sleep(120.000)
    end
end

life()
