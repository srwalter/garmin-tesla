using Toybox.WatchUi as Ui;
using Toybox.Communications as Communications;

class SecondDelegate extends Ui.BehaviorDelegate {
    var _handler;
    var _token;
    var _tesla;
    var _vehicle_id;
    var _need_auth;
    var _auth_done;
    var _need_wake;
    var _wake_done;

    var _get_climate;
    var _set_climate;
    var _get_charge;
    var _honk_horn;

    var _data;

    function initialize(data, handler) {
        BehaviorDelegate.initialize();
        _data = data;
        _token = Application.getApp().getProperty("token");
        _vehicle_id = Application.getApp().getProperty("vehicle");
        _handler = handler;

        if (_token != null) {
            _need_auth = false;
            _auth_done = true;
        } else {
            _need_auth = true;
            _auth_done = false;
        }
        _need_wake = true;
        _wake_done = false;

        _set_climate = false;
        _get_climate = true;
        _get_charge = true;
        _honk_horn = false;
        stateMachine();
    }

    function stateMachine() {
        if (_need_auth) {
            _need_auth = false;
            _handler.invoke("Login on Phone!");
            //_tesla.authenticate(method(:onReceiveAuth));
            Communications.registerForOAuthMessages(method(:onOAuthMessage));
            Communications.makeOAuthRequest(
                "https://dasbrennen.org/~srwalter/tesla.html",
                {},
                "https://dasbrennen.org/~srwalter/tesla-done.html",
                Communications.OAUTH_RESULT_TYPE_URL,
                {
                    "responseCode" => "OAUTH_CODE",
                    "responseError" => "OAUTH_ERROR"
                }
            );
            return;
        }

        if (!_auth_done) {
            return;
        }

        _tesla = new Tesla(_token);

        if (_vehicle_id == null) {
            _handler.invoke("Getting vehicles...");
            _tesla.getVehicleId(method(:onReceiveVehicles));
            return;
        }

        if (_need_wake) {
            _need_wake = false;
            _handler.invoke("Waking vehicle...");
            _tesla.wakeVehicle(_vehicle_id, method(:onReceiveAwake));
            return;
        }

        if (!_wake_done) {
            return;
        }

        if (_get_climate) {
            _get_climate = false;
            _tesla.getClimateState(_vehicle_id, method(:onReceiveClimate));
        }

        if (_get_charge) {
            _get_charge = false;
            _tesla.getChargeState(_vehicle_id, method(:onReceiveCharge));
        }

        if (_set_climate) {
            _set_climate = false;
            _handler.invoke("HVAC On");
            _tesla.climateOn(_vehicle_id, method(:onClimateDone));
        }

        if (_honk_horn) {
            _honk_horn = false;
            _handler.invoke("Honk");
            _tesla.honkHorn(_vehicle_id, method(:genericHandler));
        }
    }

    function onSelect() {
        _set_climate = true;
        stateMachine();
        return true;
    }

    function onNextPage() {
        _honk_horn = true;
        stateMachine();
        return true;
    }

    function onBack() {
        Ui.popView(Ui.SLIDE_DOWN);
        return true;
    }

    function onReceiveAuth(responseCode, data) {
        if (responseCode == 200) {
            _auth_done = true;
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
            _wake_done = true;
            _handler.invoke("Vehicle awake");
            stateMachine();
        } else {
            _handler.invoke("Error: " + responseCode.toString());
        }
    }

    function onClimateDone(responseCode, data) {
        if (responseCode == 200) {
            _get_climate = true;
            _handler.invoke(null);
            stateMachine();
        } else {
            _handler.invoke("Error: " + responseCode.toString());
        }
    }

    function genericHandler(responseCode, data) {
        if (responseCode == 200) {
            _handler.invoke(null);
            stateMachine();
        } else {
            _handler.invoke("Error: " + responseCode.toString());
        }
    }

    function onOAuthMessage(message) {
        if (message.data != null) {
            _token = message.data["OAUTH_CODE"];
            Application.getApp().setProperty("token", _token);
            _auth_done = true;
            stateMachine();
        } else {
            _handler.invoke("OAuth err");
        }
    }
}