using Toybox.WatchUi as Ui;
using Toybox.Communications as Communications;

class SecondDelegate extends Ui.BehaviorDelegate {
    var _handler;
    var _tesla;

    function initialize(handler) {
        BehaviorDelegate.initialize();
        _handler = handler;
        _tesla = new Tesla();
    }

    function onSelect() {
        _handler.invoke("Authenticating...");
        _tesla.authenticate(method(:onReceiveAuth));
        return true;
    }

    function onReceiveAuth(responseCode, data) {
        if (responseCode == 200) {
            _handler.invoke("Getting vehicles...");
            _tesla.getVehicleId(method(:onReceiveVehicles));
        } else {
            _handler.invoke("Error: " + responseCode.toString());
        }
    }

    function onReceiveVehicles(responseCode, data) {
        if (responseCode == 200) {
            _handler.invoke(data.get("id"));
        } else {
            _handler.invoke("Error: " + responseCode.toString());
        }
    }
}