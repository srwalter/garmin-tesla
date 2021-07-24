using Toybox.Application as App;
using Toybox.Background;
using Toybox.System;
using Toybox.Time;
using Toybox.WatchUi as Ui;

(:background)
class MyServiceDelegate extends System.ServiceDelegate {

    function initialize() {
        System.ServiceDelegate.initialize();
    }

    // This fires on our temporal event - we're going to go off and get the vehicle data, only if we have a token and vehicle ID
    function onTemporalEvent() {
        var _token = Settings.getToken();
        var _vehicle_id = Application.getApp().getProperty("vehicle");

        if (_token != null && _vehicle_id != null)
        {
            var _tesla = new Tesla(_token);
            System.println("Getting vehicle data");
            _tesla.getVehicleData(_vehicle_id, method(:onReceiveVehicleData));
        }
    }   

    function onReceiveVehicleData(responseCode, responseData) {
        // The API request has returned check for any other background data waiting (we don't want to lose it)
        var data = Background.getBackgroundData();
        if (data == null) {
            data = {};
		}

        // Deal with appropriately - we care about awake (200) or asleep (408)
        if (responseCode == 200) {
            System.println("Got vehicle data");

            var vehicle_data = responseData.get("response");    
            var battery_level = vehicle_data.get("charge_state").get("battery_level");
            var charging_state = vehicle_data.get("charge_state").get("charging_state");
            data.put("status", battery_level + "%" + (charging_state == "true" ? "+" : "") + " at " + System.getClockTime().hour.format("%d")+":"+System.getClockTime().min.format("%02d"));
            Background.exit(data);
        } else if (responseCode == 408) {
            System.println("Asleep");

            data.put("status", "Asleep" + " at " + System.getClockTime().hour.format("%d")+":"+System.getClockTime().min.format("%02d"));
            Background.exit(data);
        } else {
            System.println("Problem");

            data.put("status", "Problem" + " at " + System.getClockTime().hour.format("%d")+":"+System.getClockTime().min.format("%02d"));
            Background.exit(data);
        }
    }
}