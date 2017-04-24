if (localStorage.getItem("state") == null)
{
	localStorage.setItem("state", "day");
}
$("tr:nth-child(even)").addClass("even");
function pressStyleButton()
{
    if (localStorage.getItem("state") == "day")
		localStorage.setItem("state", "night");
	else
		localStorage.setItem("state", "day");
	refreshStyle();
}
function refreshStyle()
{
    if (localStorage.getItem("state") == "night")
    {
        document.querySelector("body").style.backgroundColor = "#21252B";
        document.querySelector("body").style.color = "#58AFDD";
        document.querySelector("div.content").style.backgroundColor = "#282C34";
        document.querySelector("div.content").style.borderColor = "#3C424E";
        input = document.querySelectorAll("input")
        for (i = 0; i < input.length; i++) {
            input[i].style.backgroundColor = "#2C323E";
            input[i].style.borderColor = "#8BD0EE"; }
        th = document.querySelectorAll("th")
        for (i = 0; i < th.length; i++)
            th[i].style.borderColor = "#3C424E";
        td = document.querySelectorAll("td")
        for (i = 0; i < td.length; i++)
            td[i].style.borderColor = "#3C424E";
        heads = document.querySelectorAll("h2")
        for (i = 0; i < heads.length; i++)
            heads[i].style.color = "#58AFDD";
        tables = document.querySelectorAll("table")
        for (i = 0; i < tables.length; i++)
        {
            tables[i].style.color = "#58AFDD";
            tables[i].style.borderColor = "#3C424E";
        }
        for (i = 0; i < $("tr:nth-child(even)").addClass("even").length; i++)
        {$("tr:nth-child(even)").addClass("even")[i].style.backgroundColor="#2C323E";}
        document.querySelector("button").style.backgroundColor = "#58AFDD";
    }
    else // if "day"
    {
        document.querySelector("body").style.backgroundColor = "#ffffff";
        document.querySelector("body").style.color = "#000000";
        document.querySelector("div.content").style.backgroundColor = "#f0f0ff";
        document.querySelector("div.content").style.borderColor = "#b0b0ff";
        input = document.querySelectorAll("input")
        for (i = 0; i < input.length; i++) {
            input[i].style.backgroundColor = "#e0e0ff";
            input[i].style.borderColor = "#8BD0EE"; }
        th = document.querySelectorAll("th")
        for (i = 0; i < th.length; i++)
            th[i].style.borderColor = "#b0b0ff";
        td = document.querySelectorAll("td")
        for (i = 0; i < td.length; i++)
            td[i].style.borderColor = "#b0b0ff";
        heads = document.querySelectorAll("h2")
        for (i = 0; i < heads.length; i++)
            heads[i].style.color = "#000000";
        tables = document.querySelectorAll("table")
        for (i = 0; i < tables.length; i++)
        {
            tables[i].style.color = "#000000";
            tables[i].style.borderColor = "#b0b0ff";
        }
        for (i = 0; i < $("tr:nth-child(even)").addClass("even").length; i++)
        {$("tr:nth-child(even)").addClass("even")[i].style.backgroundColor="#e0e0ff";}
        document.querySelector("button").style.backgroundColor = "#5BC0DE";
    }
}
