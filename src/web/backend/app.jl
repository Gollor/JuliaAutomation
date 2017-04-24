module App

export start_app

using Web.Backend.Overview: constructor_overview
importall Bukdu

type OverviewController <: ApplicationController
    conn::Conn
end

function get_file(filename)
    loaded_file = join(readlines(open("../src/web/frontend/$filename")), "")
    function get_loaded_file(void)
        return loaded_file
    end
end

function start_app()
    overview_builder = constructor_overview()
    function overview(c::OverviewController)
        q = c[:params]
        # x, y = map(v -> parse(Int, v), (q[:x], q[:y]))
        # render(JSON, x + 2*y)
        return overview_builder()
    end

    Router() do
        get("/", OverviewController, overview)
    end

    Endpoint() do
        plug(Plug.Logger)
        plug(Plug.Static, at="/static", from="../src/web/frontend/static")
        plug(Router)
    end

    Bukdu.start(8080, getaddrinfo("0.0.0.0"))
end

end # module
