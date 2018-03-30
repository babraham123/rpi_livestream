// Populate WiFi ssids on load.

$(document).ready(function () {
    $.ajax({
        url: "/ssids",
        success: function( res ) {
            res = JSON.parse(res);
            $.each(res.ssids, function (i, ssid) {
                $('#ssid').append($('<option>', { 
                    value: ssid,
                    text : ssid 
                }));
            });
        }
    });
});
