using Toybox.WatchUi as Ui;

class SimpleDelegate extends Ui.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() {
        var data = new TeslaData();
        var view = new SecondView(data);
        Ui.pushView(view, new SecondDelegate(data, view.method(:onReceive)), Ui.SLIDE_UP);
        return true;
    }

}