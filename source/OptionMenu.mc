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
        } else if (item == :toggle_units) {
            var units = Application.getApp().getProperty("imperial");
            if (units) {
                Application.getApp().setProperty("imperial", false);
            } else {
                Application.getApp().setProperty("imperial", true);
            }
        }
    }
}
