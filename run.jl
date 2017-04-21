include("src/instance/instance.jl")
include("src/master/master.jl")
include("src/web/web.jl")

# using Instance
using Web
using Master

Backend.App.start_app()

Life.init_life()

life_iteration = Life.construct_life_iteration(10, 180, 300)
autoclose = false

while length(Life.query) > 0 ||
        length(filter((call) -> call.active, Life.calls)) > 0 ||
        !autoclose # With autoclose disabled the program will run even after
        # finishing all tasks.
    life_iteration()
    sleep(300.000)
end
