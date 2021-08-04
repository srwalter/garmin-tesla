using Toybox.WatchUi as Ui;

class OptionMenuDelegate extends Ui.MenuInputDelegate {
    var _controller;

    function initialize(controller) {
        Ui.MenuInputDelegate.initialize();
        _controller = controller;
    }

    function onMenuItem(item) {
        if (item == :reset) {
            Settings.setToken(null);
            Application.getApp().setProperty("vehicle", null);
        } else if (item == :honk) {
            _controller._honk_horn = true;
            _controller.stateMachine();
        } else if (item == :select_car) {
            _controller._tesla.getVehicleId(method(:onReceiveVehicles));
        } else if (item == :open_port) {
            _controller._open_port = true;
            _controller.stateMachine();
        } else if (item == :toggle_units) {
            var units = Application.getApp().getProperty("imperial");
            if (units) {
                Application.getApp().setProperty("imperial", false);
            } else {
                Application.getApp().setProperty("imperial", true);
            }
        } else if (item == :toggle_view) {
            var view = Application.getApp().getProperty("image_view");
            if (view) {
                Application.getApp().setProperty("image_view", false);
            } else {
                Application.getApp().setProperty("image_view", true);
            }
        }
    }

    function onReceiveVehicles(responseCode, data) {
        if (responseCode == 200) {
            var vehicles = data.get("response");
            var vins = new [vehicles.size()];
            for (var i = 0; i < vehicles.size(); i++) {
                vins[i] = vehicles[i].get("display_name");
            }
            Ui.pushView(new CarPicker(vins), new CarPickerDelegate(_controller), Ui.SLIDE_UP);
        } else {
            _controller._handler.invoke(Ui.loadResource(Rez.Strings.label_error) + responseCode.toString());
        }
    }
}
