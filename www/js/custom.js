$(function () {
    console.log("ready!");

    var decorate = function () {
        if (!$("table").length) {
            return;
        }
        $("td").each(function () {
            var content = $(this).text();
            if (content.startsWith("EPI_ISL_")) {
                var newHtml = "<span class='decorated' epi_isl_id='" + content + "'>" + content + "</span>";
                $(this).html(newHtml);
            }
        });
        // gisaid.addPopups();		
    }

    setInterval(decorate, 1000);
});



