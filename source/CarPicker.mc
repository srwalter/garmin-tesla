using Toybox.WatchUi;
using Toybox.Graphics;

class CarPicker extends WatchUi.Picker {
    function initialize (cars) {
        var title = new WatchUi.Text({:text=>Rez.Strings.car_chooser_title, :locX =>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM, :color=>Graphics.COLOR_WHITE});
        var factory = new WordFactory(cars);
        Picker.initialize({:pattern => [factory], :title => title});
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        Picker.onUpdate(dc);
    }
}

class CarPickerDelegate extends WatchUi.PickerDelegate {
    var _controller;
    var _selected;

    function initialize (controller) {
        _controller = controller;
        PickerDelegate.initialize();
    }

    function onCancel () {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

    function onAccept (values) {
        _selected = values[0];
        _controller._tesla.getVehicleId(method(:onReceiveVehicles));
    }

    function onReceiveVehicles(responseCode, data) {
        if (responseCode == 200) {
            var vehicles = data.get("response");
            for (var i = 0; i < vehicles.size(); i++) {
                if (_selected.equals(vehicles[i].get("display_name"))) {
                    Application.getApp().setProperty("vehicle", vehicles[i].get("id"));
                    WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                }
            }
        } else {
            _controller._handler.invoke(WatchUi.loadResource(Rez.Strings.label_error) + responseCode.toString());
        }
    }
}
