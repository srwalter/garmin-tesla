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
            Application.getApp().setProperty("token", null);
            Application.getApp().setProperty("vehicle", null);
        } else if (item == :honk) {
            _controller._honk_horn = true;
            _controller.stateMachine();
        }
    }
}
