module Life

export calls, query, completed, instances, processes
export init_life, construct_life_iteration

using Instance.Monitoring
using Master.Types
using Master.Startup_utils
using Master.Instance_utils

calls = Array{Call_info,1}() # All remote functions calls
query = Array{Requested_task,1}() # All requests to run
completed = Array{Completed_task,1}() # All completed requests
instances = Array{Instance_info,1}() # All available machines
processes = Array{Process_info,1}() # All running processes.
# The same machine will share the one process for all gpu instances.
process_table = Dict() # The table that maps hosts to process identifiers.
# The table that maps hosts to process identifiers.

function init_life()
    global query, instances, process_table
    query = read_tasks_list("tasks.csv")
    instances = read_instance_list("instances.csv")
    process_table = connect_machines!(processes, instances)
end

function connect_machines!(processes::Array{Process_info,1},
                           instances::Array{Instance_info,1},
                           remote_pwd::AbstractString="~/julia_temp",
                           remote_exe::AbstractString="~/julia/bin/julia")::Dict
    process_table = Dict()
    for instance in instances
        if (instance.userhost in keys(process_table)) == false
            proc = addprocs([instance.userhost],
                            tunnel=true,
                            dir=remote_pwd,
                            exename=remote_exe,
                            topology=:master_slave)
            push!(processes, Process_info(instance.userhost, proc[1]))
            process_table[instance.userhost] = proc[1]
        end
        instance.process_id = process_table[instance.userhost]
    end
    return process_table
end


function construct_life_iteration(instance_error_limit,
                                  logs_update_timeout_minutes,
                                  process_runtime_minutes)::Function
    iteration = 1
    logs_update_timeout = logs_update_timeout_minutes * 60 * 1000
    process_runtime = process_runtime_minutes * 60 * 1000 # from minutes to ms
    function life_iteration()
        for instance in instances
            if instance.status == "OK"
                try
                    # gpu_state = remotecall_fetch(get_gpu_state,
                    #         instance.process_id, instance.gpu_id)
                    gpu_state = 1
                    if gpu_state == 1 && length(query) > 0
                        request = pop!(query)
                        call!(calls, request, instance)
                        instance.status = "BUSY"
                    else
                        # It indicates it is occupied by the other program.
                        uh = instance.userhost
                        warn("Instance $(uh) is occupied by unknown force.")
                        instance.error_counter += 1
                        instance.status = "OK"
                    end
                catch e
                    userhost = instance.userhost
                    warn("Failed to check the state of instance $(userhost).")
                    println(e)
                    instance.error_counter += 1
                    instance.status = "OK"
                    if instance.error_counter >= instance_error_limit
                        instance.status = "ERROR"
                    end
                end
            end
        end
        for call in calls
            if call.active == true
                try
                    pos_before = call.log_pos
                    get_log!(call)
                    pos_after = call.log_pos
                    if pos_after > pos_before
                        call.log_last_update = now()
                    end
                    if (now() - call.log_start).value > process_runtime
                        info("Call runtime reached the time limit:")
                        error("Call runtime reached the time limit.")
                    end
                    if (now() - call.log_last_update).value >logs_update_timeout
                        info("Call failed to update the logs in time:")
                        error("Call failed to update the logs in time.")
                    end
                    if call.process.termsignal >= 0
                        info("Call exited:")
                        error("Call exited.")
                    end
                    try
                        logfile = open(string(split(
                            split(string(call.log_file), ' ')[2], '>')[1]))
                        log_is_fine = startswith(readlines(logfile)[end],
                                                 "Training finished.")
                        if log_is_fine
                            info("Logs showed that the call was finished:")
                            error("Logs showed that the call was finished:")
                        end
                    catch e
                        print("Failed to check logs at runtime.")
                        print(e)
                    end
                catch e
                    println(e)
                    call.active = false
                    log_is_fine = false
                    try
                        logfile = open(string(split(
                                split(string(call.log_file), ' ')[2], '>')[1]))
                        log_is_fine = startswith(readlines(logfile)[end],
                                                 "Training finished.")
                    catch e
                        println(e)
                        log_is_fine = false
                    end
                    timeout_is_fine =
                            (now() - call.log_start).value > process_runtime
                    if log_is_fine || timeout_is_fine
                        info("The call $(call.task.id) succeed.")
                        push!(completed,
                              Completed_task(call.task, call.instance))
                    else
                        push!(query, call.task)
                        info("The call $(call.task.id) failed.")
                        userhost = call.instance.userhost
                        info("The error counter of instance $(userhost)." *
                             "incremented due to call fail.")
                        call.instance.error_counter += 1
                    end
                    kill_python3(call.instance)
                    kill_python3(call.instance)
                    call.instance.status = "OK"
                    if call.instance.error_counter >= instance_error_limit
                        call.instance.status = "ERROR"
                    end
                end
            end
        end
        println("Iteration $iteration:")
        iteration += 1
    end
    return life_iteration
end

end # module
