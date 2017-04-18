include("src/instance/instance.jl")
include("src/master/master.jl")
include("src/web/web.jl")

# using Instance
using Web
using Master

Backend.App.start_app()

Life.init_life()

life_iteration = Life.construct_life_iteration(3, 12, 480)

while length(Life.query) > 0 ||
        length(filter((call) -> call.active, Life.calls)) > 0
    life_iteration()
    sleep(120.000)
end
