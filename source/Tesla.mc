class Tesla {
    hidden var _token;
    hidden var _notify;

    function initialize(token) {
        if (token != null) {
            _token = "Bearer " + token;
        }
    }

    hidden function genericGet(url, notify) {
        Communications.makeWebRequest(
            url, null,
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

    function getVehicleId(notify) {
        System.println(_token);
        genericGet("https://owner-api.teslamotors.com/api/1/vehicles", notify);
    }

    function getClimateState(vehicle, notify) {
        var url = "https://owner-api.teslamotors.com/api/1/vehicles/" + vehicle.toString() + "/data_request/climate_state";
        System.println(url);
        genericGet(url, notify);
    }

    function getChargeState(vehicle, notify) {
        var url = "https://owner-api.teslamotors.com/api/1/vehicles/" + vehicle.toString() + "/data_request/charge_state";
        System.println(url);
        genericGet(url, notify);
    }

    function getVehicleState(vehicle, notify) {
        var url = "https://owner-api.teslamotors.com/api/1/vehicles/" + vehicle.toString() + "/data_request/vehicle_state";
        System.println(url);
        genericGet(url, notify);
    }

    function genericPost(url, notify) {
        Communications.makeWebRequest(
            url,
            null,
            {
                :method => Communications.HTTP_REQUEST_METHOD_POST,
                :headers => {
                    "Authorization" => _token
                },
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
            },
            notify
        );
    }

    function wakeVehicle(vehicle, notify) {
        var url = "https://owner-api.teslamotors.com/api/1/vehicles/" + vehicle.toString() + "/wake_up";
        System.println(url);
        genericPost(url, notify);
    }

    function climateOn(vehicle, notify) {
        var url = "https://owner-api.teslamotors.com/api/1/vehicles/" + vehicle.toString() + "/command/auto_conditioning_start";
        System.println(url);
        genericPost(url, notify);
    }

    function climateOff(vehicle, notify) {
        var url = "https://owner-api.teslamotors.com/api/1/vehicles/" + vehicle.toString() + "/command/auto_conditioning_stop";
        System.println(url);
        genericPost(url, notify);
    }

    function honkHorn(vehicle, notify) {
        var url = "https://owner-api.teslamotors.com/api/1/vehicles/" + vehicle.toString() + "/command/honk_horn";
        System.println(url);
        genericPost(url, notify);
    }

    function doorUnlock(vehicle, notify) {
        var url = "https://owner-api.teslamotors.com/api/1/vehicles/" + vehicle.toString() + "/command/door_unlock";
        System.println(url);
        genericPost(url, notify);
    }

    function doorLock(vehicle, notify) {
        var url = "https://owner-api.teslamotors.com/api/1/vehicles/" + vehicle.toString() + "/command/door_lock";
        System.println(url);
        genericPost(url, notify);
    }

    function openFrunk(vehicle, notify) {
        var url = "https://owner-api.teslamotors.com/api/1/vehicles/" + vehicle.toString() + "/command/actuate_trunk";
        System.println(url);
        Communications.makeWebRequest(
            url,
            {
                "which_trunk" => "front"
            },
            {
                :method => Communications.HTTP_REQUEST_METHOD_POST,
                :headers => {
                    "Authorization" => _token
                },
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
            },
            notify
        );
    }

    //function authCallback(responseCode, data) {
    //    if (responseCode == 200) {
    //        Application.getApp().setProperty("token", data.get("access_token"));
    //        _token = "Bearer " + data.get("access_token");
    //    }
    //    _notify.invoke(responseCode, data);
    //}
}
