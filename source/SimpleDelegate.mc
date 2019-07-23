using Toybox.WatchUi as Ui;

class SimpleDelegate extends Ui.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() {
        var view = new SecondView();
        Ui.pushView(view, new SecondDelegate(view.method(:onReceive)), Ui.SLIDE_UP);
        return true;
    }

}