module Overview

export constructor_overview

using Master.Life: calls, query, completed, instances, processes

function construct_html_table(list, fields)::AbstractString
    text = "<table>"
    for i in 1:length(list)
        text *= "<tr>"
        for field in fields
            text *= "<td>$(getfield(list[i], field))</td>"
        end
        text *= "</tr>"
    end
    text *= "</table>"
end

function construct_html_table_with_head(list, head, fields)::AbstractString
    text = "<table><tr>"
    for entry in head
        text *= "<th>$(entry)</th>"
    end
    text *= "</tr>"
    for i in 1:length(list)
        text *= "<tr>"
        for field in fields
            if field == :instance
                instance = getfield(list[i], field)
                text *= "<td>$(getfield(instance, :userhost))</td>"
            elseif field == :task
                instance = getfield(list[i], field)
                text *= "<td>$(getfield(instance, :id))</td>"
            elseif typeof(getfield(list[i], field)) == DateTime
                str = replace(string(getfield(list[i], field)), "T", " ")
                text *= "<td>$(str)</td>"
            else
                text *= "<td>$(getfield(list[i], field))</td>"
            end
        end
        text *= "</tr>"
    end
    text *= "</table>"
end

function constructor_overview()
    html_doc = readlines(open("../src/web/frontend/overview.html"))
    html_doc = join(html_doc, "")
    html_parts = split(html_doc, "{}")
    if length(html_parts) != 2
        error("The html page has broken formatting.")
    end
    function overview(list_of_pairs_of_list_and_name)
        insertion = ""
        for i in 1:length(list_of_pairs_of_list_and_name)
            li = list_of_pairs_of_list_and_name[i][1]
            if length(li) == 0
                continue
            end
            name = list_of_pairs_of_list_and_name[i][2]
            bad_atoms = [:password, :process, :log_file]
            fields = filter((x) -> !(x in bad_atoms), fieldnames(li[1]))
            head = map((x) -> replace(ucfirst(string(x)), "_", " "), fields)
            text = construct_html_table_with_head(li, head, fields)
            insertion *= "<h2>$(name)</h2><p>"
            insertion *= text * "<p>"
        end
        return html_parts[1] * insertion * html_parts[2]
    end
    return () -> overview([(instances, "Instances"),
                           (calls, "Calls"),
                           (processes, "Processes"),
                           (query, "Query"),
                           (completed, "Completed")])
end

end # module
