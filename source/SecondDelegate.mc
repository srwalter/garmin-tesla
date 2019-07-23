using Toybox.WatchUi as Ui;
using Toybox.Communications as Communications;

class SecondDelegate extends Ui.BehaviorDelegate {
    var _handler;
    var _tesla;
    var _vehicle_id;
    var _need_auth;
    var _auth_done;
    var _need_wake;
    var _wake_done;

    var _get_climate;
    var _set_climate;
    var _get_charge;

    var _data;

    function initialize(data, handler) {
        BehaviorDelegate.initialize();
        _data = data;
        var _token = Application.getApp().getProperty("token");
        _vehicle_id = Application.getApp().getProperty("vehicle");
        _handler = handler;
        _tesla = new Tesla(_token);

        if (_token != null) {
            _need_auth = 0;
            _auth_done = 1;
        } else {
            _need_auth = 1;
            _auth_done = 0;
        }
        _need_wake = 1;
        _wake_done = 0;

        _set_climate = 0;
        _get_climate = 1;
        _get_charge = 1;
        stateMachine();
    }

    function stateMachine() {
        if (_need_auth) {
            _handler.invoke("Authenticating...");
            _tesla.authenticate(method(:onReceiveAuth));
        }

        if (!_auth_done) {
            return;
        }

        if (_vehicle_id == null) {
            _handler.invoke("Getting vehicles...");
            _tesla.getVehicleId(method(:onReceiveVehicles));
            return;
        }

        if (_need_wake) {
            _need_wake = 0;
            _handler.invoke("Waking vehicle...");
            _tesla.wakeVehicle(_vehicle_id, method(:onReceiveAwake));
            return;
        }

        if (!_wake_done) {
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

        if (_set_climate) {
            _set_climate = 0;
            _tesla.climateOn(_vehicle_id, method(:onClimateDone));
        }
    }

    function onSelect() {
        _set_climate = 1;
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
            _data._climate = data.get("response");
            System.println("Got climate");
            _handler.invoke(null);
        } else {
            _handler.invoke("Error: " + responseCode.toString());
        }
    }

    function onReceiveCharge(responseCode, data) {
        if (responseCode == 200) {
            _data._charge = data.get("response");
            System.println("Got charge");
            _handler.invoke(null);
        } else {
            _handler.invoke("Error: " + responseCode.toString());
        }
    }

    function onReceiveAwake(responseCode, data) {
        if (responseCode == 200) {
            _wake_done = 1;
            stateMachine();
        } else {
            _handler.invoke("Error: " + responseCode.toString());
        }
    }

    function onClimateDone(responseCode, data) {
        if (responseCode == 200) {
            _get_climate = 1;
            stateMachine();
        } else {
            _handler.invoke("Error: " + responseCode.toString());
        }
    }
}