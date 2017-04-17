module Master

export Instance_utils, Life, Startup_utils, Types

include("types.jl")
using Master.Types

include("instance_utils.jl")
using Master.Instance_info

include("startup_utils.jl")
using Master.Startup_utils

include("life.jl")
using Master.Life

end # module
