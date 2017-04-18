module Monitoring

export get_gpu_state, add_logging_to_pyfile, run_task

function get_gpu_state(gpu_id::Integer)
    i = 0
    output = readstring(open(pipeline(`nvidia-smi`, `cat`))[1])
    for line in split(output, "\n")
        if contains(line, "%")
            if i == gpu_id
                if parse(Int, split(line)[13][1:end-1]) > 5
                    return 0 # Busy
                else
                    return 1 # Free
                end
            else
                i += 1
            end
        end
    end
    error("The selected gpu id wasn't found.")
end

function update_logs(log_pos, file)
    text = join(readlines(seek(open(file), log_pos)), "")
    return (text, log_pos + length(text))
end

function add_logging_to_pyfile(file)
    # This function will append changed stdin to python file.
    # So the file will write not to terminal but to file.
    prepend = "import sys\nimport functools\nsys.stdout = open(\"log.txt\", \"w\")\nprint = functools.partial(print, flush=True)"
    data = join(readlines(open(file, "r")), "")
    if startswith(data, prepend)
        return
    end
    rm(file)
    fw = open(file, "w")
    write(fw, string(prepend,data))
    close(fw)
end

function run_task(command::Cmd)::Base.Process
    return spawn(command)
end

end # module
