module App

export start_app

using Web.Backend.Overview: constructor_overview
importall Bukdu

type OverviewController <: ApplicationController
    conn::Conn
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

    Bukdu.start(8080, getaddrinfo("0.0.0.0"))
end

end # module
