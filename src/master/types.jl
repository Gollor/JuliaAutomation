module Types

export Process_info, Instance_info, Call_info, Requested_task, Completed_task

type Process_info
    userhost::AbstractString
    process_id::Integer
end

type Instance_info
    userhost::AbstractString
    password::AbstractString
    process_id::Integer
    gpu_id::Integer
    error_counter::Integer
    status::AbstractString # "OK" "BUSY" "ERROR"
end

type Requested_task
    id::Integer
    command::AbstractString
end

type Completed_task
    task::Requested_task
    instance::Instance_info
end

type Call_info
    active::Bool
    process_id::Integer
    task::Requested_task
    process::Base.Process
    log_file::IOStream
    log_pos::Integer
    log_start::DateTime
    log_last_update::DateTime
    instance::Instance_info
end

Instance_info(userhost, password, gpu_id) =
        Instance_info(userhost, password, 1, gpu_id, 0, "OK")
Instance_info(userhost, password) =
        Instance_info(userhost, password, 1, 0, 0, "OK")

end # module
