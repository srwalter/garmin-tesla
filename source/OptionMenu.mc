using Toybox.WatchUi as Ui;

class OptionMenuDelegate extends Ui.MenuInputDelegate {
    var _controller;

    function initialize(controller) {
        Ui.MenuInputDelegate.initialize();
        _controller = controller;
    }

    function onMenuItem(item) {
        if (item == :reset) {
            System.println("menu");
            Settings.setToken(null);
            Application.getApp().setProperty("vehicle", null);
        } else if (item == :honk) {
            _controller._honk_horn = true;
            _controller.stateMachine();
        } else if (item == :select_car) {
            System.println("select car 1");
            _controller._tesla.getVehicleId(method(:onReceiveVehicles));
            System.println("select car 2");
        } else if (item == :toggle_units) {
            var units = Application.getApp().getProperty("imperial");
            if (units) {
                Application.getApp().setProperty("imperial", false);
            } else {
                Application.getApp().setProperty("imperial", true);
            }
        /* Template:
        } else if (item == :"%snake_case%) {
            _controller._"%snake_case% = true;
            _controller.stateMachine();
        */
        }
    }

    function onReceiveVehicles(responseCode, data) {
        System.println("on receive vehicles");
        if (responseCode == 200) {
            System.println("Got vehicles");
            var vehicles = data.get("response");
            var vins = new [vehicles.size()];
            for (var i = 0; i < vehicles.size(); i++) {
                vins[i] = vehicles[i].get("display_name");
            }
            Ui.pushView(new CarPicker(vins), new CarPickerDelegate(_controller), Ui.SLIDE_UP);
        } else {
            System.println("error " + responseCode.toString());
            _controller._handler.invoke(Ui.loadResource(Rez.Strings.label_error) + responseCode.toString());
        }
    }
}
