module Startup_utils

export install_julia, read_instance_list, read_tasks_list

using DataFrames
using Master.Types

function install_julia(userhost, folder="~", sshpass=nothing, sshfile=nothing)
    if sshpass != nothing
        spawn(`sshpass -p $sshpass scp julia.tar.gz $userhost:$folder;
               sshpass -p $sshpass ssh $userhost
                   "cd $folder;
                   tar -xzf julia.tar.gz;
                   rm julia.tar.gz"`)
    elseif sshfile != nothing
        spawn(`scp -i $sshfile julia.tar.gz $userhost:$folder;
               ssh -i $sshfile $userhost
                   "cd $folder;
                   tar -xzf julia.tar.gz;
                   rm julia.tar.gz"`)
    else
        spawn(`scp julia.tar.gz $userhost:$folder;
               ssh $userhost
                   "cd $folder;
                   tar -xzf julia.tar.gz;
                   rm julia.tar.gz"`)
    end
end

function read_instance_list(
        file::AbstractString="instances.csv")::Array{Instance_info,1}
    instances = Array{Instance_info,1}()
    try
        table = readtable(file)
        for i in 1:length(table[1]) # for each entry in the table
            println("Enter password for $(table[1][i]):")
            password = chomp(readline())
            run(`clear`)
            instance = Instance_info(table[1][i], password, table[2][i])
            push!(instances, instance)
        end
    catch e
        println(e)
        warn("The instances list failed to load.")
        instances = Array{Instance_info,1}()
    end
    return instances
end

function read_tasks_list(
        file::AbstractString="tasks.csv")::Array{Requested_task,1}
    tasks = Array{Requested_task,1}()
    try
        table = readtable(file)
        for i in 1:length(table[1]) # for each entry in the table
            task = Requested_task(table[1][i], table[2][i])
            push!(tasks, task)
        end
    catch e
        println(e)
        warn("The tasks list failed to load.")
        tasks = Array{Requested_task,1}()
    end
    return tasks
end

end # module
