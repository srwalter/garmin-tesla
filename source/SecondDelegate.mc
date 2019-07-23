using Toybox.WatchUi as Ui;
using Toybox.Communications as Communications;

class SecondDelegate extends Ui.BehaviorDelegate {
    var _handler;
    var _tesla;
    var _vehicle_id;
    var _need_auth;
    var _need_wake;

    var _get_climate;
    var _get_charge;

    var _climate;
    var _charge;

    function initialize(handler) {
        BehaviorDelegate.initialize();
        var _token = Application.getApp().getProperty("token");
        _vehicle_id = Application.getApp().getProperty("vehicle");
        _handler = handler;
        _tesla = new Tesla(_token);

        _get_climate = 0;
        _get_charge = 0;

        if (_token != null) {
            _need_auth = 0;
        } else {
            _need_auth = 1;
        }
        _need_wake = 1;
    }

    function stateMachine() {
        if (_need_auth) {
            _handler.invoke("Authenticating...");
            _tesla.authenticate(method(:onReceiveAuth));
            return;
        }

        if (_vehicle_id == null) {
            _handler.invoke("Getting vehicles...");
            _tesla.getVehicleId(method(:onReceiveVehicles));
            return;
        }

        if (_need_wake) {
            _handler.invoke("Waking vehicle...");
            _tesla.wakeVehicle(_vehicle_id, method(:onReceiveAwake));
            return;
        }

        _handler.invoke("Vehicle awake");
        if (_get_climate) {
            _get_climate = 0;
            _tesla.getClimateState(_vehicle_id, method(:onReceiveClimate));
        }

        if (_get_charge) {
            _get_charge = 0;
            _tesla.getChargeState(_vehicle_id, method(:onReceiveCharge));
        }
    }

    function onSelect() {
        _get_climate = 1;
        stateMachine();
        return true;
    }

    function onReceiveAuth(responseCode, data) {
        if (responseCode == 200) {
            _need_auth = 0;
            stateMachine();
        } else {
            _handler.invoke("Error: " + responseCode.toString());
        }
    }

    function onReceiveVehicles(responseCode, data) {
        System.println("on receive vehicles");
        if (responseCode == 200) {
            _vehicle_id = data.get("response")[0].get("id");
            Application.getApp().setProperty("vehicle", _vehicle_id);
            stateMachine();
        } else {
            _handler.invoke("Error: " + responseCode.toString());
        }
    }

    function onReceiveClimate(responseCode, data) {
        if (responseCode == 200) {
            _climate = data;
        } else {
            _handler.invoke("Error: " + responseCode.toString());
        }
    }

    function onReceiveCharge(responseCode, data) {
        if (responseCode == 200) {
            _charge = data;
        } else {
            _handler.invoke("Error: " + responseCode.toString());
        }
    }

    function onReceiveAwake(responseCode, data) {
        _need_wake = 0;
        stateMachine();
    }
}