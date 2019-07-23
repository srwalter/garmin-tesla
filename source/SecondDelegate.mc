using Toybox.WatchUi as Ui;
using Toybox.Communications as Communications;

class SecondDelegate extends Ui.BehaviorDelegate {
    var _handler;
    var _tesla;
    var _token;

    function initialize(handler) {
        BehaviorDelegate.initialize();
        _handler = handler;
        _token = Application.getApp().getProperty("token");
        _tesla = new Tesla(_token);
    }

    function onSelect() {
        if (_token != null) {
            getVehicles();
        } else {
            _handler.invoke("Authenticating...");
            _tesla.authenticate(method(:onReceiveAuth));
        }
        return true;
    }

    function getVehicles() {
        _handler.invoke("Getting vehicles...");
        _tesla.getVehicleId(method(:onReceiveVehicles));
    }

    function onReceiveAuth(responseCode, data) {
        if (responseCode == 200) {
            getVehicles();
        } else {
            _handler.invoke("Error: " + responseCode.toString());
        }
    }

    function onReceiveVehicles(responseCode, data) {
        System.println("on receive vehicles");
        if (responseCode == 200) {
            var id = data.get("response")[0].get("id");
            _handler.invoke("Getting climate state...");
            _tesla.getClimateState(id, method(:onReceiveClimate));
        } else {
            _handler.invoke("Error: " + responseCode.toString());
        }
    }

    function onReceiveClimate(responseCode, data) {
        if (responseCode == 200) {
            _handler.invoke(data);
        } else {
            _handler.invoke("Error: " + responseCode.toString());
        }
    }
}