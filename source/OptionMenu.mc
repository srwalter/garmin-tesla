using Toybox.WatchUi as Ui;

class OptionMenuDelegate extends Ui.MenuInputDelegate {
    function initialize() {
        Ui.MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        if (item == :reset) {
            System.println("menu");
            Application.getApp().setProperty("token", null);
            Application.getApp().setProperty("vehicle", null);
        }
    }
}
