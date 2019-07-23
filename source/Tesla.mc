class Tesla {
    hidden var _token;
    hidden var _notify;

    function initialize(token) {
        if (token != null) {
            _token = "Bearer " + token;
        }
    }

    function authenticate(notify) {
        _notify = notify;
        Communications.makeWebRequest(
            "https://owner-api.teslamotors.com/oauth/token",
            {
                "grant_type" => "password",
                "client_id" => "81527cff06843c8634fdc09e8ac0abefb46ac849f38fe1e431c2ef2106796384",
                "client_secret" => "c7257eb71a564034f9419ee651c7d0e5f7aa6bfbd18bafb5c5c033b093bb2fa3",
                "email" => "steven@stevenwalter.org",
                "password" => ""
            },
            {
                :method => Communications.HTTP_REQUEST_METHOD_POST,
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
            },
            method(:authCallback)
        );
    }

    function getVehicleId(notify) {
        System.println(_token);
        Communications.makeWebRequest(
            "https://owner-api.teslamotors.com/api/1/vehicles",
            null,
            {
                :method => Communications.HTTP_REQUEST_METHOD_GET,
                :headers => {
                    "Authorization" => _token
                },
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
            },
            notify
        );
    }

    function getClimateState(vehicle, notify) {
        var url = "https://owner-api.teslamotors.com/api/1/vehicles/" + vehicle.toString() + "/data_request/climate_state";
        System.println(url);
        Communications.makeWebRequest(
            url,
            null,
            {
                :method => Communications.HTTP_REQUEST_METHOD_GET,
                :headers => {
                    "Authorization" => _token
                },
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
            },
            notify
        );
    }

    function authCallback(responseCode, data) {
        if (responseCode == 200) {
            Application.getApp().setProperty("token", data.get("access_token"));
            _token = "Bearer " + data.get("access_token");
        }
        _notify.invoke(responseCode, data);
    }
}