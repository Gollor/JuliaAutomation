module Instance_utils

export check_status, get_log!, call!, update_logs!

include("../instance/monitoring.jl")

using Master.Types

function check_status(instance::Instance_info)
    userhost = instance.userhost
    password = instance.password
    infostr = "$userhost"
    output = readstring(
        open(pipeline(
        `sshpass -p $password ssh $userhost "nvidia-smi"`, `cat`))[1])
    for line in split(output, "\n")
        if contains(line, "%")
            infostr = string(infostr, " | ",
                             split(line)[2], " ",
                             split(line)[3])
            if parse(Int, split(line)[13][1:end-1]) > 5
                infostr = string(infostr, "  ON")
            else
                infostr = string(infostr, " OFF")
            end
        end
    end
    println(infostr)
end

function get_log!(call::Call_info)::Call_info
    (text, state) = remotecall_fetch(
            update_logs, # function
            call.process_id, # process
            call.log_pos, string("logs", call.task.id, ".txt")) # args
    call.log_pos = state
    write(call.log_file, text)
    flush(call.log_file)
    return call
end

function call!(calls::Array{Call_info,1},
               task::Requested_task,
               instance::Instance_info)
    instance.status = "BUSY"
    gpu_id = instance.gpu_id
    args = split(task.command)
    for i in length(args)
        if args[i] == "\$gpu"
            args[i] = "/gpu:$(instance.gpu_id)"
        end
    end
    command = `$args`
    moment = now()
    process = remotecall_fetch(run_task, instance.process_id, command)
    call = Call_info(true,
                     instance.process_id,
                     task,
                     process,
                     open("log$(task.id).txt", "w"),
                     0,
                     moment,
                     moment,
                     instance)
    push!(calls, call)
end

function update_logs!(calls::Array{Call_info,1})
    for call in calls
        pos_before = calls.log_pos
        if call.active == true
            get_log!(call)
        end
        pos_after = calls.log_pos
        if pos_after > pos_before
            call.log_last_update = now()
        end
    end
end

end # module
